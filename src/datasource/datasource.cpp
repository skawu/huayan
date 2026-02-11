#include "datasource.h"
#include <QDebug>

// 静态成员初始化
QMap<QString, std::function<DataSource*(HYTagManager*, QObject*)>> DataSourceFactory::m_creators;

/**
 * @brief DataSource构造函数
 * @param tagManager 点位管理器指针
 * @param parent 父对象
 */
DataSource::DataSource(HYTagManager *tagManager, QObject *parent)
    : QObject(parent),
      m_tagManager(tagManager)
{
}

/**
 * @brief DataSource析构函数
 */
DataSource::~DataSource()
{
}

/**
 * @brief 创建数据源实例
 * @param type 数据源类型
 * @param tagManager 点位管理器指针
 * @param parent 父对象
 * @return 数据源实例
 */
DataSource* DataSourceFactory::createDataSource(const QString &type, HYTagManager *tagManager, QObject *parent)
{
    if (m_creators.contains(type)) {
        return m_creators[type](tagManager, parent);
    } else {
        qWarning() << "不支持的数据源类型:" << type;
        return nullptr;
    }
}

/**
 * @brief 注册数据源类型
 * @param type 数据源类型
 * @param creator 数据源创建函数
 */
void DataSourceFactory::registerDataSource(const QString &type, std::function<DataSource*(HYTagManager*, QObject*)> creator)
{
    m_creators[type] = creator;
    qDebug() << "注册数据源类型:" << type;
}

/**
 * @brief 获取支持的数据源类型列表
 * @return 数据源类型列表
 */
QStringList DataSourceFactory::supportedTypes()
{
    return m_creators.keys();
}
