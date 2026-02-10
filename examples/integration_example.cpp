#include <QCoreApplication>
#include <QDebug>
#include <QTimer>

// 包含项目的头文件
#include "core/tagmanager.h"
#include "core/dataprocessor.h"
#include "core/chartdatamodel.h"

// 集成示例类
class SCADASystemIntegration {
public:
    // 初始化SCADASystem集成
    void initialize() {
        qDebug() << "初始化SCADASystem集成...";
        
        // 初始化标签管理器
        tagManager = new TagManager();
        
        // 初始化数据处理器
        dataProcessor = new DataProcessor();
        
        // 初始化图表数据模型
        chartDataModel = new ChartDataModel();
        
        qDebug() << "SCADASystem集成初始化完成";
    }
    
    // 处理数据
    void processData() {
        qDebug() << "\n处理数据...";
        
        // 添加示例标签
        tagManager->addTag("Temperature", "AI", "模拟输入温度");
        tagManager->addTag("Pressure", "AI", "模拟输入压力");
        
        // 更新标签值
        tagManager->updateTagValue("Temperature", 85.5);
        tagManager->updateTagValue("Pressure", 2.5);
        
        // 处理数据
        QVariant processedTemp = dataProcessor->processData("Temperature", 85.5);
        QVariant processedPres = dataProcessor->processData("Pressure", 2.5);
        
        qDebug() << "处理后温度:" << processedTemp;
        qDebug() << "处理后压力:" << processedPres;
        
        // 添加图表数据
        chartDataModel->addDataPoint("Temperature", QDateTime::currentDateTime(), 85.5);
        chartDataModel->addDataPoint("Pressure", QDateTime::currentDateTime(), 2.5);
        
        qDebug() << "数据处理完成";
    }
    
    // 获取标签值
    QVariant getTagValue(const QString& tagName) {
        return tagManager->getTagValue(tagName);
    }
    
    // 清理资源
    void cleanup() {
        qDebug() << "清理SCADASystem集成资源...";
        
        delete tagManager;
        delete dataProcessor;
        delete chartDataModel;
        
        qDebug() << "SCADASystem集成资源清理完成";
    }
    
private:
    TagManager* tagManager;
    DataProcessor* dataProcessor;
    ChartDataModel* chartDataModel;
};

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    qDebug() << "=== SCADASystem 集成示例 ===";

    // 创建集成实例
    SCADASystemIntegration integration;
    
    // 初始化集成
    integration.initialize();
    
    // 处理数据
    integration.processData();
    
    // 获取标签值
    qDebug() << "\n获取标签值:";
    qDebug() << "温度值:" << integration.getTagValue("Temperature");
    qDebug() << "压力值:" << integration.getTagValue("Pressure");
    
    // 清理资源
    integration.cleanup();

    qDebug() << "\n=== SCADASystem 集成示例完成 ===";

    // 退出应用
    QTimer::singleShot(1000, &app, &QCoreApplication::quit);
    return app.exec();
}
