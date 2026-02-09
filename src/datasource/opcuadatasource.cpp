#include "opcuadatasource.h"

/**
 * @file opcuadatasource.cpp
 * @brief OPC UA数据源实现
 * 
 * 实现了OpcUaDataSource类的核心功能，包括OPC UA服务器的连接、订阅和数据同步
 * 支持与Huayan点位管理系统的绑定，确保数据的实时更新
 */

#ifdef HAVE_OPCUA
#include <QOpcUaClient>
#include <QOpcUaNode>
#include <QOpcUaValue>
#include <QOpcUaMonitoringParameters>
#include <QThread>
#endif

OpcUaDataSource::OpcUaDataSource(HYTagManager *tagManager, QObject *parent) 
    : QObject(parent),
      m_tagManager(tagManager),
      m_client(nullptr),
      m_syncTimer(new QTimer(this))
{
    // 初始化同步定时器
    m_syncTimer->setInterval(100); // 默认100ms同步一次
    connect(m_syncTimer, &QTimer::timeout, this, &OpcUaDataSource::syncData);
}

OpcUaDataSource::~OpcUaDataSource()
{
    disconnectFromServer();
    delete m_syncTimer;
}

bool OpcUaDataSource::connectToServer(const QString &url, const QString &username, const QString &password)
{
#ifdef HAVE_OPCUA
    QMutexLocker locker(&m_mutex);

    // 断开现有连接
    if (m_client) {
        delete static_cast<QOpcUaClient*>(m_client);
        m_client = nullptr;
    }

    // 创建OPC UA客户端
    QOpcUaClient *client = new QOpcUaClient(QOpcUaClient::Backends::open62541, this);
    
    // 连接信号槽
    connect(client, &QOpcUaClient::stateChanged, this, [this](QOpcUaClient::ClientState state) {
        onConnectionStateChanged(static_cast<int>(state));
    });
    connect(client, &QOpcUaClient::attributeChanged, this, [this](const QString &nodeId, QOpcUa::NodeAttribute attribute, const QVariant &value) {
        onAttributeChanged(nodeId, static_cast<int>(attribute), value);
    });

    // 设置认证信息
    if (!username.isEmpty()) {
        client->setUserName(username);
        client->setPassword(password);
    }

    m_client = client;

    // 连接到服务器
    client->connectToEndpoint(url);

    // 等待连接完成（最多5秒）
    int timeout = 5000;
    int interval = 100;
    int elapsed = 0;
    while (client->state() != QOpcUaClient::ClientState::Connected && elapsed < timeout) {
        QThread::msleep(interval);
        QCoreApplication::processEvents();
        elapsed += interval;
    }

    if (client->state() == QOpcUaClient::ClientState::Connected) {
        // 启动同步定时器
        m_syncTimer->start();
        return true;
    }
#else
    Q_UNUSED(url)
    Q_UNUSED(username)
    Q_UNUSED(password)
#endif
    return false;
}

void OpcUaDataSource::disconnectFromServer()
{
#ifdef HAVE_OPCUA
    QMutexLocker locker(&m_mutex);

    // 停止同步定时器
    m_syncTimer->stop();

    // 断开连接
    if (m_client) {
        static_cast<QOpcUaClient*>(m_client)->disconnectFromEndpoint();
        delete static_cast<QOpcUaClient*>(m_client);
        m_client = nullptr;
    }

    // 清空节点绑定
    m_nodeBindings.clear();

    emit connectionStatusChanged(false);
#endif
}

bool OpcUaDataSource::isConnected() const
{
#ifdef HAVE_OPCUA
    QMutexLocker locker(&m_mutex);
    return m_client && static_cast<QOpcUaClient*>(m_client)->state() == QOpcUaClient::ClientState::Connected;
#else
    return false;
#endif
}

bool OpcUaDataSource::bindNodeToTag(const QString &nodeId, const QString &tagName, int samplingInterval)
{
#ifdef HAVE_OPCUA
    QMutexLocker locker(&m_mutex);

    if (!m_client || static_cast<QOpcUaClient*>(m_client)->state() != QOpcUaClient::ClientState::Connected) {
        return false;
    }

    // 检查点位是否存在
    if (!m_tagManager->getTag(tagName)) {
        // 点位不存在，创建新点位
        if (!m_tagManager->addTag(tagName, "OPC UA", 0, "OPC UA tag", "OPC UA")) {
            return false;
        }
    }

    // 创建节点
    QOpcUaNode *node = static_cast<QOpcUaClient*>(m_client)->node(nodeId);
    if (!node) {
        return false;
    }

    // 订阅节点值变化
    QOpcUaMonitoringParameters params;
    params.setPublishingInterval(samplingInterval);
    params.setSamplingInterval(samplingInterval);
    node->enableMonitoring(QOpcUa::NodeAttribute::Value, params);

    // 添加到绑定映射
    NodeBinding binding;
    binding.tagName = tagName;
    binding.samplingInterval = samplingInterval;
    binding.node = node;
    m_nodeBindings[nodeId] = binding;

    return true;
#else
    Q_UNUSED(nodeId)
    Q_UNUSED(tagName)
    Q_UNUSED(samplingInterval)
    return false;
#endif
}

