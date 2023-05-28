import QtQuick 2.0
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.15

// 播放列表位置
Item {
    id: root;

    height: parent.height

    ColumnLayout {
        CheckBox {
            checked: settings.get("Playlist", "CanToogleWithMouse")
            text: qsTr("Toggle with mouse")
            onCheckStateChanged: {
                settings.set("Playlist", "CanToogleWithMouse", checked)
                playList.canToggleWithMouse = checked
            }
        }

        RowLayout {
            Label {
                text: qsTr("PlayList Position");
            }
            ComboBox {
                textRole: qsTr("key")
                Layout.fillWidth: true
                model: ListModel {
                    id: leftButtonModel
                    ListElement { key: "Left"; value: "left" }
                    ListElement { key: "Right"; value: "right" }
                }
                Component.onCompleted: {
                    for (var i = 0; i < model.count; ++i) {
                        if (model.get(i).value === settings.get("Playlist", "Position")) {
                            currentIndex = i
                            break
                        }
                    }
                }
                onActivated: {
                    settings.set("Playlist", "Position", model.get(index).value)
                    playList.position = model.get(index).value
                }
            }
        }
    }
}
