import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ToolBar {
    id: root
    position: ToolBar.Header

    RowLayout {
        id: headerRow
        width: parent.width

        RowLayout {
            id: headerRowLeft
            Layout.alignment: Qt.AlignLeft
            ToolButton {
                action: openAction
            }
        }

        RowLayout {
            id: headerRowCenter
            Layout.alignment: Qt.AlignCenter
        }

        RowLayout {
            id: headerRowRight
            Layout.alignment: Qt.AlignRight

            ToolButton {
                text: qsTr("Playlist")
                onClicked: (playList.state == "hidden" )
            }

            ToolButton {
                action: appQuitAction
            }
        }
    }
}
