#ifndef DATASOURCE_H
#define DATASOURCE_H

#include <QObject>
#include <QVariant>
#include <QString>
#include <QMap>

#include "../core/tagmanager.h"

/**
 * @class DataSource
 * @brief 数据源接口类
 * 
 * 定义所有数据源都应该实现的方法，为协议扩展提供统一的接口
 * 支持不同工业协议的驱动插件实现
 */
class DataSource : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param tagManager 点位管理器指针
     * @param parent 父对象
     */
    explicit DataSource(HYTagManager *tagManager, QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    virtual ~DataSource();

    // 连接管理
    /**
     * @brief 连接到数据源
     * @param parameters 连接参数
     * @return 连接是否成功
     */
    virtual bool connect(const QMap<QString, QVariant> &parameters) = 0;
    
    /**
     * @brief 断开与数据源的连接
     */
    virtual void disconnect() = 0;
    
    /**
     * @brief 检查连接状态
     * @return 是否连接
     */
    virtual bool isConnected() const = 0;

    // 点位绑定
    /**
     * @brief 绑定数据源地址到Huayan点位
     * @param address 数据源地址
     * @param tagName Huayan点位名称
     * @param samplingInterval 采样间隔（毫秒）
     * @return 绑定是否成功
     */
    virtual bool bindAddressToTag(const QString &address, const QString &tagName, int samplingInterval = 100) = 0;
    
    /**
     * @brief 解除数据源地址与Huayan点位的绑定
     * @param address 数据源地址
     * @return 解除绑定是否成功
     */
    virtual bool unbindAddressFromTag(const QString &address) = 0;

    // 数据操作
    /**
     * @brief 读取数据
     * @param address 数据源地址
     * @return 读取的值
     */
    virtual QVariant readData(const QString &address) = 0;
    
    /**
     * @brief 写入数据
     * @param address 数据源地址
     * @param value 要写入的值
     * @return 写入是否成功
     */
    virtual bool writeData(const QString &address, const QVariant &value) = 0;

    // 数据源信息
    /**
     * @brief 获取数据源类型
     * @return 数据源类型
     */
    virtual QString type() const = 0;
    
    /**
     * @brief 获取数据源名称
     * @return 数据源名称
     */
    virtual QString name() const = 0;

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

protected:
    HYTagManager *m_tagManager; ///< 点位管理器指针
};

/**
 * @class DataSourceFactory
 * @brief 数据源工厂类
 * 
 * 用于创建不同类型的数据源实例
 */
class DataSourceFactory
{
public:
    /**
     * @brief 创建数据源实例
     * @param type 数据源类型
     * @param tagManager 点位管理器指针
     * @param parent 父对象
     * @return 数据源实例
     */
    static DataSource* createDataSource(const QString &type, HYTagManager *tagManager, QObject *parent = nullptr);
    
    /**
     * @brief 注册数据源类型
     * @param type 数据源类型
     * @param creator 数据源创建函数
     */
    static void registerDataSource(const QString &type, std::function<DataSource*(HYTagManager*, QObject*)> creator);
    
    /**
     * @brief 获取支持的数据源类型列表
     * @return 数据源类型列表
     */
    static QStringList supportedTypes();

private:
    static QMap<QString, std::function<DataSource*(HYTagManager*, QObject*)>> m_creators;
};

#endif // DATASOURCE_H
