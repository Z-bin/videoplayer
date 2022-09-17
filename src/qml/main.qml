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

    onVisibilityChanged: {
        if (visibility != Window.FullScreen) {
            preFullScreenVisibility = visibility
        }
    }

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

    footer: Footer { id: footer }

    MpvVideo { id: mpv }

    PlayList { id: playList }

    // 页脚
    Rectangle {
        id: fullscreenFooter
        anchors.bottom: mpv.bottom
        width: window.width
        height: footer.height
        visible: false
        color: Qt.rgba(0.14, 0.15, 0.16, 0.8)
    }


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
        id: seekForwardAction
        text: seekForward.text
        shortcut: seekForward.shortcut
        icon.name: app.iconName(seekForward.icon)
        onTriggered: mpv.command(["seek", "+5"])
    }

    Action {
        id: seekBackwardAction
        text: seekBackward.text
        shortcut: seekBackward.shortcut
        icon.name: app.iconName(seekBackward.icon)
        onTriggered: mpv.command(["seek", "-5"])
    }

    Action {
        id: seekNextSubtitleAction
        text: seekNextSubtitle.text
        shortcut: seekNextSubtitle.shortcut
        icon.name: app.iconName(seekNextSubtitle.icon)
        onTriggered: mpv.command(["sub-seek", "1"])
    }
    Action {
        id: seekPrevSubtitleAction
        text: seekPreviousSubtitle.text
        shortcut: seekPreviousSubtitle.shortcut
        icon.name: app.iconName(seekPreviousSubtitle.icon)
        onTriggered: mpv.command(["sub-seek", "-1"])
    }

    Action {
        id: playPauseAction
        text: qsTr("Play/Pause")
        icon.name: "media-playback-pause"
        shortcut: "Space"
        onTriggered: mpv.play_pause()
    }

    Action {
        id: appQuitAction
        text: quitApplication.text
        icon.name: app.iconName(quitApplication.icon)
        shortcut: quitApplication.shortcut
        onTriggered: quitApplication.trigger()
    }
}
