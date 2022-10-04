import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12
import QtQuick.Shapes 1.12

Slider {
    id: root

    property var chapters
    property bool seekStarted: false
    property int seekValue: 0

    SystemPalette { id: systemPalette; colorGroup: SystemPalette.Active }

    background: Rectangle {
        id: progressBarSlider
        color: systemPalette.base
        implicitWidth: 200
        implicitHeight: 25
        height: implicitHeight
        radius: 0
        width: availableWidth
        x: leftPadding
        y: topPadding + availableHeight / 2 - height / 2

        //  进度条颜色
        Rectangle {
            color: systemPalette.highlight
            radius: 0
            height: parent.height
            width: visualPosition * parent.width
        }

        ToolTip {
            id: progressBarToolTip

            visible: false
            timeout: -1
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onMouseXChanged: {
                mouse.accepted = false
                progressBarToolTip.x = mouseX - (progressBarToolTip.width * 0.5)

                var time = mouseX * 100 / progressBarSlider.width * root.to / 100
                progressBarToolTip.text = mpv.formatTime(time)
            }

            onEntered: {
                progressBarToolTip.visible = true
                progressBarToolTip.x = mouseX - (progressBarToolTip.width * 0.5)
                progressBarToolTip.y = root.height
            }

            onExited: progressBarToolTip.visible = false
        }
    }

    Instantiator {
        id: chaptersInstantiator
        model: chapters
        delegate: Shape {
            id: chapterMarkerShape
            property int position: modelData.time * 100 / root.to * progressBarSlider.width / 100
            antialiasing: true
            parent: progressBarSlider
            ShapePath {
                strokeWidth: 1
                strokeColor: systemPalette.text
                startX: chapterMarkerShape.position
                startY: root.height
                fillColor: systemPalette.text
                PathLine { x: chapterMarkerShape.position; y: -1 }
                PathLine { x: chapterMarkerShape.position + 6; y: -7 }
                PathLine { x: chapterMarkerShape.position - 7; y: -7 }
                PathLine { x: chapterMarkerShape.position - 1; y: -1 }
            }
        }
    }

    // 拖动滑块
    handle: Rectangle {
        border.color: systemPalette.light
        color: systemPalette.light
        implicitWidth: 0
        implicitHeight: 35
        radius: 0
        x: leftPadding + visualPosition * (availableWidth - width)
        y: topPadding + availableHeight / 2 - height / 2
    }

    onValueChanged: {
        if (seekStarted) {
            seekValue = value
        }
        // 记录点击位置,下次打开有效
        app.setSetting("General", "lastPlayedPosition", value)
    }

    onPressedChanged: {
        if (pressed) {
            seekStarted = true
            seekValue = value
        } else {
            mpv.command(["seek", value, "absolute"])
            seekStarted = false
        }
    }
}
