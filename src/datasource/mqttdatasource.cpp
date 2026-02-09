#include "mqttdatasource.h"

/**
 * @file mqttdatasource.cpp
 * @brief MQTT数据源实现
 * 
 * 实现了MqttDataSource类的核心功能，包括MQTT broker的连接、订阅和数据同步
 * 支持与Huayan点位管理系统的绑定，确保数据的实时更新
 */

MqttDataSource::MqttDataSource(HYTagManager *tagManager, QObject *parent) 
    : QObject(parent),
      m_tagManager(tagManager),
      m_client(nullptr),
      m_syncTimer(new QTimer(this))
{
    // 初始化同步定时器
    m_syncTimer->setInterval(100); // 默认100ms同步一次
    connect(m_syncTimer, &QTimer::timeout, this, &MqttDataSource::syncData);
}

MqttDataSource::~MqttDataSource()
{
    disconnectFromBroker();
    delete m_syncTimer;
}

bool MqttDataSource::connectToBroker(const QString &host, quint16 port, const QString &clientId, 
                                    const QString &username, const QString &password)
{
    QMutexLocker locker(&m_mutex);

    // 断开现有连接
    if (m_client) {
        delete m_client;
        m_client = nullptr;
    }

    // 创建MQTT客户端
    m_client = new QMqttClient(this);
    m_client->setHostname(host);
    m_client->setPort(port);
    m_client->setClientId(clientId);
    
    // 设置认证信息
    if (!username.isEmpty()) {
        m_client->setUsername(username);
        m_client->setPassword(password);
    }

    // 连接信号槽
    connect(m_client, &QMqttClient::stateChanged, this, &MqttDataSource::onConnectionStateChanged);
    connect(m_client, &QMqttClient::messageReceived, this, &MqttDataSource::onMessageReceived);

    // 连接到broker
    m_client->connectToHost();

    // 等待连接完成（最多5秒）
    int timeout = 5000;
    int interval = 100;
    int elapsed = 0;
    while (m_client->state() != QMqttClient::ClientState::Connected && elapsed < timeout) {
        QThread::msleep(interval);
        QCoreApplication::processEvents();
        elapsed += interval;
    }

    if (m_client->state() == QMqttClient::ClientState::Connected) {
        // 启动同步定时器
        m_syncTimer->start();
        return true;
    }

    return false;
}

void MqttDataSource::disconnectFromBroker()
{
    QMutexLocker locker(&m_mutex);

    // 停止同步定时器
    m_syncTimer->stop();

    // 断开连接
    if (m_client) {
        m_client->disconnectFromHost();
        delete m_client;
        m_client = nullptr;
    }

    // 清空主题绑定
    m_topicBindings.clear();

    emit connectionStatusChanged(false);
}

bool MqttDataSource::isConnected() const
{
    QMutexLocker locker(&m_mutex);
    return m_client && m_client->state() == QMqttClient::ClientState::Connected;
}

bool MqttDataSource::bindTopicToTag(const QString &topic, const QString &tagName, quint8 qos)
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QMqttClient::ClientState::Connected) {
        return false;
    }

    // 检查点位是否存在
    if (!m_tagManager->getTag(tagName)) {
        // 点位不存在，创建新点位
        if (!m_tagManager->addTag(tagName, "MQTT", 0, "MQTT tag", "MQTT")) {
            return false;
        }
    }

    // 订阅主题
    m_client->subscribe(topic, qos);

    // 添加到绑定映射
    TopicBinding binding;
    binding.tagName = tagName;
    binding.qos = qos;
    m_topicBindings[topic] = binding;

    return true;
}

bool MqttDataSource::unbindTopicFromTag(const QString &topic)
{
    QMutexLocker locker(&m_mutex);

    if (!m_topicBindings.contains(topic)) {
        return false;
    }

    // 取消订阅
    m_client->unsubscribe(topic);

    // 从映射中移除
    m_topicBindings.remove(topic);

    return true;
}

bool MqttDataSource::publishMessage(const QString &topic, const QByteArray &payload, quint8 qos, bool retain)
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QMqttClient::ClientState::Connected) {
        return false;
    }

    // 发布消息
    auto subscription = m_client->publish(topic, payload, qos, retain);
    return subscription >= 0;
}

void MqttDataSource::onConnectionStateChanged(QMqttClient::ClientState state)
{
    bool connected = (state == QMqttClient::ClientState::Connected);
    emit connectionStatusChanged(connected);

    if (connected) {
        // 重新订阅所有主题
        for (const QString &topic : m_topicBindings.keys()) {
            const TopicBinding &binding = m_topicBindings[topic];
            m_client->subscribe(topic, binding.qos);
        }
        m_syncTimer->start();
    } else {
        m_syncTimer->stop();
    }
}

void MqttDataSource::onMessageReceived(const QMqttMessage &message)
{
    QMutexLocker locker(&m_mutex);

    // 获取主题和负载
    QString topic = message.topic().name();
    QByteArray payload = message.payload();

    // 检查是否有绑定
    if (m_topicBindings.contains(topic)) {
        const TopicBinding &binding = m_topicBindings[topic];
        
        // 解析负载为QVariant
        QVariant value;
        
        // 尝试解析为不同类型
        bool ok;
        double doubleValue = payload.toDouble(&ok);
        if (ok) {
            value = doubleValue;
        } else {
            int intValue = payload.toInt(&ok);
            if (ok) {
                value = intValue;
            } else {
                bool boolValue = (payload == "true" || payload == "1" || payload == "on");
                value = boolValue;
            }
        }
        
        // 更新Huayan点位值
        m_tagManager->setTagValue(binding.tagName, value);
        
        // 发出数据更新信号
        emit dataUpdated(binding.tagName, value);
    }
}

void MqttDataSource::syncData()
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QMqttClient::ClientState::Connected) {
        return;
    }

    // MQTT主要通过订阅机制获取数据，这里可以添加额外的同步逻辑
    // 例如，对于需要主动查询的数据点，可以定期发布查询消息
}
