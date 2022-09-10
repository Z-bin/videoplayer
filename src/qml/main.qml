import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.12
import Qt.labs.settings 1.0

import mpv 1.0
import Application 1.0
import VideoPlayList 1.0

ApplicationWindow {
    id: window

    property var quitApplication: app.action("file_quit")
    property var configureShortcuts: app.action("options_configure_keybinding")
    property var seekForward: app.action("seekForward")
    property var seekBackward: app.action("seekBackward")
    property var seekNextSubtitle: app.action("seekNextSubtitle")
    property var seekPreviousSubtitle: app.action("seekPreviousSubtitle")
    property int preFullScreenVisibility

    signal setHovered(int row)
    signal removeHovered(int row)
    signal durationChanged(double duration)
    signal positionChanged(double position)

    function openFile(path, startPlayBack, loadSiblings) {
        mpv.loadFile(path)

        if (startPlayBack) {
            mpv.setProperty("pause", false)
        } else {
            mpv.setProperty("pause", true)
        }

        if (loadSiblings) {
            videoList.getVideos(path)
        }

        settings.lastPlayedFile = path
    }

    visible: true
    title:  qsTr("Haruna")
    width: 1280
    height: 720

    Settings {
        id: settings
        property string        lastPlayedFile
        property double        lastPlayedPosition
        property double        lastPlayedDuration
        property int           playingFilePosition
        property alias x:      window.x
        property alias y:      window.y
        property alias width:  window.width
        property alias height: window.height
    }

    header: Header { id: headr }

    MpvVideo { id: mpv }

    PlayList { id: playList }


    FileDialog {
        id: fileDialog
        folder: shortcuts.movies // 指定打开的文件夹
        title: qsTr("Select file")
        selectMultiple: false    // 禁止选中多个文件
        onAccepted: {
            onAccepted: {
                openFile(fileDialog.fileUrl, true, true)
                // 加载表格视图行后，计时器将播放列表滚动到正在播放的文件
                mpv.scrollPositionTimer.start()
            }
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
