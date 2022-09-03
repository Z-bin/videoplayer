import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.12
import Qt.labs.settings 1.0

import Application 1.0

ApplicationWindow {
    id: window

    property var quitApplication: app.action("file_quit")

    visible: true
    title:  qsTr("Haruna")
    width: 1280
    height: 720

    header: Header { id: headr }

    PlayList { id: playList }


    FileDialog {
        id: fileDialog
        folder: shortcuts.movies // 指定打开的文件夹
        title: qsTr("Select file")
        selectMultiple: false    // 禁止选中多个文件
        onAccepted: {
//            op
        }
    }


    Action {
        id: openAction
        text: qsTr("Open File")
        icon.name: "document-open"
        shortcut: StandardKey.Open
        onTriggered: fileDialog.open()
    }

    Action {
        id: appQuitAction
        text: quitApplication.text
        icon.name: app.iconName(quitApplication.icon)
        shortcut: quitApplication.shortcut
        onTriggered: quitApplication.trigger()
    }
}
