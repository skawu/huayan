#include "modeloptimizer.h"
#include <Qt3DRender/QMesh>
#include <Qt3DRender/QMaterial>
#include <Qt3DExtras/QPhongMaterial>
#include <Qt3DRender/QTexture>
#include <Qt3DRender/QTextureImage>
#include <QVariantMap>

ModelOptimizer::ModelOptimizer(QObject *parent) : QObject(parent)
{}

ModelOptimizer::~ModelOptimizer()
{}

void ModelOptimizer::simplifyMesh(Qt3DCore::QEntity *meshEntity, float targetReduction)
{
    if (!meshEntity) {
        return;
    }

    emit optimizationStarted();

    // 计算原始复杂度
    int originalComplexity = calculateModelComplexity(meshEntity);
    m_stats.originalTriangleCount = originalComplexity;

    // 处理网格简化
    processMeshSimplification(meshEntity, targetReduction);

    // 计算优化后复杂度
    int optimizedComplexity = calculateModelComplexity(meshEntity);
    m_stats.optimizedTriangleCount = optimizedComplexity;

    emit optimizationFinished(originalComplexity, optimizedComplexity);
}

void ModelOptimizer::compressTextures(Qt3DCore::QEntity *modelEntity, int maxWidth, int maxHeight)
{
    if (!modelEntity) {
        return;
    }

    emit optimizationStarted();

    // 处理纹理压缩
    processTextureCompression(modelEntity, maxWidth, maxHeight);

    emit optimizationFinished(0, 0); // 纹理压缩不影响复杂度统计
}

void ModelOptimizer::mergeMeshes(Qt3DCore::QEntity *parentEntity)
{
    if (!parentEntity) {
        return;
    }

    // 注意：Qt3D内置不直接支持网格合并
    // 实际项目中需要实现网格合并逻辑
    // 这里仅作为接口预留
    qDebug() << "Merging meshes not implemented in Qt3D by default";
}

void ModelOptimizer::removeRedundantNodes(Qt3DCore::QEntity *parentEntity)
{
    if (!parentEntity) {
        return;
    }

    // 注意：Qt3D内置不直接支持冗余节点检测
    // 实际项目中需要实现冗余节点检测和移除逻辑
    // 这里仅作为接口预留
    qDebug() << "Removing redundant nodes not implemented in Qt3D by default";
}

int ModelOptimizer::calculateModelComplexity(Qt3DCore::QEntity *modelEntity)
{
    if (!modelEntity) {
        return 0;
    }

    return calculateMeshComplexity(modelEntity);
}

QVariantMap ModelOptimizer::getOptimizationStats() const
{
    QVariantMap stats;
    stats["originalMeshCount"] = m_stats.originalMeshCount;
    stats["optimizedMeshCount"] = m_stats.optimizedMeshCount;
    stats["originalTriangleCount"] = m_stats.originalTriangleCount;
    stats["optimizedTriangleCount"] = m_stats.optimizedTriangleCount;
    stats["originalTextureSize"] = m_stats.originalTextureSize;
    stats["optimizedTextureSize"] = m_stats.optimizedTextureSize;
    return stats;
}

int ModelOptimizer::calculateMeshComplexity(Qt3DCore::QEntity *entity)
{
    if (!entity) {
        return 0;
    }

    int complexity = 0;

    // 计算当前实体的复杂度
    for (auto component : entity->components()) {
        if (qobject_cast<Qt3DRender::QMesh *>(component)) {
            complexity += 100; // 简化计算，假设每个网格贡献100复杂度
            m_stats.originalMeshCount++;
        }
    }

    // 递归计算子实体的复杂度
    for (auto child : entity->children()) {
        if (auto childEntity = qobject_cast<Qt3DCore::QEntity *>(child)) {
            complexity += calculateMeshComplexity(childEntity);
        }
    }

    return complexity;
}

void ModelOptimizer::processMeshSimplification(Qt3DCore::QEntity *entity, float targetReduction)
{
    if (!entity) {
        return;
    }

    // 处理当前实体的网格
    for (auto component : entity->components()) {
        if (auto mesh = qobject_cast<Qt3DRender::QMesh *>(component)) {
            // 注意：Qt3D内置不直接支持网格简化
            // 实际项目中需要使用外部库如OpenMesh或MeshLab进行网格简化
            // 这里仅作为接口预留
            qDebug() << "Simplifying mesh with reduction factor:" << targetReduction;
            m_stats.optimizedMeshCount++;
        }
    }

    // 递归处理子实体
    for (auto child : entity->children()) {
        if (auto childEntity = qobject_cast<Qt3DCore::QEntity *>(child)) {
            processMeshSimplification(childEntity, targetReduction);
        }
    }
}

void ModelOptimizer::processTextureCompression(Qt3DCore::QEntity *entity, int maxWidth, int maxHeight)
{
    if (!entity) {
        return;
    }

    // 处理当前实体的材质和纹理
    for (auto component : entity->components()) {
        if (auto material = qobject_cast<Qt3DRender::QMaterial *>(component)) {
            // 注意：Qt3D内置不直接支持纹理压缩
            // 实际项目中需要实现纹理压缩逻辑
            // 这里仅作为接口预留
            qDebug() << "Compressing textures with max size:" << maxWidth << "x" << maxHeight;
        }
    }

    // 递归处理子实体
    for (auto child : entity->children()) {
        if (auto childEntity = qobject_cast<Qt3DCore::QEntity *>(child)) {
            processTextureCompression(childEntity, maxWidth, maxHeight);
        }
    }
}