bool OpcUaDataSource::unbindNodeFromTag(const QString &nodeId)
{
#ifdef HAVE_OPCUA
    QMutexLocker locker(&m_mutex);

    if (!m_nodeBindings.contains(nodeId)) {
        return false;
    }

    // 禁用监控
    NodeBinding binding = m_nodeBindings[nodeId];
    if (binding.node) {
        static_cast<QOpcUaNode*>(binding.node)->disableMonitoring(QOpcUa::NodeAttribute::Value);
        delete static_cast<QOpcUaNode*>(binding.node);
    }

    // 从映射中移除
    m_nodeBindings.remove(nodeId);

    return true;
#else
    Q_UNUSED(nodeId)
    return false;
#endif
}

QVariant OpcUaDataSource::readNodeValue(const QString &nodeId)
{
#ifdef HAVE_OPCUA
    QMutexLocker locker(&m_mutex);

    if (!m_client || static_cast<QOpcUaClient*>(m_client)->state() != QOpcUaClient::ClientState::Connected) {
        return QVariant();
    }

    QOpcUaNode *node = static_cast<QOpcUaClient*>(m_client)->node(nodeId);
    if (!node) {
        return QVariant();
    }

    // 读取节点值
    QOpcUaValue value = node->attribute(QOpcUa::NodeAttribute::Value);
    delete node;

    return value.value();
#else
    Q_UNUSED(nodeId)
    return QVariant();
#endif
}

bool OpcUaDataSource::writeNodeValue(const QString &nodeId, const QVariant &value)
{
#ifdef HAVE_OPCUA
    QMutexLocker locker(&m_mutex);

    if (!m_client || static_cast<QOpcUaClient*>(m_client)->state() != QOpcUaClient::ClientState::Connected) {
        return false;
    }

    QOpcUaNode *node = static_cast<QOpcUaClient*>(m_client)->node(nodeId);
    if (!node) {
        return false;
    }

    // 写入节点值
    bool result = node->writeAttribute(QOpcUa::NodeAttribute::Value, value);
    delete node;

    return result;
#else
    Q_UNUSED(nodeId)
    Q_UNUSED(value)
    return false;
#endif
}

void OpcUaDataSource::onConnectionStateChanged(int state)
{
#ifdef HAVE_OPCUA
    QMutexLocker locker(&m_mutex);
    
    bool connected = (state == static_cast<int>(QOpcUaClient::ClientState::Connected));
    emit connectionStatusChanged(connected);

    if (connected) {
        m_syncTimer->start();
    } else {
        m_syncTimer->stop();
    }
#else
    Q_UNUSED(state)
#endif
}

void OpcUaDataSource::onAttributeChanged(const QString &nodeId, int attribute, const QVariant &value)
{
#ifdef HAVE_OPCUA
    if (attribute != static_cast<int>(QOpcUa::NodeAttribute::Value)) {
        return;
    }

    QMutexLocker locker(&m_mutex);

    // 检查是否有绑定
    if (m_nodeBindings.contains(nodeId)) {
        const NodeBinding &binding = m_nodeBindings[nodeId];
        
        // 更新Huayan点位值
        m_tagManager->setTagValue(binding.tagName, value);
        
        // 发出数据更新信号
        emit dataUpdated(binding.tagName, value);
    }
#else
    Q_UNUSED(nodeId)
    Q_UNUSED(attribute)
    Q_UNUSED(value)
#endif
}

void OpcUaDataSource::syncData()
{
#ifdef HAVE_OPCUA
    QMutexLocker locker(&m_mutex);

    if (!m_client || static_cast<QOpcUaClient*>(m_client)->state() != QOpcUaClient::ClientState::Connected) {
        return;
    }

    // 同步所有绑定的节点数据
    for (const QString &nodeId : m_nodeBindings.keys()) {
        const NodeBinding &binding = m_nodeBindings[nodeId];
        
        if (binding.node) {
            // 读取节点值
            QOpcUaValue value = static_cast<QOpcUaNode*>(binding.node)->attribute(QOpcUa::NodeAttribute::Value);
            if (value.isValid()) {
                // 更新Huayan点位值
                m_tagManager->setTagValue(binding.tagName, value.value());
                
                // 发出数据更新信号
                emit dataUpdated(binding.tagName, value.value());
            }
        }
    }
#endif
}
