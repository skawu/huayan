#include "mqttdatasource.h"

/**
 * @file mqttdatasource.cpp
 * @brief MQTT数据源实现
 * 
 * 实现了MqttDataSource类的核心功能，包括MQTT broker的连接、订阅和数据同步
 * 支持与Huayan点位管理系统的绑定，确保数据的实时更新
 */

#ifdef HAVE_MQTT
#include <QMqttClient>
#include <QMqttMessage>
#include <QThread>
#endif

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
#ifdef HAVE_MQTT
    QMutexLocker locker(&m_mutex);

    // 断开现有连接
    if (m_client) {
        delete static_cast<QMqttClient*>(m_client);
        m_client = nullptr;
    }

    // 创建MQTT客户端
    QMqttClient *client = new QMqttClient(this);
    client->setHostname(host);
    client->setPort(port);
    client->setClientId(clientId);
    
    // 设置认证信息
    if (!username.isEmpty()) {
        client->setUsername(username);
        client->setPassword(password);
    }

    // 连接信号槽
    connect(client, &QMqttClient::stateChanged, this, [this](QMqttClient::ClientState state) {
        onConnectionStateChanged(static_cast<int>(state));
    });
    connect(client, &QMqttClient::messageReceived, this, [this](const QMqttMessage &message) {
        onMessageReceived(message.payload(), message.topic().name());
    });

    m_client = client;

    // 连接到broker
    client->connectToHost();

    // 等待连接完成（最多5秒）
    int timeout = 5000;
    int interval = 100;
    int elapsed = 0;
    while (client->state() != QMqttClient::ClientState::Connected && elapsed < timeout) {
        QThread::msleep(interval);
        QCoreApplication::processEvents();
        elapsed += interval;
    }

    if (client->state() == QMqttClient::ClientState::Connected) {
        // 启动同步定时器
        m_syncTimer->start();
        return true;
    }
#else
    Q_UNUSED(host)
    Q_UNUSED(port)
    Q_UNUSED(clientId)
    Q_UNUSED(username)
    Q_UNUSED(password)
#endif
    return false;
}

void MqttDataSource::disconnectFromBroker()
{
#ifdef HAVE_MQTT
    QMutexLocker locker(&m_mutex);

    // 停止同步定时器
    m_syncTimer->stop();

    // 断开连接
    if (m_client) {
        static_cast<QMqttClient*>(m_client)->disconnectFromHost();
        delete static_cast<QMqttClient*>(m_client);
        m_client = nullptr;
    }

    // 清空主题绑定
    m_topicBindings.clear();

    emit connectionStatusChanged(false);
#endif
}

bool MqttDataSource::isConnected() const
{
#ifdef HAVE_MQTT
    QMutexLocker locker(&m_mutex);
    return m_client && static_cast<QMqttClient*>(m_client)->state() == QMqttClient::ClientState::Connected;
#else
    return false;
#endif
}

bool MqttDataSource::bindTopicToTag(const QString &topic, const QString &tagName, quint8 qos)
{
#ifdef HAVE_MQTT
    QMutexLocker locker(&m_mutex);

    if (!m_client || static_cast<QMqttClient*>(m_client)->state() != QMqttClient::ClientState::Connected) {
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
    static_cast<QMqttClient*>(m_client)->subscribe(topic, qos);

    // 添加到绑定映射
    TopicBinding binding;
    binding.tagName = tagName;
    binding.qos = qos;
    m_topicBindings[topic] = binding;

    return true;
#else
    Q_UNUSED(topic)
    Q_UNUSED(tagName)
    Q_UNUSED(qos)
    return false;
#endif
}

bool MqttDataSource::unbindTopicFromTag(const QString &topic)
{
#ifdef HAVE_MQTT
    QMutexLocker locker(&m_mutex);

    if (!m_topicBindings.contains(topic)) {
        return false;
    }

    // 取消订阅
    if (m_client) {
        static_cast<QMqttClient*>(m_client)->unsubscribe(topic);
    }

    // 从映射中移除
    m_topicBindings.remove(topic);

    return true;
#else
    Q_UNUSED(topic)
    return false;
#endif
}

bool MqttDataSource::publishMessage(const QString &topic, const QByteArray &payload, quint8 qos, bool retain)
{
#ifdef HAVE_MQTT
    QMutexLocker locker(&m_mutex);

    if (!m_client || static_cast<QMqttClient*>(m_client)->state() != QMqttClient::ClientState::Connected) {
        return false;
    }

    // 发布消息
    auto subscription = static_cast<QMqttClient*>(m_client)->publish(topic, payload, qos, retain);
    return subscription >= 0;
#else
    Q_UNUSED(topic)
    Q_UNUSED(payload)
    Q_UNUSED(qos)
    Q_UNUSED(retain)
    return false;
#endif
}

void MqttDataSource::onConnectionStateChanged(int state)
{
#ifdef HAVE_MQTT
    QMutexLocker locker(&m_mutex);
    
    bool connected = (state == static_cast<int>(QMqttClient::ClientState::Connected));
    emit connectionStatusChanged(connected);

    if (connected && m_client) {
        // 重新订阅所有主题
        for (const QString &topic : m_topicBindings.keys()) {
            const TopicBinding &binding = m_topicBindings[topic];
            static_cast<QMqttClient*>(m_client)->subscribe(topic, binding.qos);
        }
        m_syncTimer->start();
    } else {
        m_syncTimer->stop();
    }
#else
    Q_UNUSED(state)
#endif
}

void MqttDataSource::onMessageReceived(const QByteArray &message, const QString &topic)
{
#ifdef HAVE_MQTT
    QMutexLocker locker(&m_mutex);

    // 检查是否有绑定
    if (m_topicBindings.contains(topic)) {
        const TopicBinding &binding = m_topicBindings[topic];
        
        // 解析负载为QVariant
        QVariant value;
        
        // 尝试解析为不同类型
        bool ok;
        double doubleValue = message.toDouble(&ok);
        if (ok) {
            value = doubleValue;
        } else {
            int intValue = message.toInt(&ok);
            if (ok) {
                value = intValue;
            } else {
                bool boolValue = (message == "true" || message == "1" || message == "on");
                value = boolValue;
            }
        }
        
        // 更新Huayan点位值
        m_tagManager->setTagValue(binding.tagName, value);
        
        // 发出数据更新信号
        emit dataUpdated(binding.tagName, value);
    }
#else
    Q_UNUSED(message)
    Q_UNUSED(topic)
#endif
}

void MqttDataSource::syncData()
{
#ifdef HAVE_MQTT
    QMutexLocker locker(&m_mutex);

    if (!m_client || static_cast<QMqttClient*>(m_client)->state() != QMqttClient::ClientState::Connected) {
        return;
    }

    // MQTT主要通过订阅机制获取数据，这里可以添加额外的同步逻辑
    // 例如，对于需要主动查询的数据点，可以定期发布查询消息
#endif
}
