#ifndef HYDATAPROCESSOR_H
#define HYDATAPROCESSOR_H

#include <QObject>
#include <QTimer>
#include <QThread>
#include <QMutex>
#include <QMap>
#include <QString>
#include <QVariant>
#include <QDateTime>
#include <QSet>

class HYModbusTcpDriver;
class HYTagManager;
class HYTimeSeriesDatabase;

/**
 * @file dataprocessor.h
 * @brief 数据处理器类头文件
 * 
 * 此类实现了数据处理功能，包括数据采集、命令发送、标签与设备寄存器的映射等
 * 支持基于组件可见性的智能数据更新调度
 */

/**
 * @class HYDataProcessor
 * @brief 数据处理器类
 * 
 * 负责数据的采集、处理和发送，是系统的核心组件之一
 * 支持基于组件可见性的智能数据更新调度
 */
class HYDataProcessor : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param parent 父对象
     */
    explicit HYDataProcessor(QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~HYDataProcessor();

    // 初始化
    /**
     * @brief 初始化
     * @param driver Modbus TCP驱动
     * @param tagManager 标签管理器
     */
    void initialize(HYModbusTcpDriver *driver, HYTagManager *tagManager);

    // 数据采集
    /**
     * @brief 开始数据采集
     * @param interval 采集间隔（毫秒），默认1秒
     */
    void startDataCollection(int interval = 1000);
    
    /**
     * @brief 停止数据采集
     */
    void stopDataCollection();
    
    /**
     * @brief 设置采集间隔
     * @param interval 采集间隔（毫秒）
     */
    void setCollectionInterval(int interval);

    // 命令发送
    /**
     * @brief 发送命令
     * @param tagName 标签名称
     * @param value 命令值
     * @return 发送是否成功
     */
    bool sendCommand(const QString &tagName, const QVariant &value);

    // 标签-设备映射
    /**
     * @brief 将标签映射到设备寄存器
     * @param tagName 标签名称
     * @param registerAddress 寄存器地址
     * @param isHoldingRegister 是否为保持寄存器
     * @return 映射是否成功
     */
    bool mapTagToDeviceRegister(const QString &tagName, int registerAddress, bool isHoldingRegister = true);
    
    /**
     * @brief 解除标签与设备寄存器的映射
     * @param tagName 标签名称
     * @return 解除映射是否成功
     */
    bool unmapTagFromDeviceRegister(const QString &tagName);

    // 智能数据更新调度
    /**
     * @brief 添加可见标签
     * @param tagName 标签名称
     */
    void addVisibleTag(const QString &tagName);
    
    /**
     * @brief 移除可见标签
     * @param tagName 标签名称
     */
    void removeVisibleTag(const QString &tagName);
    
    /**
     * @brief 设置可见标签集合
     * @param tagNames 标签名称集合
     */
    void setVisibleTags(const QSet<QString> &tagNames);
    
    /**
     * @brief 设置可见标签的更新间隔
     * @param interval 更新间隔（毫秒）
     */
    void setVisibleUpdateInterval(int interval);
    
    /**
     * @brief 设置不可见标签的更新间隔
     * @param interval 更新间隔（毫秒）
     */
    void setHiddenUpdateInterval(int interval);

signals:
    /**
     * @brief 数据采集开始信号
     */
    void dataCollectionStarted();
    
    /**
     * @brief 数据采集停止信号
     */
    void dataCollectionStopped();
    
    /**
     * @brief 命令发送信号
     * @param tagName 标签名称
     * @param value 命令值
     * @param success 发送是否成功
     */
    void commandSent(const QString &tagName, const QVariant &value, bool success);

private slots:
    /**
     * @brief 采集数据槽函数
     */
    void collectData();
    
    /**
     * @brief 智能采集数据槽函数
     */
    void collectDataIntelligently();

private:
    // 标签-设备寄存器映射
    struct RegisterMapping {
        int address; ///< 寄存器地址
        bool isHoldingRegister; ///< 是否为保持寄存器
        QDateTime lastUpdateTime; ///< 最后更新时间
    };

    // 时间序列数据库方法
    /**
     * @brief 设置时间序列数据库
     * @param db 时间序列数据库
     */
    void setTimeSeriesDatabase(HYTimeSeriesDatabase *db);
    
    /**
     * @brief 存储历史数据
     * @param tagName 标签名称
     * @param value 标签值
     * @param timestamp 时间戳
     * @return 存储是否成功
     */
    bool storeHistoricalData(const QString &tagName, const QVariant &value, const QDateTime &timestamp = QDateTime::currentDateTime());
    
    /**
     * @brief 查询历史数据
     * @param tagName 标签名称
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param limit 限制数量
     * @return 历史数据
     */
    QMap<QDateTime, QVariant> queryHistoricalData(const QString &tagName, const QDateTime &startTime, const QDateTime &endTime, int limit = 1000);
    
    /**
     * @brief 检查标签是否需要更新
     * @param tagName 标签名称
     * @param mapping 寄存器映射
     * @return 是否需要更新
     */
    bool shouldUpdateTag(const QString &tagName, const RegisterMapping &mapping);

    HYModbusTcpDriver *m_hyModbusDriver; ///< Modbus TCP驱动
    HYTagManager *m_hyTagManager; ///< 标签管理器
    HYTimeSeriesDatabase *m_hyTimeSeriesDatabase; ///< 时间序列数据库
    QTimer *m_hyCollectionTimer; ///< 采集定时器
    int m_hyCollectionInterval; ///< 采集间隔
    int m_hyVisibleUpdateInterval; ///< 可见标签更新间隔
    int m_hyHiddenUpdateInterval; ///< 不可见标签更新间隔
    QMutex m_hyMutex; ///< 互斥锁
    QMap<QString, RegisterMapping> m_hyTagRegisterMappings; ///< 标签-寄存器映射表
    QSet<QString> m_hyVisibleTags; ///< 可见标签集合
};

#endif // HYDATAPROCESSOR_H
