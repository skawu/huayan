#ifndef HMICOMMUNICATIONMANAGER_H
#define HMICOMMUNICATIONMANAGER_H

#include <QObject>
#include <QString>
#include <QMap>
#include <QVariant>
#include <QTimer>
#include <QMutex>

class HYModbusTcpDriver;
class OpcUaDataSource;

class HMICommunicationManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionStatusChanged)
    Q_PROPERTY(QString protocol READ protocol WRITE setProtocol NOTIFY protocolChanged)

public:
    explicit HMICommunicationManager(QObject *parent = nullptr);
    ~HMICommunicationManager();

    // 协议类型
    enum Protocol {
        ModbusTCP,
        OPCUA
    };
    Q_ENUM(Protocol)

    // 连接管理
    Q_INVOKABLE bool connect(const QString &url, const QString &username = "", const QString &password = "");
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE bool isConnected() const;

    // 点位绑定
    Q_INVOKABLE bool bindPoint(const QString &tagName, const QString &deviceAddress, int dataType = 0);
    Q_INVOKABLE bool unbindPoint(const QString &tagName);
    Q_INVOKABLE bool isPointBound(const QString &tagName) const;

    // 数据读写
    Q_INVOKABLE QVariant readPoint(const QString &tagName);
    Q_INVOKABLE bool writePoint(const QString &tagName, const QVariant &value);
    Q_INVOKABLE void updatePoint(const QString &tagName, const QVariant &value);

    // 配置
    QString protocol() const;
    void setProtocol(const QString &protocol);

    Q_INVOKABLE void setUpdateInterval(int interval);
    Q_INVOKABLE int updateInterval() const;

signals:
    void connectionStatusChanged(bool connected);
    void protocolChanged();
    void pointUpdated(const QString &tagName, const QVariant &value);
    void communicationError(const QString &error);

private slots:
    void onDataUpdated(const QString &tagName, const QVariant &value);
    void onConnectionStateChanged(bool connected);
    void syncData();

private:
    // 点位绑定结构
    struct PointBinding {
        QString deviceAddress;
        int dataType;
        QVariant lastValue;
        int updateCount;
    };

    // 通信驱动
    HYModbusTcpDriver *m_modbusDriver;
    OpcUaDataSource *m_opcuaDataSource;

    // 配置
    Protocol m_protocol;
    QString m_url;
    QString m_username;
    QString m_password;
    int m_updateInterval;
    bool m_connected;

    // 点位绑定
    QMap<QString, PointBinding> m_pointBindings;
    QMutex m_mutex;
    QTimer *m_syncTimer;

    // 初始化驱动
    void initializeDrivers();
    void cleanupDrivers();

    // 数据同步
    void syncModbusData();
    void syncOpcUaData();
};

#endif // HMICOMMUNICATIONMANAGER_H
