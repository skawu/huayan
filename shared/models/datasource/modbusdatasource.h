#ifndef MODBUSDATASOURCE_H
#define MODBUSDATASOURCE_H

#include <QObject>
#include <QModbusTcpClient>
#include <QModbusDataUnit>
#include <QTimer>
#include <QMutex>
#include "datasource.h"

/**
 * @file modbusdatasource.h
 * @brief Modbus数据源适配类
 * 
 * 此类实现了Modbus数据源的适配，支持与Huayan点位管理系统的绑定
 * 提供Modbus TCP服务器的连接、读写和数据同步功能
 */

class ModbusDataSource : public DataSource
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param tagManager 点位管理器指针
     * @param parent 父对象
     */
    explicit ModbusDataSource(HYTagManager *tagManager, QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~ModbusDataSource();

    // 连接管理
    /**
     * @brief 连接到数据源
     * @param parameters 连接参数
     * @return 连接是否成功
     */
    bool connect(const QMap<QString, QVariant> &parameters) override;
    
    /**
     * @brief 断开与数据源的连接
     */
    void disconnect() override;
    
    /**
     * @brief 检查连接状态
     * @return 是否连接
     */
    bool isConnected() const override;

    // 点位绑定
    /**
     * @brief 绑定数据源地址到Huayan点位
     * @param address 数据源地址
     * @param tagName Huayan点位名称
     * @param samplingInterval 采样间隔（毫秒）
     * @return 绑定是否成功
     */
    bool bindAddressToTag(const QString &address, const QString &tagName, int samplingInterval = 100) override;
    
    /**
     * @brief 解除数据源地址与Huayan点位的绑定
     * @param address 数据源地址
     * @return 解除绑定是否成功
     */
    bool unbindAddressFromTag(const QString &address) override;

    // 数据操作
    /**
     * @brief 读取数据
     * @param address 数据源地址
     * @return 读取的值
     */
    QVariant readData(const QString &address) override;
    
    /**
     * @brief 写入数据
     * @param address 数据源地址
     * @param value 要写入的值
     * @return 写入是否成功
     */
    bool writeData(const QString &address, const QVariant &value) override;

    // 数据源信息
    /**
     * @brief 获取数据源类型
     * @return 数据源类型
     */
    QString type() const override;
    
    /**
     * @brief 获取数据源名称
     * @return 数据源名称
     */
    QString name() const override;

    // 传统方法（保持向后兼容）
    /**
     * @brief 连接到Modbus TCP服务器
     * @param host 主机地址
     * @param port 端口号
     * @param slaveId 从站ID
     * @return 连接是否成功
     */
    bool connectToServer(const QString &host, quint16 port, quint8 slaveId);
    
    /**
     * @brief 断开与Modbus TCP服务器的连接
     */
    void disconnectFromServer();
    
    /**
     * @brief 绑定Modbus寄存器到Huayan点位
     * @param registerType 寄存器类型
     * @param address 寄存器地址
     * @param tagName Huayan点位名称
     * @param samplingInterval 采样间隔（毫秒）
     * @return 绑定是否成功
     */
    bool bindRegisterToTag(QModbusDataUnit::RegisterType registerType, quint16 address, 
                          const QString &tagName, int samplingInterval = 100);
    
    /**
     * @brief 解除Modbus寄存器与Huayan点位的绑定
     * @param registerType 寄存器类型
     * @param address 寄存器地址
     * @return 解除绑定是否成功
     */
    bool unbindRegisterFromTag(QModbusDataUnit::RegisterType registerType, quint16 address);

    /**
     * @brief 读取Modbus寄存器
     * @param registerType 寄存器类型
     * @param address 起始地址
     * @param count 寄存器数量
     * @return 读取的值
     */
    QVector<quint16> readRegisters(QModbusDataUnit::RegisterType registerType, quint16 address, quint16 count);
    
    /**
     * @brief 写入Modbus寄存器
     * @param registerType 寄存器类型
     * @param address 起始地址
     * @param values 要写入的值
     * @return 写入是否成功
     */
    bool writeRegisters(QModbusDataUnit::RegisterType registerType, quint16 address, const QVector<quint16> &values);
    
    /**
     * @brief 读取单个线圈
     * @param address 线圈地址
     * @return 线圈状态
     */
    bool readCoil(quint16 address);
    
    /**
     * @brief 写入单个线圈
     * @param address 线圈地址
     * @param value 线圈状态
     * @return 写入是否成功
     */
    bool writeCoil(quint16 address, bool value);
    
    /**
     * @brief 读取多个线圈
     * @param address 起始地址
     * @param count 线圈数量
     * @return 线圈状态列表
     */
    QList<bool> readMultipleCoils(quint16 address, quint16 count);

private slots:
    /**
     * @brief 连接状态变化槽函数
     * @param state 连接状态
     */
    void onConnectionStateChanged(QModbusDevice::State state);
    
    /**
     * @brief 读取完成槽函数
     * @param reply 读取回复
     */
    void onReadFinished(QModbusReply *reply);
    
    /**
     * @brief 定期同步数据
     */
    void syncData();

private:
    QModbusTcpClient *m_client; ///< Modbus TCP客户端
    QTimer *m_syncTimer; ///< 同步定时器
    QMutex m_mutex; ///< 互斥锁
    quint8 m_slaveId; ///< 从站ID
    QString m_host; ///< 主机地址
    quint16 m_port; ///< 端口号
    
    // 寄存器绑定映射
    struct RegisterBinding {
        QString tagName; ///< 点位名称
        int samplingInterval; ///< 采样间隔
    };
    QMap<QPair<QModbusDataUnit::RegisterType, quint16>, RegisterBinding> m_registerBindings; ///< 寄存器绑定映射表
    
    // 地址解析辅助函数
    bool parseAddress(const QString &address, QModbusDataUnit::RegisterType &registerType, quint16 &regAddress) const;
    QString createAddressString(QModbusDataUnit::RegisterType registerType, quint16 address) const;
};

#endif // MODBUSDATASOURCE_H
