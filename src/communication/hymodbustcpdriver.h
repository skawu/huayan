#ifndef HYMODBUSTCPDRIVER_H
#define HYMODBUSTCPDRIVER_H

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QEventLoop>
#include <QModbusClient>
#include <QModbusTcpClient>
#include <QModbusDataUnit>

/**
 * @file hymodbustcpdriver.h
 * @brief Modbus TCP驱动类头文件
 * 
 * 此类实现了Modbus TCP协议的通信功能，用于与工业设备进行数据交换
 */

/**
 * @class HYModbusTcpDriver
 * @brief Modbus TCP驱动类
 * 
 * 负责与Modbus TCP设备的通信，包括连接管理、数据读写、错误处理等功能
 */
class HYModbusTcpDriver : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param parent 父对象
     */
    explicit HYModbusTcpDriver(QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~HYModbusTcpDriver();

    // 连接管理
    /**
     * @brief 连接到设备
     * @param ipAddress 设备IP地址
     * @param port 设备端口号
     * @param slaveId 从站ID
     * @return 连接是否成功
     */
    bool connectToDevice(const QString &ipAddress, int port, int slaveId);
    
    /**
     * @brief 断开与设备的连接
     */
    void disconnectFromDevice();
    
    /**
     * @brief 检查是否已连接
     * @return 是否已连接
     */
    bool isConnected() const;

    // 数据读写
    /**
     * @brief 读取线圈状态
     * @param address 寄存器地址
     * @param value 读取的值
     * @return 读取是否成功
     */
    bool readCoil(int address, bool &value);
    
    /**
     * @brief 读取离散输入
     * @param address 寄存器地址
     * @param value 读取的值
     * @return 读取是否成功
     */
    bool readDiscreteInput(int address, bool &value);
    
    /**
     * @brief 读取保持寄存器
     * @param address 寄存器地址
     * @param value 读取的值
     * @return 读取是否成功
     */
    bool readHoldingRegister(int address, quint16 &value);
    
    /**
     * @brief 读取输入寄存器
     * @param address 寄存器地址
     * @param value 读取的值
     * @return 读取是否成功
     */
    bool readInputRegister(int address, quint16 &value);

    /**
     * @brief 写入线圈状态
     * @param address 寄存器地址
     * @param value 要写入的值
     * @return 写入是否成功
     */
    bool writeCoil(int address, bool value);
    
    /**
     * @brief 写入保持寄存器
     * @param address 寄存器地址
     * @param value 要写入的值
     * @return 写入是否成功
     */
    bool writeHoldingRegister(int address, quint16 value);

    // 批量操作
    /**
     * @brief 批量读取线圈状态
     * @param startAddress 起始地址
     * @param count 数量
     * @param values 读取的值
     * @return 读取是否成功
     */
    bool readCoils(int startAddress, int count, QVector<bool> &values);
    
    /**
     * @brief 批量读取线圈状态（别名）
     * @param startAddress 起始地址
     * @param count 数量
     * @param values 读取的值
     * @return 读取是否成功
     */
    bool readMultipleCoils(int startAddress, int count, QVector<bool> &values);
    
    /**
     * @brief 批量读取保持寄存器
     * @param startAddress 起始地址
     * @param count 数量
     * @param values 读取的值
     * @return 读取是否成功
     */
    bool readMultipleHoldingRegisters(int startAddress, int count, QVector<quint16> &values);
    
    /**
     * @brief 批量写入线圈状态
     * @param startAddress 起始地址
     * @param values 要写入的值
     * @return 写入是否成功
     */
    bool writeMultipleCoils(int startAddress, const QVector<bool> &values);
    
    /**
     * @brief 批量写入保持寄存器
     * @param startAddress 起始地址
     * @param values 要写入的值
     * @return 写入是否成功
     */
    bool writeMultipleHoldingRegisters(int startAddress, const QVector<quint16> &values);

    // 配置
    /**
     * @brief 设置重连间隔
     * @param interval 重连间隔（毫秒）
     */
    void setReconnectInterval(int interval);
    
    /**
     * @brief 设置响应超时
     * @param timeout 超时时间（毫秒）
     */
    void setResponseTimeout(int timeout);

signals:
    /**
     * @brief 连接成功信号
     */
    void connected();
    
    /**
     * @brief 断开连接信号
     */
    void disconnected();
    
    /**
     * @brief 连接错误信号
     * @param error 错误信息
     */
    void connectionError(const QString &error);
    
    /**
     * @brief 数据读取错误信号
     * @param error 错误信息
     */
    void dataReadError(const QString &error);
    
    /**
     * @brief 数据写入错误信号
     * @param error 错误信息
     */
    void dataWriteError(const QString &error);

private slots:
    /**
     * @brief 状态变化槽函数
     * @param state 新状态
     */
    void onStateChanged(QModbusDevice::State state);
    
    /**
     * @brief 错误发生槽函数
     * @param error 错误类型
     */
    void onErrorOccurred(QModbusDevice::Error error);
    
    /**
     * @brief 尝试重连槽函数
     */
    void attemptReconnect();

private:
    QModbusTcpClient *m_hyModbusClient; ///< Modbus TCP客户端
    QString m_hyIpAddress; ///< 设备IP地址
    int m_hyPort; ///< 设备端口号
    int m_hySlaveId; ///< 从站ID
    int m_hyReconnectInterval; ///< 重连间隔（毫秒）
    int m_hyResponseTimeout; ///< 响应超时（毫秒）
    QTimer *m_hyReconnectTimer; ///< 重连定时器
    bool m_hyAutoReconnect; ///< 是否自动重连
};

#endif // HYMODBUSTCPDRIVER_H
