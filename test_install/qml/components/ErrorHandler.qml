import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Huayan.Core 1.0

/**
 * @qmltype ErrorHandler
 * @brief 错误处理和异常兜底组件
 * 
 * 用于在操作出错时提供可视化报错提示，并支持一键恢复默认配置
 */
Rectangle {
    id: errorHandler
    width: 400
    height: content.height + 20
    color: "#FFF8E1"
    border.color: "#FFC107"
    border.width: 2
    radius: 8
    visible: false
    z: 1000

    property string errorTitle: "操作错误"
    property string errorMessage: "发生了未知错误"
    property bool showRestoreButton: true

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 10

        RowLayout {
            Layout.fillWidth: true

            Image {
                id: errorIcon
                source: "qrc:/icons/alarm/warning.svg"
                width: 32
                height: 32
                Layout.alignment: Qt.AlignVCenter
            }

            Label {
                id: errorTitleLabel
                text: errorTitle
                font.bold: true
                font.pointSize: 14
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            Button {
                id: closeButton
                text: "×"
                font.pointSize: 16
                font.bold: true
                width: 30
                height: 30
                onClicked: errorHandler.visible = false
                style: ButtonStyle {
                    background: Rectangle {
                        color: "#FFC107"
                        border.color: "#FFA000"
                        radius: 15
                    }
                    label: Label {
                        text: control.text
                        color: "#FFFFFF"
                        font.bold: true
                        font.pointSize: 16
                    }
                }
            }
        }

        Label {
            id: errorMessageLabel
            text: errorMessage
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            Layout.topMargin: 10
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 15
            Layout.alignment: Qt.AlignRight

            Button {
                id: detailsButton
                text: "查看详情"
                onClicked: {
                    console.log("Error details:", errorMessage)
                    // 这里可以添加更详细的错误信息显示
                }
            }

            Button {
                id: restoreButton
                text: "恢复默认配置"
                visible: showRestoreButton
                enabled: ConfigManager.instance !== null
                onClicked: {
                    if (ConfigManager.instance) {
                        ConfigManager.instance.restoreDefaultConfig()
                        errorMessage = "默认配置已恢复，请重启应用程序以应用更改"
                        showRestoreButton = false
                    }
                }
                style: ButtonStyle {
                    background: Rectangle {
                        color: "#4CAF50"
                        border.color: "#45a049"
                        radius: 4
                    }
                    label: Label {
                        text: control.text
                        color: "#FFFFFF"
                    }
                }
            }
        }
    }

    /**
     * @brief 显示错误信息
     * @param title 错误标题
     * @param message 错误消息
     * @param showRestore 是否显示恢复按钮
     */
    function showError(title, message, showRestore = true) {
        errorTitle = title
        errorMessage = message
        showRestoreButton = showRestore
        visible = true
    }

    /**
     * @brief 隐藏错误信息
     */
    function hideError() {
        visible = false
    }
}
