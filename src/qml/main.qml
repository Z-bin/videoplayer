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

    Actions { id: actions }

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

    Osd {id: osd }

    SystemPalette { id: systemPalette; colorGroup: SystemPalette.Active }

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
        width: 500
        x: 10
        y: 10

        onOpened: {
            // 焦点强制为输入框
            openUrlTextField.forceActiveFocus(Qt.MouseFocusReason)
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
                        openUrlTextField.clear()
                        app.setSetting("General", "lastUrl", openUrlTextField.text)
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
                    openUrlTextField.clear()
                    app.setSetting("General", "lastUrl", openUrlTextField.text)
                }
            }
        }
    }
}
