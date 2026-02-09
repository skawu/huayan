#include "modelloader.h"
#include <Qt3DRender/QSceneLoader>
#include <Qt3DExtras/QPhongMaterial>
#include <Qt3DRender/QTexture>
#include <Qt3DRender/QTextureImage>
#include <Qt3DRender/QMesh>
#include <Qt3DCore/QComponent>
#include <Qt3DCore/QTransform>
#include <QFileInfo>

ModelLoader::ModelLoader(QObject *parent) : QObject(parent)
{}

ModelLoader::~ModelLoader()
{}

Qt3DCore::QEntity *ModelLoader::loadGltfModel(const QUrl &url, Qt3DCore::QEntity *parentEntity)
{
    if (!parentEntity) {
        m_lastError = "Parent entity is null";
        emit lastErrorChanged();
        return nullptr;
    }

    // 检查文件是否存在
    QFileInfo fileInfo(url.toLocalFile());
    if (!fileInfo.exists()) {
        m_lastError = "File does not exist: " + url.toString();
        emit lastErrorChanged();
        return nullptr;
    }

    // 创建场景加载器
    auto *sceneLoader = new Qt3DRender::QSceneLoader(parentEntity);
    sceneLoader->setSource(url);

    // 创建模型根实体
    auto *modelEntity = new Qt3DCore::QEntity(parentEntity);

    // 等待模型加载完成
    QObject::connect(sceneLoader, &Qt3DRender::QSceneLoader::statusChanged, this, [=](Qt3DRender::QSceneLoader::Status status) {
        if (status == Qt3DRender::QSceneLoader::Ready) {
            // 获取加载的实体
            QVector<Qt3DCore::QEntity *> entities = sceneLoader->entities();
            if (!entities.isEmpty()) {
                // 将加载的实体作为子实体添加到模型根实体
                for (auto entity : entities) {
                    entity->setParent(modelEntity);
                }
                emit modelLoaded(modelEntity);
            }
        } else if (status == Qt3DRender::QSceneLoader::Error) {
            m_lastError = "Failed to load glTF model";
            emit lastErrorChanged();
        }
    });

    return modelEntity;
}

Qt3DCore::QEntity *ModelLoader::loadObjModel(const QUrl &url, Qt3DCore::QEntity *parentEntity)
{
    if (!parentEntity) {
        m_lastError = "Parent entity is null";
        emit lastErrorChanged();
        return nullptr;
    }

    // 检查文件是否存在
    QFileInfo fileInfo(url.toLocalFile());
    if (!fileInfo.exists()) {
        m_lastError = "File does not exist: " + url.toString();
        emit lastErrorChanged();
        return nullptr;
    }

    // 创建OBJ模型实体
    auto *modelEntity = new Qt3DCore::QEntity(parentEntity);
    auto *mesh = new Qt3DRender::QMesh(modelEntity);
    mesh->setSource(url);

    // 创建默认材质
    auto *material = new Qt3DExtras::QPhongMaterial(modelEntity);
    modelEntity->addComponent(material);

    emit modelLoaded(modelEntity);
    return modelEntity;
}

void ModelLoader::optimizeModel(Qt3DCore::QEntity *modelEntity, float simplificationFactor)
{
    if (!modelEntity) {
        m_lastError = "Model entity is null";
        emit lastErrorChanged();
        return;
    }

    if (simplificationFactor <= 0.0f || simplificationFactor >= 1.0f) {
        m_lastError = "Simplification factor must be between 0.0 and 1.0";
        emit lastErrorChanged();
        return;
    }

    // 计算原始模型大小
    qint64 originalSize = calculateModelSize(modelEntity);

    // 执行模型简化
    performModelReduction(modelEntity, simplificationFactor);

    // 计算优化后模型大小
    qint64 optimizedSize = calculateModelSize(modelEntity);

    emit modelOptimized(modelEntity, originalSize, optimizedSize);
}

void ModelLoader::compressTextures(Qt3DCore::QEntity *modelEntity, int maxTextureSize)
{
    if (!modelEntity) {
        m_lastError = "Model entity is null";
        emit lastErrorChanged();
        return;
    }

    // 遍历所有子实体，压缩纹理
    QVector<Qt3DCore::QEntity *> entitiesToProcess = {modelEntity};
    while (!entitiesToProcess.isEmpty()) {
        Qt3DCore::QEntity *entity = entitiesToProcess.takeFirst();
        
        // 处理当前实体的材质
        for (auto component : entity->components()) {
            if (auto material = qobject_cast<Qt3DRender::QMaterial *>(component)) {
                performTextureCompression(material, maxTextureSize);
            }
        }
        
        // 添加子实体到处理队列
        entitiesToProcess += entity->children().toVector().cast<Qt3DCore::QEntity *>();
    }
}

qint64 ModelLoader::calculateModelSize(Qt3DCore::QEntity *modelEntity)
{
    if (!modelEntity) {
        return 0;
    }

    qint64 size = 0;

    // 遍历所有子实体，计算模型大小
    QVector<Qt3DCore::QEntity *> entitiesToProcess = {modelEntity};
    while (!entitiesToProcess.isEmpty()) {
        Qt3DCore::QEntity *entity = entitiesToProcess.takeFirst();
        
        // 计算网格大小
        for (auto component : entity->components()) {
            if (auto mesh = qobject_cast<Qt3DRender::QMesh *>(component)) {
                // 简化计算：假设每个三角形约占12字节（3个顶点，每个顶点4字节）
                // 实际项目中应根据具体网格数据结构计算
                size += 12 * 1000; // 估算值
            }
            
            // 计算材质和纹理大小
            if (auto material = qobject_cast<Qt3DRender::QMaterial *>(component)) {
                size += 1000; // 估算值
            }
        }
        
        // 添加子实体到处理队列
        entitiesToProcess += entity->children().toVector().cast<Qt3DCore::QEntity *>();
    }

    return size;
}

QString ModelLoader::lastError() const
{
    return m_lastError;
}

void ModelLoader::performModelReduction(Qt3DCore::QEntity *entity, float simplificationFactor)
{
    // 遍历所有子实体，执行面片简化
    QVector<Qt3DCore::QEntity *> entitiesToProcess = {entity};
    while (!entitiesToProcess.isEmpty()) {
        Qt3DCore::QEntity *currentEntity = entitiesToProcess.takeFirst();
        
        // 处理当前实体的网格
        for (auto component : currentEntity->components()) {
            if (auto mesh = qobject_cast<Qt3DRender::QMesh *>(component)) {
                // 注意：Qt3D内置不直接支持网格简化
                // 实际项目中需要使用外部库如OpenMesh或MeshLab进行网格简化
                // 这里仅作为接口预留
                qDebug() << "Performing mesh simplification with factor:" << simplificationFactor;
            }
        }
        
        // 添加子实体到处理队列
        entitiesToProcess += currentEntity->children().toVector().cast<Qt3DCore::QEntity *>();
    }
}

void ModelLoader::performTextureCompression(Qt3DRender::QMaterial *material, int maxTextureSize)
{
    // 注意：Qt3D内置不直接支持纹理压缩
    // 实际项目中需要实现纹理压缩逻辑
    // 这里仅作为接口预留
    qDebug() << "Performing texture compression with max size:" << maxTextureSize;
}
