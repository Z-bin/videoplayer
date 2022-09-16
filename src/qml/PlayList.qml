import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12

Rectangle {
    id: root

    property int minWidth: 500
    property alias tableView: tableView

    height: parent.height
    width: (parent.width * 0.33) < minWidth ? minWidth : parent.width * 0.33
    x: parent.width

    onWidthChanged: {
        tableView.columnWidthProvider = function (column) { return tableView.columnWidths[column] }
    }

    TableView {
        id: tableView
        property var columnWidths: [40, parent.width - 130, 90]
        anchors.fill: parent
        clip: true
        columnSpacing: 1
        // 返回每列的宽度
        columnWidthProvider: function (column) { return columnWidths[column] }
        delegate: PlayListItem {}
        rowSpacing: 1
        model: videoListModel
        z: 20
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: playList
                x: parent.width
            }
        },
        State {
            name: "visible"
            PropertyChanges {
                target: playList
                x: parent.width - root.width
            }
        }
    ]

    transitions: Transition {
        PropertyAnimation { properties: "x"; easing.type: Easing.Linear; duration: 100 }
    }
}