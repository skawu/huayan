import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: cameraController
    
    property var camera: null
    property var controls: null
    property var scene: null
    
    property real minDistance: 100
    property real maxDistance: 1000
    property real minPolarAngle: 0
    property real maxPolarAngle: Math.PI / 2
    property bool enableDamping: true
    property real dampingFactor: 0.05
    property bool screenSpacePanning: false
    property bool autoRotate: false
    property real autoRotateSpeed: 1
    
    // Camera control methods
    function initialize(cameraObj, rendererDomElement) {
        if (!cameraObj) {
            console.error("No camera provided");
            return false;
        }
        
        camera = cameraObj;
        
        // Check if OrbitControls is available
        if (typeof THREE === 'undefined' || typeof THREE.OrbitControls === 'undefined') {
            console.error("Three.js or OrbitControls is not loaded");
            return false;
        }
        
        // Create controls
        controls = new THREE.OrbitControls(camera, rendererDomElement);
        
        // Set control properties
        controls.minDistance = minDistance;
        controls.maxDistance = maxDistance;
        controls.minPolarAngle = minPolarAngle;
        controls.maxPolarAngle = maxPolarAngle;
        controls.enableDamping = enableDamping;
        controls.dampingFactor = dampingFactor;
        controls.screenSpacePanning = screenSpacePanning;
        controls.autoRotate = autoRotate;
        controls.autoRotateSpeed = autoRotateSpeed;
        
        return true;
    }
    
    // Update controls
    function update() {
        if (controls) {
            controls.update();
        }
    }
    
    // Set camera position
    function setPosition(x, y, z) {
        if (camera) {
            camera.position.set(x, y, z);
            update();
        }
    }
    
    // Set camera target
    function setTarget(x, y, z) {
        if (controls) {
            controls.target.set(x, y, z);
            update();
        }
    }
    
    // Set camera look at
    function lookAt(x, y, z) {
        if (camera) {
            camera.lookAt(x, y, z);
            update();
        }
    }
    
    // Zoom camera
    function zoom(distance) {
        if (controls) {
            controls.object.position.z -= distance;
            update();
        }
    }
    
    // Pan camera
    function pan(x, y) {
        if (controls) {
            controls.panOffset.set(x, y);
            update();
        }
    }
    
    // Rotate camera
    function rotate(theta, phi) {
        if (controls) {
            controls.theta += theta;
            controls.phi += phi;
            update();
        }
    }
    
    // Reset camera position
    function resetPosition() {
        if (camera) {
            camera.position.set(0, 200, 500);
            update();
        }
    }
    
    // Reset camera target
    function resetTarget() {
        if (controls) {
            controls.target.set(0, 0, 0);
            update();
        }
    }
    
    // Save camera state
    function saveState() {
        if (camera && controls) {
            return {
                position: {
                    x: camera.position.x,
                    y: camera.position.y,
                    z: camera.position.z
                },
                target: {
                    x: controls.target.x,
                    y: controls.target.y,
                    z: controls.target.z
                }
            };
        }
        return null;
    }
    
    // Load camera state
    function loadState(state) {
        if (state && camera && controls) {
            if (state.position) {
                setPosition(state.position.x, state.position.y, state.position.z);
            }
            if (state.target) {
                setTarget(state.target.x, state.target.y, state.target.z);
            }
        }
    }
    
    // Enable/disable controls
    function enable(enabled) {
        if (controls) {
            controls.enabled = enabled;
        }
    }
    
    // Enable/disable rotation
    function enableRotation(enabled) {
        if (controls) {
            controls.enableRotate = enabled;
        }
    }
    
    // Enable/disable zoom
    function enableZoom(enabled) {
        if (controls) {
            controls.enableZoom = enabled;
        }
    }
    
    // Enable/disable pan
    function enablePan(enabled) {
        if (controls) {
            controls.enablePan = enabled;
        }
    }
    
    // Component cleanup
    Component.onDestruction: {
        if (controls) {
            controls.dispose();
        }
    }
}
