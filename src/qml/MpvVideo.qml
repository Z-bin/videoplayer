import QtQuick 2.12
import QtQuick.Window 2.12
import mpv 1.0
import Application 1.0

MpvObject {
    id: root

    property int mx
    property int my

    // 双击全屏化事件
    function toggleFullScreen() {
        if (window.visibility !== Window.FullScreen) {
            window.visibility = Window.FullScreen
            header.visible = false
            footer.visible = false
            fullscreenFooter.visible = false
            footer.footerRow.parent = fullscreenFooter
        } else {
            window.visibility = window.preFullScreenVisibility
            header.visible = true
            footer.visible = true
            fullscreenFooter.visible = false
            footer.footerRow.parent = footer
        }
    }

    anchors.fill: parent

    onReady: {
        // 打开上次播放的文件，暂停并在播放器关闭或上次保存时的位置
        window.openFile(settings.lastPlayedFile, false, true)
        root.setProperty("start", "+" + settings.lastPlayedPosition)
        // 设置进度条位置
        footer.progressBar.from = 0
        footer.progressBar.to = settings.lastPlayedDuration
        footer.progressBar.value = settings.lastPlayedPosition;
    }

    onDurationChanged: {
        footer.progressBar.from = 0
        footer.progressBar.to = duration
        settings.lastPlayedDuration = duration

        window.durationChanged(duration)
    }

    onPositionChanged: {
        // 按下动作时候不处理
        if (!footer.progressBar.seekStarted) {
            console.debug("onPositionChanged")
            footer.progressBar.value = position
            window.positionChanged(position)
        }
    }

    // 待研究
    onEndOfFile: {
        var nextFileRow = videoList.getPlayingVideo() + 1
        if (nextFileRow < playList.tableView.rows) {
            var nextFile = playList.tableView.contentItem.children[nextFileRow].path
            window.openFile(nextFile, true, false)
            videoList.setPlayingVideo(nextFileRow)
        }
    }

    // 全屏化2000ms后隐藏鼠标
    Timer {
        id: hideCursorTimer

        property int tx: mx
        property int ty: my
        property int timeNotMoved: 0

        interval: 50; running: false; repeat: true

        onTriggered: {

            if (window.visibility !== Window.FullScreen) {
                return;
            }

            if (mx == tx && my == ty) {
                if (timeNotMoved > 2000) {
                    app.hideCursor()
                }
            } else {
                app.showCursor()
                timeNotMoved = 0
            }
            tx = mx
            ty = my
            timeNotMoved += interval
        }
    }

    MouseArea {
        id: mouseArea
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        hoverEnabled: true

        onEntered: hideCursorTimer.running = true

        onExited: hideCursorTimer.running = false

        onDoubleClicked: {
            if (mouse.button == Qt.LeftButton) {
                toggleFullScreen()
            }
        }
    }
}
