#include <QCoreApplication>
#include <QDebug>
#include <QTimer>

// 包含项目的头文件
#include "core/tagmanager.h"

// 扩展标签管理器类
class ExtendedTagManager : public TagManager {
public:
    // 构造函数
    ExtendedTagManager() : TagManager() {
        qDebug() << "创建扩展标签管理器";
    }
    
    // 扩展方法：批量添加标签
    void addTags(const QList<QString>& names, const QString& type, const QString& description) {
        qDebug() << "批量添加标签...";
        
        for (const QString& name : names) {
            addTag(name, type, description);
        }
        
        qDebug() << "批量添加标签完成，共添加" << names.size() << "个标签";
    }
    
    // 扩展方法：获取标签统计信息
    QMap<QString, int> getTagStatistics() {
        QMap<QString, int> statistics;
        
        QStringList tags = getTags();
        
        for (const QString& tag : tags) {
            QString type = getTagType(tag);
            statistics[type] = statistics.value(type, 0) + 1;
        }
        
        return statistics;
    }
    
    // 扩展方法：导出标签配置
    void exportTagConfiguration(const QString& filePath) {
        qDebug() << "导出标签配置到:" << filePath;
        
        // 这里可以实现导出标签配置到文件的逻辑
        // 例如导出为JSON、XML或CSV格式
        
        qDebug() << "标签配置导出完成";
    }
    
    // 扩展方法：导入标签配置
    void importTagConfiguration(const QString& filePath) {
        qDebug() << "从:" << filePath << "导入标签配置";
        
        // 这里可以实现从文件导入标签配置的逻辑
        // 例如导入JSON、XML或CSV格式的配置
        
        qDebug() << "标签配置导入完成";
    }
};

// 扩展数据源类
class CustomDataSource {
public:
    // 构造函数
    CustomDataSource() {
        qDebug() << "创建自定义数据源";
    }
    
    // 初始化数据源
    void initialize() {
        qDebug() << "初始化自定义数据源";
    }
    
    // 读取数据
    QVariant readData(const QString& address) {
        qDebug() << "读取地址" << address << "的数据";
        return QVariant(0.0);
    }
    
    // 写入数据
    bool writeData(const QString& address, const QVariant& value) {
        qDebug() << "向地址" << address << "写入数据:" << value;
        return true;
    }
    
    // 连接数据源
    bool connect() {
        qDebug() << "连接自定义数据源";
        return true;
    }
    
    // 断开数据源
    void disconnect() {
        qDebug() << "断开自定义数据源";
    }
};

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    qDebug() << "=== SCADASystem 扩展示例 ===";

    // 1. 示例：使用扩展标签管理器
    qDebug() << "\n1. 使用扩展标签管理器:";
    ExtendedTagManager extendedTagManager;
    
    // 批量添加标签
    QList<QString> tagNames = {"Temperature1", "Temperature2", "Pressure1", "Pressure2", "Flow1", "Flow2"};
    extendedTagManager.addTags(tagNames, "AI", "模拟输入");
    
    // 获取标签统计信息
    QMap<QString, int> statistics = extendedTagManager.getTagStatistics();
    qDebug() << "标签统计信息:";
    for (auto it = statistics.constBegin(); it != statistics.constEnd(); ++it) {
        qDebug() << it.key() << ":" << it.value() << "个";
    }
    
    // 导出标签配置
    extendedTagManager.exportTagConfiguration("tags_config.json");
    
    // 2. 示例：使用自定义数据源
    qDebug() << "\n2. 使用自定义数据源:";
    CustomDataSource customDataSource;
    
    // 初始化数据源
    customDataSource.initialize();
    
    // 连接数据源
    bool connected = customDataSource.connect();
    qDebug() << "数据源连接状态:" << connected;
    
    if (connected) {
        // 读取数据
        QVariant value = customDataSource.readData("0x0000");
        qDebug() << "读取数据:" << value;
        
        // 写入数据
        bool written = customDataSource.writeData("0x0001", 100);
        qDebug() << "写入数据状态:" << written;
        
        // 断开数据源
        customDataSource.disconnect();
    }

    qDebug() << "\n=== SCADASystem 扩展示例完成 ===";

    // 退出应用
    QTimer::singleShot(1000, &app, &QCoreApplication::quit);
    return app.exec();
}
