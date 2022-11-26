import QtQuick 2.12
import QtQuick.Window 2.12
import mpv 1.0

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
            hSettings.state = "hidden"
            window.showFullScreen()
            header.visible = false
            footer.visible = false
            footer.anchors.bottom = root.bottom
            root.anchors.fill = root.parent
        } else {
            if (window.preFullScreenVisibility === Window.Windowed) {
                window.showNormal()
            }
            if (window.preFullScreenVisibility == Window.Maximized) {
                window.show()
                window.showMaximized()
            }
            header.visible = true
            footer.visible = true
            footer.anchors.bottom = undefined
            root.anchors.fill = undefined
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
                ((playList.tableView.rows * 50) + (playList.tableView.rows * 1)) - root.height
        if (scrollDistance > scrollAvailableDistance) {
            if (scrollAvailableDistance < root.height) {
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
            root.setProperty("sid", id)
        } else {
            root.setProperty("sid", "no")
        }
    }

    onSetAudio: {
        root.setProperty("aid", id)
    }

    width: parent.width
    height: parent.height - footer.height
    anchors.left: hSettings.right
    anchors.right: parent.right

    onReady: {
        root.setProperty("sub-file-paths", settings.getPath("General", "SubtitlesFolders").join(":"))

        footer.volume.value = settings.get("General", "volume")
        if (app.argument(0) !== "") {
            openFile(app.getPathFromArg(app.argument(0)), true, true);
        } else {
            // 打开上次播放的文件，暂停并在播放器关闭或上次保存时的位置
            window.openFile(settings.get("General", "lastPlayedFile"), false, true)
            root.setProperty("start", "+" + settings.get("General", "lastPlayedPosition"))
            // 设置进度条位置
            footer.progressBar.from = 0;
            footer.progressBar.to = settings.get("General", "lastPlayedDuration")
            footer.progressBar.value = settings.get("General", "lastPlayedPosition")

            footer.timeInfo.currentTime = mpv.formatTime(settings.get("General", "lastPlayedPosition"))
            footer.timeInfo.totalTime = mpv.formatTime(settings.get("General", "lastPlayedDuration"))
        }
    }

    // 加载文件时获取章节
    onFileLoaded: {
        footer.progressBar.chapters = root.getProperty("chapter-list")
        header.audioTracks = root.getProperty("track-list").filter(track => track["type"] === "audio")
        header.subtitleTracks = root.getProperty("track-list").filter(track => track["type"] === "sub")
    }

    onDurationChanged: {
        footer.progressBar.from = 0
        footer.progressBar.to = duration
        settings.set("General", "lastPlayedDuration", duration)

        footer.timeInfo.totalTime = mpv.formatTime(duration)
    }

    onPositionChanged: {
        // 按下动作时候不处理
        if (!footer.progressBar.seekStarted) {
            footer.progressBar.value = position
        }
        footer.timeInfo.currentTime = mpv.formatTime(position)
    }

    // 剩余播放时间
    onRemainingChanged: {
        footer.timeInfo.remainingTime = mpv.formatTime(remaining)
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

    onPauseChanged: {
        if (pause) {
            footer.playPauseButton.icon.name = "media-playback-start"
            lockManager.setInhibitionOff()
        } else {
            footer.playPauseButton.icon.name = "media-playback-pause"
            lockManager.setInhibitionOn()
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
            root.focus = true
            mx = mouseX
            if (mouseX > root.width - 50 && playList.tableView.rows > 0) {
                playList.state = "visible"
            }
            if (mouseX < root.width - playList.width) {
                playList.state = "hidden"
            }
        }

        onMouseYChanged: {
            root.focus = true
            my = mouseY
            if (mouseY > window.height - footer.height && window.visibility === Window.FullScreen) {
                footer.visible = true
            } else if (mouseY < window.height - footer.height && window.visibility === Window.FullScreen) {
                footer.visible = false
            }
        }

        onWheel: {
            var currentVolume = parseInt(mpv.getProperty("volume"))
            var volumeStep = parseInt(settings.get("General", "VolumeStep"))
            if (wheel.angleDelta.y > 0 && currentVolume < 100) {
                mpv.setProperty("volume", currentVolume + volumeStep)
            } else if (wheel.angleDelta.y < 0 && currentVolume >= 0) {
                mpv.setProperty("volume", currentVolume - volumeStep)
            }

            osd.message(`Volume: ${mpv.getProperty("volume").toFixed(0)}`)
        }

        onClicked: {
            focus = true
            if (mouse.button === Qt.RightButton) {
                root.play_pause()
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
