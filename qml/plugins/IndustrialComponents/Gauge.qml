import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: gauge
    
    property real value: 0.5
    property real minValue: 0
    property real maxValue: 100
    property string label: "Gauge"
    property string unit: "%"
    property real threshold: 80
    property color backgroundColor: "#F5F5F5"
    property color needleColor: "#2196F3"
    property color textColor: "#333333"
    property color warningColor: "#FF9800"
    property color dangerColor: "#F44336"
    property color normalColor: "#4CAF50"
    
    width: 200
    height: 200
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: backgroundColor
        radius: width / 2
        border.color: "#E0E0E0"
        border.width: 2
    }
    
    // 刻度背景
    Canvas {
        id: scaleCanvas
        anchors.fill: parent
        anchors.margins: 20
        
        onPaint: {
            const ctx = getContext("2d");
            const centerX = width / 2;
            const centerY = height / 2;
            const radius = Math.min(centerX, centerY) - 10;
            
            // 清除画布
            ctx.clearRect(0, 0, width, height);
            
            // 绘制刻度
            ctx.lineWidth = 2;
            ctx.font = "12px Arial";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            
            // 绘制主要刻度
            for (let i = 0; i <= 10; i++) {
                const angle = Math.PI * 0.2 + Math.PI * 1.6 * (i / 10);
                const x1 = centerX + Math.cos(angle) * (radius - 10);
                const y1 = centerY + Math.sin(angle) * (radius - 10);
                const x2 = centerX + Math.cos(angle) * radius;
                const y2 = centerY + Math.sin(angle) * radius;
                
                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
                ctx.strokeStyle = "#666";
                ctx.stroke();
                
                // 绘制刻度值
                const value = minValue + (maxValue - minValue) * (i / 10);
                const textX = centerX + Math.cos(angle) * (radius - 25);
                const textY = centerY + Math.sin(angle) * (radius - 25);
                ctx.fillStyle = textColor;
                ctx.fillText(value.toFixed(0), textX, textY);
            }
            
            // 绘制次要刻度
            ctx.lineWidth = 1;
            for (let i = 0; i < 100; i++) {
                if (i % 10 !== 0) {
                    const angle = Math.PI * 0.2 + Math.PI * 1.6 * (i / 100);
                    const x1 = centerX + Math.cos(angle) * (radius - 5);
                    const y1 = centerY + Math.sin(angle) * (radius - 5);
                    const x2 = centerX + Math.cos(angle) * radius;
                    const y2 = centerY + Math.sin(angle) * radius;
                    
                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.strokeStyle = "#999";
                    ctx.stroke();
                }
            }
        }
    }
    
    // 指针
    Canvas {
        id: needleCanvas
        anchors.fill: parent
        anchors.margins: 20
        
        onPaint: {
            const ctx = getContext("2d");
            const centerX = width / 2;
            const centerY = height / 2;
            const radius = Math.min(centerX, centerY) - 10;
            
            // 清除画布
            ctx.clearRect(0, 0, width, height);
            
            // 计算指针角度
            const normalizedValue = Math.max(0, Math.min(1, (value - minValue) / (maxValue - minValue)));
            const angle = Math.PI * 0.2 + Math.PI * 1.6 * normalizedValue;
            
            // 绘制指针
            ctx.save();
            ctx.translate(centerX, centerY);
            ctx.rotate(angle);
            
            // 指针主体
            ctx.beginPath();
            ctx.moveTo(0, -5);
            ctx.lineTo(radius - 10, 0);
            ctx.lineTo(0, 5);
            ctx.closePath();
            ctx.fillStyle = needleColor;
            ctx.fill();
            ctx.strokeStyle = "#1976D2";
            ctx.lineWidth = 1;
            ctx.stroke();
            
            ctx.restore();
            
            // 绘制中心点
            ctx.beginPath();
            ctx.arc(centerX, centerY, 8, 0, Math.PI * 2);
            ctx.fillStyle = needleColor;
            ctx.fill();
            ctx.strokeStyle = "#1976D2";
            ctx.lineWidth = 2;
            ctx.stroke();
        }
        
        Connections {
            target: gauge
            function onValueChanged() {
                needleCanvas.requestPaint();
            }
        }
    }
    
    // 标签
    Text {
        id: labelText
        text: label
        font.pixelSize: 14
        font.bold: true
        color: textColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
    }
    
    // 数值显示
    Text {
        id: valueText
        text: value.toFixed(1) + unit
        font.pixelSize: 20
        font.bold: true
        color: {
            const normalizedValue = Math.max(0, Math.min(1, (value - minValue) / (maxValue - minValue)));
            if (normalizedValue > threshold / 100) {
                return dangerColor;
            } else if (normalizedValue > threshold / 100 * 0.8) {
                return warningColor;
            } else {
                return normalColor;
            }
        }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: labelText.top
        anchors.bottomMargin: 5
    }
}
