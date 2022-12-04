import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Item {
    id: settingsView
    height: parent.height


    GridLayout {
        id: grid

        width: parent.width
        columns: 2

        // OSD 字体大小
        Label {
            color: systemPalette.text
            text:  qsTr("Osd font size")
            Layout.alignment: Qt.AlignRight
        }

        Item {
            height: osdFontSize.height
            SpinBox {
                id: osdFontSize
                editable: true
                from: 0
                to: 100
                value: settings.get("General", "OsdFontSize")
                onValueChanged: {
                    if (root.state === "visible") {
                        osd.label.font.pixelSize = osdFontSize.value
                        osd.message("Test osd font size")
                        settings.set("General", "OsdFontSize", osdFontSize.value)
                    }
                }
            }
            Layout.fillWidth: true
        }

        // 音量变化阶数
        Label {
            color: systemPalette.text
            text: "Volume step"
            Layout.alignment: Qt.AlignRight
        }

        Item {
            height: volumeStep.height
            SpinBox {
                id: volumeStep
                editable: true
                from: 0
                to: 100
                value: settings.get("General", "VolumeStep")
                onValueChanged: {
                    if (root.state === "visible") {
                        settings.set("General", "VolumeStep", volumeStep.value)
                    }
                }
            }
            Layout.fillWidth: true
        }

        // 分隔符
        ToolSeparator {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            orientation: Qt.Horizontal
            contentItem: Rectangle {
                implicitHeight: parent.vertical ? 24 : 1
                color: systemPalette.base
            }
        }

        // Seek Small Step
        Label {
            color: systemPalette.text
            text: "Seek Small Step"
            Layout.alignment: Qt.AlignRight
        }

        Item {
            height: seekSmallStep.height
            SpinBox {
                id: seekSmallStep
                editable: true
                from: 0
                to: 100
                value: settings.get("General", "SeekSmallStep")
                onValueChanged: {
                    if (root.state === "visible") {
                        settings.set("General", "SeekSmallStep", seekSmallStep.value)
                    }
                }
            }
            Layout.fillWidth: true
        }

        // Seek Medium Step
        Label {
            color: systemPalette.text
            text: "Seek Medium Step"
            Layout.alignment: Qt.AlignRight
        }

        Item {
            height: seekMediumStep.height
            SpinBox {
                id: seekMediumStep
                editable: true
                from: 0
                to: 100
                value: settings.get("General", "SeekMediumStep")
                onValueChanged: {
                    if (root.state === "visible") {
                        settings.set("General", "SeekMediumStep", seekMediumStep.value)
                    }
                }
            }
            Layout.fillWidth: true
        }

        // Seek Big Step
        Label {
            color: systemPalette.text
            text: "Seek Big Step"
            Layout.alignment: Qt.AlignRight
        }

        Item {
            height: seekBigStep.height
            SpinBox {
                id: seekBigStep
                editable: true
                from: 0
                to: 100
                value: settings.get("General", "SeekBigStep")
                onValueChanged: {
                    if (root.state === "visible") {
                        settings.set("General", "SeekBigStep", seekBigStep.value)
                    }
                }
            }
            Layout.fillWidth: true
        }

        ToolSeparator {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            orientation: Qt.Horizontal
            contentItem: Rectangle {
                implicitHeight: parent.vertical ? 24 : 1
                color: systemPalette.base
            }
        }

        SubtitlesFolders {
            id: subtitleFolders
            _width: grid.width
        }

        Item {
            Layout.columnSpan: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
