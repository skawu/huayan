#ifndef OPCUADATASOURCE_H
#define OPCUADATASOURCE_H

#include <QObject>
#include <QOpcUaClient>
#include <QOpcUaNode>
#include <QOpcUaValue>
#include <QTimer>
#include <QMutex>
#include "../core/tagmanager.h"

/**
 * @file opcuadatasource.h
 * @brief OPC UA数据源适配类
 * 
 * 此类实现了OPC UA数据源的适配，支持与Huayan点位管理系统的绑定
 * 提供OPC UA服务器的连接、订阅和数据同步功能
 */

class OpcUaDataSource : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param tagManager 点位管理器指针
     * @param parent 父对象
     */
    explicit OpcUaDataSource(HYTagManager *tagManager, QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~OpcUaDataSource();

    // 连接管理
    /**
     * @brief 连接到OPC UA服务器
     * @param url 服务器URL
     * @param username 用户名
     * @param password 密码
     * @return 连接是否成功
     */
    bool connectToServer(const QString &url, const QString &username = "", const QString &password = "");
    
    /**
     * @brief 断开与OPC UA服务器的连接
     */
    void disconnectFromServer();
    
    /**
     * @brief 检查连接状态
     * @return 是否连接
     */
    bool isConnected() const;

    // 点位绑定
    /**
     * @brief 绑定OPC UA节点到Huayan点位
     * @param nodeId OPC UA节点ID
     * @param tagName Huayan点位名称
     * @param samplingInterval 采样间隔（毫秒）
     * @return 绑定是否成功
     */
    bool bindNodeToTag(const QString &nodeId, const QString &tagName, int samplingInterval = 100);
    
    /**
     * @brief 解除OPC UA节点与Huayan点位的绑定
     * @param nodeId OPC UA节点ID
     * @return 解除绑定是否成功
     */
    bool unbindNodeFromTag(const QString &nodeId);

    // 数据操作
    /**
     * @brief 读取OPC UA节点值
     * @param nodeId OPC UA节点ID
     * @return 节点值
     */
    QVariant readNodeValue(const QString &nodeId);
    
    /**
     * @brief 写入OPC UA节点值
     * @param nodeId OPC UA节点ID
     * @param value 要写入的值
     * @return 写入是否成功
     */
    bool writeNodeValue(const QString &nodeId, const QVariant &value);

signals:
    /**
     * @brief 连接状态变化信号
     * @param connected 是否连接
     */
    void connectionStatusChanged(bool connected);
    
    /**
     * @brief 数据更新信号
     * @param tagName 点位名称
     * @param value 新值
     */
    void dataUpdated(const QString &tagName, const QVariant &value);

private slots:
    /**
     * @brief 连接状态变化槽函数
     * @param state 连接状态
     */
    void onConnectionStateChanged(QOpcUaClient::ClientState state);
    
    /**
     * @brief 属性变化槽函数
     * @param nodeId 节点ID
     * @param attribute 属性ID
     * @param value 新值
     */
    void onAttributeChanged(const QString &nodeId, QOpcUa::NodeAttribute attribute, const QVariant &value);
    
    /**
     * @brief 定期同步数据
     */
    void syncData();

private:
    HYTagManager *m_tagManager; ///< 点位管理器指针
    QOpcUaClient *m_client; ///< OPC UA客户端
    QTimer *m_syncTimer; ///< 同步定时器
    QMutex m_mutex; ///< 互斥锁
    
    // 节点绑定映射
    struct NodeBinding {
        QString tagName; ///< 点位名称
        int samplingInterval; ///< 采样间隔
        QOpcUaNode *node; ///< OPC UA节点
    };
    QMap<QString, NodeBinding> m_nodeBindings; ///< 节点绑定映射表
};

#endif // OPCUADATASOURCE_H
