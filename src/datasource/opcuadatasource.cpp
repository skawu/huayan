#include "opcuadatasource.h"

/**
 * @file opcuadatasource.cpp
 * @brief OPC UA数据源实现
 * 
 * 实现了OpcUaDataSource类的核心功能，包括OPC UA服务器的连接、订阅和数据同步
 * 支持与Huayan点位管理系统的绑定，确保数据的实时更新
 */

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
    QMutexLocker locker(&m_mutex);

    // 断开现有连接
    if (m_client) {
        delete m_client;
        m_client = nullptr;
    }

    // 创建OPC UA客户端
    m_client = new QOpcUaClient(QOpcUaClient::Backends::open62541, this);
    
    // 连接信号槽
    connect(m_client, &QOpcUaClient::stateChanged, this, &OpcUaDataSource::onConnectionStateChanged);
    connect(m_client, &QOpcUaClient::attributeChanged, this, &OpcUaDataSource::onAttributeChanged);

    // 设置认证信息
    if (!username.isEmpty()) {
        m_client->setUserName(username);
        m_client->setPassword(password);
    }

    // 连接到服务器
    m_client->connectToEndpoint(url);

    // 等待连接完成（最多5秒）
    int timeout = 5000;
    int interval = 100;
    int elapsed = 0;
    while (m_client->state() != QOpcUaClient::ClientState::Connected && elapsed < timeout) {
        QThread::msleep(interval);
        QCoreApplication::processEvents();
        elapsed += interval;
    }

    if (m_client->state() == QOpcUaClient::ClientState::Connected) {
        // 启动同步定时器
        m_syncTimer->start();
        return true;
    }

    return false;
}

void OpcUaDataSource::disconnectFromServer()
{
    QMutexLocker locker(&m_mutex);

    // 停止同步定时器
    m_syncTimer->stop();

    // 断开连接
    if (m_client) {
        m_client->disconnectFromEndpoint();
        delete m_client;
        m_client = nullptr;
    }

    // 清空节点绑定
    m_nodeBindings.clear();

    emit connectionStatusChanged(false);
}

bool OpcUaDataSource::isConnected() const
{
    QMutexLocker locker(&m_mutex);
    return m_client && m_client->state() == QOpcUaClient::ClientState::Connected;
}

bool OpcUaDataSource::bindNodeToTag(const QString &nodeId, const QString &tagName, int samplingInterval)
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QOpcUaClient::ClientState::Connected) {
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
    QOpcUaNode *node = m_client->node(nodeId);
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
}

bool OpcUaDataSource::unbindNodeFromTag(const QString &nodeId)
{
    QMutexLocker locker(&m_mutex);

    if (!m_nodeBindings.contains(nodeId)) {
        return false;
    }

    // 禁用监控
    NodeBinding binding = m_nodeBindings[nodeId];
    if (binding.node) {
        binding.node->disableMonitoring(QOpcUa::NodeAttribute::Value);
        delete binding.node;
    }

    // 从映射中移除
    m_nodeBindings.remove(nodeId);

    return true;
}

QVariant OpcUaDataSource::readNodeValue(const QString &nodeId)
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QOpcUaClient::ClientState::Connected) {
        return QVariant();
    }

    QOpcUaNode *node = m_client->node(nodeId);
    if (!node) {
        return QVariant();
    }

    // 读取节点值
    QOpcUaValue value = node->attribute(QOpcUa::NodeAttribute::Value);
    delete node;

    return value.value();
}

bool OpcUaDataSource::writeNodeValue(const QString &nodeId, const QVariant &value)
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QOpcUaClient::ClientState::Connected) {
        return false;
    }

    QOpcUaNode *node = m_client->node(nodeId);
    if (!node) {
        return false;
    }

    // 写入节点值
    bool result = node->writeAttribute(QOpcUa::NodeAttribute::Value, value);
    delete node;

    return result;
}

void OpcUaDataSource::onConnectionStateChanged(QOpcUaClient::ClientState state)
{
    bool connected = (state == QOpcUaClient::ClientState::Connected);
    emit connectionStatusChanged(connected);

    if (connected) {
        m_syncTimer->start();
    } else {
        m_syncTimer->stop();
    }
}

void OpcUaDataSource::onAttributeChanged(const QString &nodeId, QOpcUa::NodeAttribute attribute, const QVariant &value)
{
    if (attribute != QOpcUa::NodeAttribute::Value) {
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
}

void OpcUaDataSource::syncData()
{
    QMutexLocker locker(&m_mutex);

    if (!m_client || m_client->state() != QOpcUaClient::ClientState::Connected) {
        return;
    }

    // 同步所有绑定的节点数据
    for (const QString &nodeId : m_nodeBindings.keys()) {
        const NodeBinding &binding = m_nodeBindings[nodeId];
        
        if (binding.node) {
            // 读取节点值
            QOpcUaValue value = binding.node->attribute(QOpcUa::NodeAttribute::Value);
            if (value.isValid()) {
                // 更新Huayan点位值
                m_tagManager->setTagValue(binding.tagName, value.value());
                
                // 发出数据更新信号
                emit dataUpdated(binding.tagName, value.value());
            }
        }
    }
}
