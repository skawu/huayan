#include <QCoreApplication>
#include <QDebug>
#include <QTimer>

// 包含项目的头文件
#include "core/tagmanager.h"
#include "core/dataprocessor.h"
#include "core/chartdatamodel.h"
#include "datasource/modbusdatasource.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    qDebug() << "=== SCADASystem API 使用示例 ===";

    // 1. 示例：使用TagManager管理标签
    qDebug() << "\n1. 使用TagManager管理标签:";
    TagManager tagManager;
    
    // 添加标签
    tagManager.addTag("Temperature", "AI", "模拟输入温度");
    tagManager.addTag("Pressure", "AI", "模拟输入压力");
    tagManager.addTag("Flow", "AI", "模拟输入流量");
    tagManager.addTag("Motor1", "DO", "数字输出电机1");
    
    // 获取标签列表
    QStringList tags = tagManager.getTags();
    qDebug() << "标签列表:" << tags;
    
    // 更新标签值
    tagManager.updateTagValue("Temperature", 85.5);
    tagManager.updateTagValue("Pressure", 2.5);
    tagManager.updateTagValue("Flow", 120.0);
    tagManager.updateTagValue("Motor1", true);
    
    // 获取标签值
    qDebug() << "温度值:" << tagManager.getTagValue("Temperature");
    qDebug() << "压力值:" << tagManager.getTagValue("Pressure");
    qDebug() << "流量值:" << tagManager.getTagValue("Flow");
    qDebug() << "电机1状态:" << tagManager.getTagValue("Motor1");

    // 2. 示例：使用DataProcessor处理数据
    qDebug() << "\n2. 使用DataProcessor处理数据:";
    DataProcessor dataProcessor;
    
    // 处理数据
    QVariant processedValue = dataProcessor.processData("Temperature", 85.5);
    qDebug() << "处理后的数据:" << processedValue;

    // 3. 示例：使用ChartDataModel管理图表数据
    qDebug() << "\n3. 使用ChartDataModel管理图表数据:";
    ChartDataModel chartModel;
    
    // 添加数据点
    chartModel.addDataPoint("Temperature", QDateTime::currentDateTime(), 85.5);
    chartModel.addDataPoint("Temperature", QDateTime::currentDateTime().addSecs(60), 86.0);
    chartModel.addDataPoint("Temperature", QDateTime::currentDateTime().addSecs(120), 85.8);
    chartModel.addDataPoint("Temperature", QDateTime::currentDateTime().addSecs(180), 86.2);
    chartModel.addDataPoint("Temperature", QDateTime::currentDateTime().addSecs(240), 86.5);
    
    // 获取图表数据
    QVector<QPointF> chartData = chartModel.getChartData("Temperature");
    qDebug() << "图表数据点数量:" << chartData.size();

    // 4. 示例：使用ModbusDataSource
    qDebug() << "\n4. 使用ModbusDataSource:";
    ModbusDataSource modbusSource;
    
    // 配置Modbus连接
    modbusSource.setHostName("192.168.1.100");
    modbusSource.setPort(502);
    modbusSource.setSlaveId(1);
    
    // 连接到设备
    bool connected = modbusSource.connect();
    qDebug() << "Modbus连接状态:" << connected;
    
    if (connected) {
        // 读取寄存器
        QVariant value = modbusSource.readRegister(0);
        qDebug() << "读取寄存器0的值:" << value;
        
        // 写入寄存器
        bool written = modbusSource.writeRegister(1, 100);
        qDebug() << "写入寄存器1的状态:" << written;
        
        // 断开连接
        modbusSource.disconnect();
    }

    qDebug() << "\n=== API 使用示例完成 ===";

    // 退出应用
    QTimer::singleShot(1000, &app, &QCoreApplication::quit);
    return app.exec();
}
