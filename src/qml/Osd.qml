import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    property alias timer: osdTimer
    property alias label: root

    Label {
        id: root
        x: 10
        y: 10
        visible: false
        background: Rectangle {
            color: systemPalette.base
        }
        text: ""
        padding: 5
    }

    Timer {
        id: osdTimer
        running: false
        repeat: false
        onTriggered: {
            root.visible = false
        }
    }
}
