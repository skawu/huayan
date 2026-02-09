#ifndef MODELOPTIMIZER_H
#define MODELOPTIMIZER_H

#include <QObject>
#include <Qt3DCore/QEntity>

class ModelOptimizer : public QObject
{
    Q_OBJECT

public:
    explicit ModelOptimizer(QObject *parent = nullptr);
    ~ModelOptimizer();

    // 简化网格
    Q_INVOKABLE void simplifyMesh(Qt3DCore::QEntity *meshEntity, float targetReduction = 0.5f);
    
    // 压缩纹理
    Q_INVOKABLE void compressTextures(Qt3DCore::QEntity *modelEntity, int maxWidth = 1024, int maxHeight = 1024);
    
    // 合并网格
    Q_INVOKABLE void mergeMeshes(Qt3DCore::QEntity *parentEntity);
    
    // 移除冗余节点
    Q_INVOKABLE void removeRedundantNodes(Qt3DCore::QEntity *parentEntity);
    
    // 计算模型复杂度
    Q_INVOKABLE int calculateModelComplexity(Qt3DCore::QEntity *modelEntity);
    
    // 获取优化统计信息
    Q_INVOKABLE QVariantMap getOptimizationStats() const;

signals:
    void optimizationStarted();
    void optimizationFinished(int originalComplexity, int optimizedComplexity);
    void progressUpdated(int progress);

private:
    // 优化统计信息
    struct OptimizationStats {
        int originalMeshCount = 0;
        int optimizedMeshCount = 0;
        int originalTriangleCount = 0;
        int optimizedTriangleCount = 0;
        int originalTextureSize = 0;
        int optimizedTextureSize = 0;
    };

    OptimizationStats m_stats;
    
    // 递归计算网格复杂度
    int calculateMeshComplexity(Qt3DCore::QEntity *entity);
    
    // 递归处理网格简化
    void processMeshSimplification(Qt3DCore::QEntity *entity, float targetReduction);
    
    // 递归处理纹理压缩
    void processTextureCompression(Qt3DCore::QEntity *entity, int maxWidth, int maxHeight);
};

#endif // MODELOPTIMIZER_H
