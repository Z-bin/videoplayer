import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Item {
    id: nav
    width: root.width * 0.3 - root.padding
    height: parent.height
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    Rectangle {
        width: 1
        height: parent.height
        anchors.right: parent.right
        color: systemPalette.dark
    }

    ColumnLayout {
        width: parent.width - root.padding
        Button {
            text: qsTr("General")
            Layout.fillWidth: true
            onClicked: {
                settingsViewLoader.sourceComponent = generalSettings
            }
        }

        Button {
            text: qsTr("Color Adjustments")
            Layout.fillWidth: true
            onClicked: {
                settingsViewLoader.sourceComponent = colorAdjustmentsSettings
            }
        }

        Button {
            text: qsTr("Mouse")
            Layout.fillWidth: true
            onClicked: {
                settingsViewLoader.sourceComponent = mouseSettings
            }
        }

        Button {
            text: qsTr("Playlist")
            Layout.fillWidth: true
            onClicked: {
                settingsViewLoader.sourceComponent = playlistSettings
            }
        }
    }
}
