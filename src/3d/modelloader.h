#ifndef MODELLOADER_H
#define MODELLOADER_H

#include <QObject>
#include <QUrl>
#include <Qt3DCore/QEntity>
#include <Qt3DRender/QMaterial>

class ModelLoader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit ModelLoader(QObject *parent = nullptr);
    ~ModelLoader();

    // 加载glTF模型
    Q_INVOKABLE Qt3DCore::QEntity *loadGltfModel(const QUrl &url, Qt3DCore::QEntity *parentEntity);
    
    // 加载OBJ模型
    Q_INVOKABLE Qt3DCore::QEntity *loadObjModel(const QUrl &url, Qt3DCore::QEntity *parentEntity);
    
    // 优化模型（面片简化）
    Q_INVOKABLE void optimizeModel(Qt3DCore::QEntity *modelEntity, float simplificationFactor = 0.5f);
    
    // 压缩纹理
    Q_INVOKABLE void compressTextures(Qt3DCore::QEntity *modelEntity, int maxTextureSize = 1024);
    
    // 获取模型大小
    Q_INVOKABLE qint64 calculateModelSize(Qt3DCore::QEntity *modelEntity);
    
    // 获取最后错误信息
    QString lastError() const;

signals:
    void lastErrorChanged();
    void modelLoaded(Qt3DCore::QEntity *modelEntity);
    void modelOptimized(Qt3DCore::QEntity *modelEntity, qint64 originalSize, qint64 optimizedSize);

private:
    void performModelReduction(Qt3DCore::QEntity *entity, float simplificationFactor);
    void performTextureCompression(Qt3DRender::QMaterial *material, int maxTextureSize);
    QString m_lastError;
};

#endif // MODELLOADER_H
