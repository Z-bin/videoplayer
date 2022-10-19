import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12
import QtQuick.Shapes 1.12
import QtGraphicalEffects 1.12

Slider {
    id: root

    from: 0
    to:   100
    implicitWidth: 100
    implicitHeight: 25
    wheelEnabled:  true
    stepSize: 2

    background: Rectangle {
        id: harunaSliderBG
        color: systemPalette.base

        Rectangle {
            color: systemPalette.highlight
            height: parent.height
            width: visualPosition * parent.width
        }
    }

    Label {
        id: progressBarToolTip
        text: root.value
        anchors.centerIn: root
        layer.enabled: true
        layer.effect: DropShadow { verticalOffset: 1; color: "#111"; radius: 5; spread: 0.3; samples: 17 }
    }

    onPressedChanged: {
        if (!pressed) {
            mpv.setProperty("volume", value.toFixed(0))
        }
    }
    onValueChanged: {
        mpv.setProperty("volume", value.toFixed(0))
        app.setSetting("General", "volume", value.toFixed(0))
    }

}
