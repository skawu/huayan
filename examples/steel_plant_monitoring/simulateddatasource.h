#ifndef HYSIMULATEDDATASOURCE_H
#define HYSIMULATEDDATASOURCE_H

#include <QObject>
#include <QMap>
#include <QVariant>
#include <QTimer>

/**
 * @brief 华颜模拟数据源
 * 
 * 用于替代真实设备/数据库，生成模拟的工业数据
 * 确保示例在断网/无外部服务时可完整运行
 */
class HYSimulatedDataSource : public QObject
{
    Q_OBJECT

public:
    explicit HYSimulatedDataSource(QObject *parent = nullptr);
    ~HYSimulatedDataSource();

    // 方法
    Q_INVOKABLE void initialize();
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE QVariant readValue(const QString &address);
    Q_INVOKABLE bool writeValue(const QString &address, const QVariant &value);

    // 获取模拟数据
    QMap<QString, QVariant> getAllValues() const;

signals:
    // 信号
    void dataUpdated(const QString &address, const QVariant &value);

private slots:
    // 槽函数
    void updateData();

private:
    // 私有成员
    QMap<QString, QVariant> m_data;
    QTimer *m_updateTimer;
};

#endif // HYSIMULATEDDATASOURCE_H
