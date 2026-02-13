import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: modelLoader
    
    property string modelPath: ""
    property var position: ({ x: 0, y: 0, z: 0 })
    property var rotation: ({ x: 0, y: 0, z: 0 })
    property var scale: ({ x: 1, y: 1, z: 1 })
    property var scene: null
    property var loadedModel: null
    property bool loading: false
    property string error: ""
    
    // Load model
    function loadModel(path, sceneObj) {
        if (!sceneObj) {
            error = "No scene provided";
            return false;
        }
        
        modelPath = path;
        scene = sceneObj;
        loading = true;
        error = "";
        
        // Check if Three.js and GLTFLoader are available
        if (typeof THREE === 'undefined') {
            error = "Three.js is not loaded";
            loading = false;
            return false;
        }
        
        if (typeof THREE.GLTFLoader === 'undefined') {
            error = "GLTFLoader is not loaded";
            loading = false;
            return false;
        }
        
        // Create loader
        const loader = new THREE.GLTFLoader();
        
        // Load model
        loader.load(
            path,
            function (gltf) {
                // Clear previous model
                if (loadedModel) {
                    scene.remove(loadedModel);
                    disposeModel(loadedModel);
                }
                
                // Get model
                loadedModel = gltf.scene;
                
                // Set position
                if (position) {
                    loadedModel.position.set(position.x, position.y, position.z);
                }
                
                // Set rotation
                if (rotation) {
                    loadedModel.rotation.set(rotation.x, rotation.y, rotation.z);
                }
                
                // Set scale
                if (scale) {
                    loadedModel.scale.set(scale.x, scale.y, scale.z);
                }
                
                // Add to scene
                scene.add(loadedModel);
                
                loading = false;
                console.log("Model loaded successfully:", path);
            },
            function (xhr) {
                console.log((xhr.loaded / xhr.total * 100) + '% loaded');
            },
            function (err) {
                error = "Error loading model: " + err.message;
                loading = false;
                console.error(error);
            }
        );
        
        return true;
    }
    
    // Dispose model resources
    function disposeModel(model) {
        if (!model) return;
        
        model.traverse(function (object) {
            if (object.geometry) {
                object.geometry.dispose();
            }
            if (object.material) {
                if (Array.isArray(object.material)) {
                    object.material.forEach(function (material) {
                        material.dispose();
                    });
                } else {
                    object.material.dispose();
                }
            }
        });
    }
    
    // Remove model from scene
    function removeModel() {
        if (loadedModel && scene) {
            scene.remove(loadedModel);
            disposeModel(loadedModel);
            loadedModel = null;
        }
    }
    
    // Update model position
    function updatePosition(x, y, z) {
        if (loadedModel) {
            loadedModel.position.set(x, y, z);
            position = { x: x, y: y, z: z };
        }
    }
    
    // Update model rotation
    function updateRotation(x, y, z) {
        if (loadedModel) {
            loadedModel.rotation.set(x, y, z);
            rotation = { x: x, y: y, z: z };
        }
    }
    
    // Update model scale
    function updateScale(x, y, z) {
        if (loadedModel) {
            loadedModel.scale.set(x, y, z);
            scale = { x: x, y: y, z: z };
        }
    }
    
    // Get model bounding box
    function getBoundingBox() {
        if (!loadedModel) return null;
        
        const box = new THREE.Box3().setFromObject(loadedModel);
        return box;
    }
    
    // Get model center
    function getModelCenter() {
        if (!loadedModel) return null;
        
        const box = getBoundingBox();
        const center = new THREE.Vector3();
        box.getCenter(center);
        return center;
    }
    
    // Component cleanup
    Component.onDestruction: {
        removeModel();
    }
}
