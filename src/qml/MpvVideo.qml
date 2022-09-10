import QtQuick 2.12
import QtQuick.Window 2.12
import mpv 1.0
import Application 1.0

MpvObject {
    id: root

    anchors.fill: parent

    onReady: {
        // 打开上次播放的文件，暂停并在播放器关闭或上次保存时的位置
        window.openFile(settings.lastPlayedFile, false, true)
        root.setProperty("start", "+" + settings.lastPlayedPosition)
    }
}
