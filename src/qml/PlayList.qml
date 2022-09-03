import QtQuick 2.12

Rectangle {
    id: root

    property int minWidth: 500
//    property alias tableview: tableView

    height: parent.height
    width: (parent.width * 0.33) < minWidth ? minWidth : parent.width * 0.33
    x: parent.width

    TableView {
        id: tableview
        anchors.fill: parent
        clip: true
        columnSpacing: 1
    }

}
