import QtQuick 2.12
import QtQuick.Window 2.12
import mpv 1.0
import Application 1.0

MpvObject {
    id: root

    property int mx
    property int my
    property alias scrollPositionTimer: scrollPositionTimer
    signal setSubtitle(int id)
    signal setAudio(int id)

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

    function setPlayListScrollPosition() {
        if (playList.tableView.rows <= 0) {
            return;
        }
        // 正在播放的索引列表
        var rowsAbove = videoList.getPlayingVideo();
        // 50 是行高，1 是行间距
        var scrollDistance = (rowsAbove * 50) + (rowsAbove * 1)
        var scrollAvailableDistance =
                ((playList.tableView.rows * 50) + (playList.tableView.rows * 1)) - mpv.height
        if (scrollDistance > scrollAvailableDistance) {
            if (scrollAvailableDistance < mpv.height) {
                playList.tableView.contentY = 0;
            } else {
                playList.tableView.contentY = scrollAvailableDistance
            }
        } else {
            playList.tableView.contentY = scrollDistance
        }
    }

    onSetSubtitle: {
        if (id !== -1) {
            mpv.setProperty("sid", id)
        } else {
            mpv.setProperty("sid", "no")
        }
    }

    onSetAudio: {
        mpv.setProperty("aid", id)
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
        window.positionChanged(settings.lastPlayedPosition)
        window.durationChanged(settings.lastPlayedDuration)
    }

    // 加载文件时获取章节
    onFileLoaded: {
        footer.progressBar.chapters = mpv.getProperty("chapter-list")
        header.audioTracks = mpv.getProperty("track-list").filter(track => track["type"] === "audio")
        header.subtitleTracks = mpv.getProperty("track-list").filter(track => track["type"] === "sub")
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
            footer.progressBar.value = position
            window.positionChanged(position)
        }
    }

    // 剩余播放时间
    onRemainingChanged: {
        window.remainingChanged(remaining)
    }

    // 待研究
    onEndOfFile: {
        var nextFileRow = videoList.getPlayingVideo() + 1
        if (nextFileRow < playList.tableView.rows) {
            var nextFile = videoList.getPath(nextFileRow)
            window.openFile(nextFile, true, false)
            videoList.setPlayingVideo(nextFileRow)
        }
    }

    // 滚动播放列表到播放加载的文件
    Timer {
        id: scrollPositionTimer
        interval: 50; running: true; repeat: true

        onTriggered: {
            setPlayListScrollPosition()
            scrollPositionTimer.stop()
        }
    }

    // 全屏化2000ms后隐藏鼠标
    Timer {
        id: hideCursorTimer

        property int tx: mx
        property int ty: my
        property int timeNotMoved: 0

        interval: 50; running: true; repeat: true

        onTriggered: {

            if (window.visibility !== Window.FullScreen) {
                return;
            }

            if (mx === tx && my === ty) {
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

        // 鼠标靠近右侧显示播放列表
        onMouseXChanged: {
            mpv.focus = true
            mx = mouseX
            if (mouseX > mpv.width - 50
                    && (mouseY < mpv.height * 0.8 && mouseY > mpv.height * 0.2) && playList.tableView.rows > 0) {
                playList.state = "visible"
            }
            if (mouseX < mpv.width - playList.width) {
                playList.state = "hidden"
            }
        }

        onMouseYChanged: {
            mpv.focus = true
            my = mouseY
            if (mouseY > window.height - footer.height && window.visibility === Window.FullScreen) {
                fullscreenFooter.visible = true
            } else if (mouseY < window.height - footer.height && window.visibility === Window.FullScreen) {
                fullscreenFooter.visible = false
            }
        }

        onClicked: {
            focus = true
            if (mouse.button === Qt.RightButton) {
                mpv.play_pause()
            }
        }

        onDoubleClicked: {
            if (mouse.button === Qt.LeftButton) {
                toggleFullScreen()
                setPlayListScrollPosition()
                app.showCursor()
            }
        }
    }
    DropArea {
        id: dropArea
        anchors.fill: parent
        keys: ["text/uri-list"]

        onDropped: {
            window.openFile(drop.urls[0], true, true)
        }
    }
}
