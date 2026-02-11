#include <QCoreApplication>
#include <QDebug>
#include <QTimer>
#include <QDateTime>

// 包含项目的头文件
#include "../src/core/hy_tagmanager.h"
#include "../src/core/hy_dataprocessor.h"
#include "../src/core/hy_chartdatamodel.h"
#include "../src/datasource/hy_modbusdatasource.h"

/**
 * @file api_usage_example.cpp
 * @brief Huayan SCADA系统API使用示例
 * 
 * 演示如何使用Huayan SCADA系统的核心API，包括：
 * - HYTagManager：标签管理
 * - HYDataProcessor：数据处理
 * - HYChartDataModel：图表数据模型
 * - HYModbusDataSource：Modbus通信
 */

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    qDebug() << "=== Huayan SCADA系统 API 使用示例 ===";

    // 1. 示例：使用HYTagManager管理标签
    qDebug() << "\n1. 使用HYTagManager管理标签:";
    HYTagManager hyTagManager;
    
    // 添加标签
    hyTagManager.addTag("Temperature", "AI", 0.0, "模拟输入温度", "AI");
    hyTagManager.addTag("Pressure", "AI", 0.0, "模拟输入压力", "AI");
    hyTagManager.addTag("Flow", "AI", 0.0, "模拟输入流量", "AI");
    hyTagManager.addTag("Motor1", "DO", false, "数字输出电机1", "DO");
    
    // 获取标签列表
    QVector<HYTag *> hyTags = hyTagManager.getTags();
    qDebug() << "标签列表数量:" << hyTags.size();
    for (const auto &tag : hyTags) {
        qDebug() << "标签名称:" << tag->name() << "，初始值:" << tag->value();
    }
    
    // 更新标签值
    hyTagManager.setTagValue("Temperature", 85.5);
    hyTagManager.setTagValue("Pressure", 2.5);
    hyTagManager.setTagValue("Flow", 120.0);
    hyTagManager.setTagValue("Motor1", true);
    
    // 获取标签值
    qDebug() << "温度值:" << hyTagManager.getTagValue("Temperature");
    qDebug() << "压力值:" << hyTagManager.getTagValue("Pressure");
    qDebug() << "流量值:" << hyTagManager.getTagValue("Flow");
    qDebug() << "电机1状态:" << hyTagManager.getTagValue("Motor1");

    // 2. 示例：使用HYDataProcessor处理数据
    qDebug() << "\n2. 使用HYDataProcessor处理数据:";
    HYDataProcessor hyDataProcessor(&hyTagManager);
    
    // 处理数据
    QVariant processedValue = hyDataProcessor.processData("Temperature", 85.5);
    qDebug() << "处理后的数据:" << processedValue;

    // 3. 示例：使用HYChartDataModel管理图表数据
    qDebug() << "\n3. 使用HYChartDataModel管理图表数据:";
    HYChartDataModel hyChartModel(&hyTagManager);
    
    // 添加数据点
    hyChartModel.addDataPoint("Temperature", QDateTime::currentDateTime(), 85.5);
    hyChartModel.addDataPoint("Temperature", QDateTime::currentDateTime().addSecs(60), 86.0);
    hyChartModel.addDataPoint("Temperature", QDateTime::currentDateTime().addSecs(120), 85.8);
    hyChartModel.addDataPoint("Temperature", QDateTime::currentDateTime().addSecs(180), 86.2);
    hyChartModel.addDataPoint("Temperature", QDateTime::currentDateTime().addSecs(240), 86.5);
    
    // 获取图表数据
    QVector<QPointF> chartData = hyChartModel.getChartData("Temperature");
    qDebug() << "图表数据点数量:" << chartData.size();

    // 4. 示例：使用HYModbusDataSource
    qDebug() << "\n4. 使用HYModbusDataSource:";
    HYModbusDataSource modbusSource(&hyTagManager);
    
    // 配置Modbus连接参数
    QMap<QString, QVariant> params;
    params["host"] = "192.168.1.100";
    params["port"] = 502;
    params["slaveId"] = 1;
    params["timeout"] = 1000; // 1秒超时
    params["retries"] = 3;    // 3次重试
    
    // 连接到设备
    bool connected = modbusSource.connect(params);
    qDebug() << "Modbus连接状态:" << connected;
    
    if (connected) {
        // 批量读取寄存器
        qDebug() << "\n4.1 批量读取寄存器:";
        
        // 读取多个保持寄存器
        QVector<QVariant> registerValues = modbusSource.batchReadData("holding:0-5");
        qDebug() << "读取保持寄存器0-5的值:";
        for (int i = 0; i < registerValues.size(); ++i) {
            qDebug() << "寄存器" << i << ":" << registerValues[i];
        }
        
        // 读取多个线圈
        QVector<QVariant> coilValues = modbusSource.batchReadData("coil:0-3");
        qDebug() << "读取线圈0-3的值:";
        for (int i = 0; i < coilValues.size(); ++i) {
            qDebug() << "线圈" << i << ":" << coilValues[i];
        }
        
        // 批量写入寄存器
        qDebug() << "\n4.2 批量写入寄存器:";
        
        // 批量写入保持寄存器
        QVector<QVariant> writeValues = {100, 200, 300};
        bool batchWritten = modbusSource.batchWriteData("holding:1-3", writeValues);
        qDebug() << "批量写入保持寄存器1-3的状态:" << batchWritten;
        
        // 批量写入线圈
        QVector<QVariant> coilWriteValues = {true, false, true};
        bool batchCoilWritten = modbusSource.batchWriteData("coil:1-3", coilWriteValues);
        qDebug() << "批量写入线圈1-3的状态:" << batchCoilWritten;
        
        // 断开连接
        modbusSource.disconnect();
        qDebug() << "Modbus连接已断开";
    } else {
        qDebug() << "Modbus连接失败，可能的原因:"
                 << "1. 设备IP地址错误"
                 << "2. 设备未通电或网络不可达"
                 << "3. 防火墙阻止了Modbus TCP流量"
                 << "4. 设备Modbus服务未运行";
    }

    // 5. 示例：Tag数据通知
    qDebug() << "\n5. Tag数据通知示例:";
    // 连接信号槽，监听标签值变化
    QObject::connect(&hyTagManager, &HYTagManager::tagValueChanged, [](const QString &tagName, const QVariant &value) {
        qDebug() << "标签值变化: " << tagName << " = " << value;
    });
    
    // 触发标签值变化
    hyTagManager.setTagValue("Temperature", 90.0);

    qDebug() << "\n=== API 使用示例完成 ===";

    // 退出应用
    QTimer::singleShot(1000, &app, &QCoreApplication::quit);
    return app.exec();
}
