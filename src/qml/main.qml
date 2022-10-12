import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.12
import Qt.labs.platform 1.0 as PlatformDialog

import mpv 1.0

ApplicationWindow {
    id: window

    property var quitApplication: app.action("file_quit")
    property var configureShortcuts: app.action("options_configure_keybinding")
    property var openUrl: app.action("openUrl")
    property var seekForward: app.action("seekForward")
    property var seekBackward: app.action("seekBackward")
    property var seekNextSubtitle: app.action("seekNextSubtitle")
    property var seekPreviousSubtitle: app.action("seekPreviousSubtitle")
    property var frameStep: app.action("frameStep")                         // 逐帧快进
    property var frameBackStep: app.action("frameBackStep")                 // 逐帧倒退
    property var increasePlayBackSpeed: app.action("increasePlayBackSpeed") // 增加播放速度
    property var decreasePlayBackSpeed: app.action("decreasePlayBackSpeed") // 减慢播放速度
    property var resetPlayBackSpeed: app.action("resetPlayBackSpeed")       // 重置播放速度
    property var configure: app.action("configure")

    property int preFullScreenVisibility

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

        app.setSetting("General", "lastPlayedFile", path)
    }

    visible: true
    title:  qsTr("Haruna")
    width: 1280
    height: 720

    // 记录全屏和正常化窗口状态
    onVisibilityChanged: {
        if (visibility != Window.FullScreen) {
            preFullScreenVisibility = visibility
        }
    }

    header: Header { id: headr }

    footer: Footer { id: footer }

    MpvVideo { id: mpv }

    PlayList { id: playList }

    // 页脚,作为全屏化的进度条背景
    Rectangle {
        id: fullscreenFooter
        anchors.bottom: mpv.bottom
        width: window.width
        height: footer.height
        visible: false
        color: "#31363B"
    }

    PlatformDialog.FileDialog {
        id: fileDialog
        folder: PlatformDialog.StandardPaths.writableLocation(PlatformDialog.StandardPaths.MoviesLocation) // 指定打开的文件夹
        title: qsTr("Select file")
        fileMode: PlatformDialog.FileDialog.OpenFile    // 禁止选中多个文件

        onAccepted: {
            openFile(fileDialog.file, true, true)
            // 加载表格视图行后，计时器将播放列表滚动到正在播放的文件
            mpv.scrollPositionTimer.start()
            mpv.focus = true
        }
        onRejected: mpv.focus = true
    }

    Popup {
        id: openUrlPopup
        anchors.centerIn: Overlay.overlay
        width: mpv.width * 0.7

        onOpened: {
            openUrlPopup.focus = true
            openUrlTextField.focus = true
            openUrlTextField.selectAll()
        }

        RowLayout {
            anchors.fill: parent
            TextField {
                id: openUrlTextField
                Layout.fillWidth: true

                Keys.onPressed: {
                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        openFile(openUrlTextField.text, true, false)
                        openUrlPopup.close()
                        app.setSetting("General", "lastUrl", openUrlTextField.text)
                        openUrlTextField.text = ""
                    }
                    if (event.key === Qt.Key_Escape) {
                        openUrlPopup.close()
                    }
                }
            }

            Button {
                id: openUrlButton
                text: qsTr("Open")

                onClicked: {
                    openFile(openUrlTextField.text, true, false)
                    openUrlPopup.close()
                    app.setSetting("General", "lastUrl", openUrlTextField.text)
                    openUrlTextField.text = ""
                }
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
        id: openUrlAction
        text: openUrl.text
        shortcut: openUrl.shortcut
        icon.name: app.iconName(openUrl.icon)
        onTriggered: openUrlPopup.open()
    }

    Action {
        id: seekForwardAction
        text: seekForward.text
        shortcut: seekForward.shortcut
        icon.name: app.iconName(seekForward.icon)
        onTriggered: mpv.command(["seek", "+5", "extract"])
    }

    Action {
        id: seekBackwardAction
        text: seekBackward.text
        shortcut: seekBackward.shortcut
        icon.name: app.iconName(seekBackward.icon)
        onTriggered: mpv.command(["seek", "-5", "exact"])
    }

    Action {
        id: seekNextSubtitleAction
        text: seekNextSubtitle.text
        shortcut: seekNextSubtitle.shortcut
        icon.name: app.iconName(seekNextSubtitle.icon)
        onTriggered: {
            if (mpv.getProperty("sid") !== false) {
                mpv.command(["sub-seek", "1"])
            } else {
                seekForwardAction.trigger()
            }
        }
    }
    Action {
        id: seekPrevSubtitleAction
        text: seekPreviousSubtitle.text
        shortcut: seekPreviousSubtitle.shortcut
        icon.name: app.iconName(seekPreviousSubtitle.icon)
        onTriggered: {
             if (mpv.getProperty("sid") !== false) {
                 mpv.command(["sub-seek", "-1"])
             } else {
                 seekBackwardAction.trigger()
             }
         }
    }

    Action {
        id: frameStepAction
        text: frameStep.text
        shortcut: frameStep.shortcut
        icon.name: app.iconName(frameStep.icon)
        onTriggered: mpv.command(["frame-step"])
    }

    Action {
        id: frameBackStepAction
        text: frameBackStep.text
        shortcut: frameBackStep.shortcut
        icon.name: app.iconName(frameBackStep.icon)
        onTriggered: mpv.command(["frame-back-step"])
    }

    Action {
        id: increasePlayBackSpeedAction
        text: increasePlayBackSpeed.text
        shortcut: increasePlayBackSpeed.shortcut
        icon.name: app.iconName(increasePlayBackSpeed.icon)
        onTriggered: mpv.setProperty("speed", mpv.getProperty("speed") + 0.1)
    }

    Action {
        id: decreasePlayBackSpeedAction
        text: decreasePlayBackSpeed.text
        shortcut: decreasePlayBackSpeed.shortcut
        icon.name: app.iconName(decreasePlayBackSpeed.icon)
        onTriggered: mpv.setProperty("speed", mpv.getProperty("speed") - 0.1)
    }

    Action {
        id: resetPlayBackSpeedAction
        text: resetPlayBackSpeed.text
        shortcut: resetPlayBackSpeed.shortcut
        icon.name: app.iconName(resetPlayBackSpeed.icon)
        onTriggered: mpv.setProperty("speed", 1.0)
    }

    Action {
        id: playPauseAction
        text: qsTr("Play/Pause")
        icon.name: "media-playback-pause"
        shortcut: "Space"
        onTriggered: mpv.play_pause()
    }

    Action {
        id: configureShortcutsAction
        text: configureShortcuts.text
        icon.name: app.iconName(configureShortcuts.icon)
        shortcut: configureShortcuts.shortcut
        onTriggered: configureShortcuts.trigger()
    }

    Action {
        id: appQuitAction
        text: quitApplication.text
        icon.name: app.iconName(quitApplication.icon)
        shortcut: quitApplication.shortcut
        onTriggered: quitApplication.trigger()
    }

    Action {
        id: configureAction
        text: configure.text
        icon.name: app.iconName(configure.icon)
        shortcut: configure.shortcut
        onTriggered: configure.trigger()
    }
}
