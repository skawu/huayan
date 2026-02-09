#ifndef MQTTDATASOURCE_H
#define MQTTDATASOURCE_H

#include <QObject>
#include <QTimer>
#include <QMutex>
#include "../core/tagmanager.h"

// Conditionally include Mqtt headers if available
#ifdef HAVE_MQTT
#include <QMqttClient>
#include <QMqttMessage>
#endif

/**
 * @file mqttdatasource.h
 * @brief MQTT数据源适配类
 * 
 * 此类实现了MQTT数据源的适配，支持与Huayan点位管理系统的绑定
 * 提供MQTT broker的连接、订阅和数据同步功能
 */

class MqttDataSource : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param tagManager 点位管理器指针
     * @param parent 父对象
     */
    explicit MqttDataSource(HYTagManager *tagManager, QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~MqttDataSource();

    // 连接管理
    /**
     * @brief 连接到MQTT broker
     * @param host 主机地址
     * @param port 端口号
     * @param clientId 客户端ID
     * @param username 用户名
     * @param password 密码
     * @return 连接是否成功
     */
    bool connectToBroker(const QString &host, quint16 port, const QString &clientId, 
                        const QString &username = "", const QString &password = "");
    
    /**
     * @brief 断开与MQTT broker的连接
     */
    void disconnectFromBroker();
    
    /**
     * @brief 检查连接状态
     * @return 是否连接
     */
    bool isConnected() const;

    // 点位绑定
    /**
     * @brief 绑定MQTT主题到Huayan点位
     * @param topic MQTT主题
     * @param tagName Huayan点位名称
     * @param qos QoS级别
     * @return 绑定是否成功
     */
    bool bindTopicToTag(const QString &topic, const QString &tagName, quint8 qos = 1);
    
    /**
     * @brief 解除MQTT主题与Huayan点位的绑定
     * @param topic MQTT主题
     * @return 解除绑定是否成功
     */
    bool unbindTopicFromTag(const QString &topic);

    // 数据操作
    /**
     * @brief 发布MQTT消息
     * @param topic 主题
     * @param payload 负载
     * @param qos QoS级别
     * @param retain 是否保留
     * @return 发布是否成功
     */
    bool publishMessage(const QString &topic, const QByteArray &payload, quint8 qos = 1, bool retain = false);

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
    void onConnectionStateChanged(int state);
    
    /**
     * @brief 消息接收槽函数
     * @param message 接收到的消息
     */
    void onMessageReceived(const QByteArray &message, const QString &topic);
    
    /**
     * @brief 定期同步数据
     */
    void syncData();

private:
    HYTagManager *m_tagManager; ///< 点位管理器指针
    void *m_client; ///< MQTT客户端
    QTimer *m_syncTimer; ///< 同步定时器
    QMutex m_mutex; ///< 互斥锁
    
    // 主题绑定映射
    struct TopicBinding {
        QString tagName; ///< 点位名称
        quint8 qos; ///< QoS级别
    };
    QMap<QString, TopicBinding> m_topicBindings; ///< 主题绑定映射表
};

#endif // MQTTDATASOURCE_H
