import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ToolBar {
    id: root

    property alias progressBar: progressBar
    property alias footerRow: footerRow
    property alias timeInfo: timeInfo
    property alias playPauseButton: playPauseButton
    property var playNext: app.action("playNext")
    property var playPrevious: app.action("playPrevious")

    contentHeight: 40
    contentWidth: window.width
    position: ToolBar.Footer


    RowLayout {
        id: footerRow
        anchors.fill: parent

        ToolButton {
            id: playPauseButton
            action: playPauseAction
            text: ""
            icon.name: "media-playback-start"
        }

        ToolButton {
            id: playPreviousFile
            action: playPreviousAction
            text: ""


            ToolTip {
                text: qsTr("Play Previous File")
            }
        }

        ToolButton {
            id: playNextFile
            action: playNextAction
            text: ""

            ToolTip {
                text: qsTr("Play Next File")
            }
        }

        VideoProgressBar {
            id: progressBar
            Layout.fillWidth: true
            rightPadding: 10
        }

        // 播放时间比
        Label {
            id: timeInfo
            property string totalTime
            property string currentTime
            property string remainingTime

            text: currentTime + " / " + totalTime

            // 播放剩余时间
            ToolTip {
                id: timeToolTip
                visible: false
                timeout: -1
                text: qsTr("Remaining: ") + timeInfo.remainingTime
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: timeToolTip.visible = true
                onExited: timeToolTip.visible = false
            }
        }

        Action {
            id: playNextAction
            text: playNext.text
            shortcut: playNext.shortcut
            icon.name: app.iconName(playNext.icon)
            onTriggered: {
                var nextFileRow = videoList.getPlayingVideo() + 1
                if (nextFileRow < playList.tableView.rows) {
                    var nextFile = videoList.getPath(nextFileRow)
                    window.openFile(nextFile, true, false)
                    videoList.setPlayingVideo(nextFileRow)
                }
            }
        }

        Action {
            id: playPreviousAction
            text: playPrevious.text
            shortcut: playPrevious.shortcut
            icon.name: app.iconName(playPrevious.icon)
            onTriggered: {
                if (videoList.getPlayingVideo() !== 0) {
                    var previousFileRow = videoList.getPlayingVideo() - 1
                    var nextFile = videoList.getPath(previousFileRow)
                    window.openFile(nextFile, true, false)
                    videoList.setPlayingVideo(previousFileRow)
                }
            }
        }
    }
}
