import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Item {
    id: threeDScene
    
    property string sceneName: "3D Scene"
    property int width: 800
    property int height: 600
    property real cameraDistance: 500
    property real cameraAzimuth: 45
    property real cameraElevation: 30
    property bool autoRotate: false
    property real autoRotateSpeed: 1
    
    // Three.js properties
    property var scene: null
    property var camera: null
    property var renderer: null
    property var controls: null
    property var animationId: null
    
    width: threeDScene.width
    height: threeDScene.height
    
    // Canvas for Three.js rendering
    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded
        
        Component.onCompleted: {
            initializeThreeJS();
        }
        
        function initializeThreeJS() {
            // Check if Three.js is loaded
            if (typeof THREE === 'undefined') {
                console.error("Three.js is not loaded. Please include Three.js library.");
                return;
            }
            
            // Create scene
            threeDScene.scene = new THREE.Scene();
            threeDScene.scene.background = new THREE.Color(0xf0f0f0);
            
            // Create camera
            threeDScene.camera = new THREE.PerspectiveCamera(75, canvas.width / canvas.height, 0.1, 10000);
            threeDScene.camera.position.set(0, 200, threeDScene.cameraDistance);
            
            // Create renderer
            threeDScene.renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
            threeDScene.renderer.setSize(canvas.width, canvas.height);
            threeDScene.renderer.setPixelRatio(window.devicePixelRatio);
            
            // Add renderer to canvas
            const canvasElement = document.getElementById(canvas.objectName);
            if (canvasElement) {
                // Clear any existing content
                while (canvasElement.firstChild) {
                    canvasElement.removeChild(canvasElement.firstChild);
                }
                canvasElement.appendChild(threeDScene.renderer.domElement);
            }
            
            // Add controls
            if (typeof THREE.OrbitControls !== 'undefined') {
                threeDScene.controls = new THREE.OrbitControls(threeDScene.camera, threeDScene.renderer.domElement);
                threeDScene.controls.enableDamping = true;
                threeDScene.controls.dampingFactor = 0.05;
                threeDScene.controls.screenSpacePanning = false;
                threeDScene.controls.minDistance = 100;
                threeDScene.controls.maxDistance = 1000;
                threeDScene.controls.minPolarAngle = 0;
                threeDScene.controls.maxPolarAngle = Math.PI / 2;
            }
            
            // Add lights
            addLights();
            
            // Add ground plane
            addGroundPlane();
            
            // Start animation
            animate();
        }
        
        function addLights() {
            // Ambient light
            const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
            threeDScene.scene.add(ambientLight);
            
            // Directional light
            const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
            directionalLight.position.set(1, 10, 1);
            threeDScene.scene.add(directionalLight);
            
            // Point light
            const pointLight = new THREE.PointLight(0xffffff, 1, 1000);
            pointLight.position.set(0, 500, 0);
            threeDScene.scene.add(pointLight);
        }
        
        function addGroundPlane() {
            // Create ground geometry
            const groundGeometry = new THREE.PlaneGeometry(1000, 1000);
            const groundMaterial = new THREE.MeshStandardMaterial({ 
                color: 0x888888,
                side: THREE.DoubleSide
            });
            const ground = new THREE.Mesh(groundGeometry, groundMaterial);
            ground.rotation.x = Math.PI / 2;
            ground.position.y = -50;
            threeDScene.scene.add(ground);
            
            // Create grid helper
            const gridHelper = new THREE.GridHelper(1000, 20);
            threeDScene.scene.add(gridHelper);
        }
        
        function animate() {
            threeDScene.animationId = requestAnimationFrame(animate);
            
            // Update controls
            if (threeDScene.controls) {
                threeDScene.controls.update();
            }
            
            // Auto rotate
            if (threeDScene.autoRotate) {
                threeDScene.scene.rotation.y += threeDScene.autoRotateSpeed * 0.01;
            }
            
            // Render scene
            if (threeDScene.renderer && threeDScene.scene && threeDScene.camera) {
                threeDScene.renderer.render(threeDScene.scene, threeDScene.camera);
            }
        }
        
        function resize() {
            if (threeDScene.camera && threeDScene.renderer) {
                threeDScene.camera.aspect = canvas.width / canvas.height;
                threeDScene.camera.updateProjectionMatrix();
                threeDScene.renderer.setSize(canvas.width, canvas.height);
            }
        }
        
        onWidthChanged: {
            resize();
        }
        
        onHeightChanged: {
            resize();
        }
    }
    
    // Add model to scene
    function addModel(modelPath, position, rotation, scale) {
        if (!threeDScene.scene) return null;
        
        // Use GLTFLoader to load models
        if (typeof THREE.GLTFLoader !== 'undefined') {
            const loader = new THREE.GLTFLoader();
            loader.load(
                modelPath,
                function (gltf) {
                    const model = gltf.scene;
                    
                    // Set position
                    if (position) {
                        model.position.set(position.x, position.y, position.z);
                    }
                    
                    // Set rotation
                    if (rotation) {
                        model.rotation.set(rotation.x, rotation.y, rotation.z);
                    }
                    
                    // Set scale
                    if (scale) {
                        model.scale.set(scale.x, scale.y, scale.z);
                    }
                    
                    threeDScene.scene.add(model);
                    console.log("Model loaded successfully:", modelPath);
                },
                function (xhr) {
                    console.log((xhr.loaded / xhr.total * 100) + '% loaded');
                },
                function (error) {
                    console.error('Error loading model:', error);
                }
            );
        } else {
            console.error("GLTFLoader is not available. Please include GLTFLoader.js");
        }
    }
    
    // Add primitive to scene
    function addPrimitive(type, parameters) {
        if (!threeDScene.scene) return null;
        
        let geometry, material, mesh;
        
        switch (type) {
            case "box":
                geometry = new THREE.BoxGeometry(parameters.width || 50, parameters.height || 50, parameters.depth || 50);
                break;
            case "sphere":
                geometry = new THREE.SphereGeometry(parameters.radius || 25, parameters.widthSegments || 32, parameters.heightSegments || 32);
                break;
            case "cylinder":
                geometry = new THREE.CylinderGeometry(parameters.radiusTop || 25, parameters.radiusBottom || 25, parameters.height || 50, parameters.radialSegments || 32);
                break;
            case "plane":
                geometry = new THREE.PlaneGeometry(parameters.width || 100, parameters.height || 100);
                break;
            default:
                console.error("Unknown primitive type:", type);
                return null;
        }
        
        material = new THREE.MeshStandardMaterial({
            color: parameters.color || 0x00ff00,
            metalness: parameters.metalness || 0.5,
            roughness: parameters.roughness || 0.5
        });
        
        mesh = new THREE.Mesh(geometry, material);
        
        // Set position
        if (parameters.position) {
            mesh.position.set(parameters.position.x, parameters.position.y, parameters.position.z);
        }
        
        // Set rotation
        if (parameters.rotation) {
            mesh.rotation.set(parameters.rotation.x, parameters.rotation.y, parameters.rotation.z);
        }
        
        // Set scale
        if (parameters.scale) {
            mesh.scale.set(parameters.scale.x, parameters.scale.y, parameters.scale.z);
        }
        
        threeDScene.scene.add(mesh);
        return mesh;
    }
    
    // Remove all objects from scene
    function clearScene() {
        if (!threeDScene.scene) return;
        
        while (threeDScene.scene.children.length > 0) {
            const object = threeDScene.scene.children[0];
            threeDScene.scene.remove(object);
            
            // Dispose geometry and material
            if (object.geometry) {
                object.geometry.dispose();
            }
            if (object.material) {
                if (Array.isArray(object.material)) {
                    object.material.forEach(material => material.dispose());
                } else {
                    object.material.dispose();
                }
            }
        }
        
        // Re-add lights and ground
        addLights();
        addGroundPlane();
    }
    
    // Set camera position
    function setCameraPosition(x, y, z) {
        if (threeDScene.camera) {
            threeDScene.camera.position.set(x, y, z);
            if (threeDScene.controls) {
                threeDScene.controls.update();
            }
        }
    }
    
    // Set camera target
    function setCameraTarget(x, y, z) {
        if (threeDScene.controls) {
            threeDScene.controls.target.set(x, y, z);
            threeDScene.controls.update();
        }
    }
    
    // Component cleanup
    Component.onDestruction: {
        if (threeDScene.animationId) {
            cancelAnimationFrame(threeDScene.animationId);
        }
        
        if (threeDScene.renderer) {
            threeDScene.renderer.dispose();
        }
        
        clearScene();
    }
}
