import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

// Subtitles Folders
Item {
    id: root

    property int _width
    // 避免重复创建空的items
    property bool canAddFolder: true

    Layout.columnSpan: 2
    Layout.fillWidth: true
    width: _width
    height: sectionTitle.height + sfListView.height + sfAddFolder.height + 25

    Label {
        id: sectionTitle
        color: systemPalette.text
        bottomPadding: 10
        text: "Subtitles folders"
    }

    ListView {
        id: sfListView
        property int sfDelegateHeight: 40
        property int rows: subsFoldersModel.rowCount()
        anchors.top: sectionTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: rows > 5
                ? 5 * sfListView.sfDelegateHeight + (sfListView.spacing * 4)
                : rows * sfListView.sfDelegateHeight + (sfListView.spacing * (rows - 1))
        spacing: 5
        clip: true  // 当元素的子项超出父项范围后会自动裁剪
        model: subsFoldersModel // 使用subsFoldersModel
        ScrollBar.vertical: ScrollBar { id: scrollBar}
        delegate: Rectangle {
            id: sfDelegate
            width: _width
            height: sfListView.sfDelegateHeight
            color: systemPalette.base

            Loader {
                id: sfLoader
                anchors.fill: parent
                sourceComponent: model.display === "" ? sfEditComponent : sfDisplayComponent
            }

            Component {
                id: sfDisplayComponent

                RowLayout {

                    Label {
                        id: sfLabel
                        text: model.display // 获取subsFoldersModel中data的DispalyRole数据
                        leftPadding: 10
                        Layout.fillWidth: true
                    }

                    Button {
                        icon.name: "edit-entry"
                        flat: true
                        onClicked: {
                            sfLoader.sourceComponent = sfEditComponent
                        }
                    }

                    Item { width: scrollBar.width }
                }
            } //显示

            Component {
                id: sfEditComponent

                RowLayout {

                    TextField {
                        id: editField
                        leftPadding: 10
                        text: model.display
                        Layout.leftMargin: 5
                        Layout.fillWidth: true
                        Component.onCompleted: editField.forceActiveFocus(Qt.MouseFocusReason)
                    }

                    Button {
                        property bool canDelete: editField.text === ""
                        icon.name: "delete"
                        flat: true
                        onClicked: {
                            // 两次确认删除
                            if (!canDelete) {
                                text = "Click again to delete"
                                canDelete = true
                                return
                            }

                            // 把最后一个删除后可以添加
                            if (model.row === subsFoldersModel.rowCount() - 1) {
                                root.canAddFolder = true
                            }
                            subsFoldersModel.deleteFolder(model.row)
                            var rows = subsFoldersModel.rowCount()
                            sfListView.height = rows > 5
                                    ? 5 * sfListView.sfDelegateHeight + (sfListView.spacing * 4)
                                    : rows * sfListView.sfDelegateHeight + (sfListView.spacing * (rows - 1))
                        }
                        ToolTip {
                            text: "Delete this folder from list"
                        }
                    }

                    Button {
                        icon.name: "dialog-ok"
                        flat: true
                        enabled: editField.text !== "" ? true : false
                        onClicked: {
                            subsFoldersModel.updateFolder(editField.text, model.row)
                            sfLoader.sourceComponent = sfDisplayComponent
                            if (model.row === subsFoldersModel.rowCount() - 1) {
                                root.canAddFolder = true
                            }
                        }
                        ToolTip {
                            text: "Save changes"
                        }
                    }

                    Item { width: scrollBar.width }
                }
            } // Component: edit
        }
    }

    Item {
        id: spacer
        anchors.top: sfListView.bottom
        height: 25
    }

    Button {
        id: sfAddFolder
        anchors.top: spacer.bottom
        icon.name: "list-add"
        text: "Add new folder"
        enabled: root.canAddFolder
        onClicked: {
            subsFoldersModel.addFolder()
            var rows = subsFoldersModel.rowCount()
            sfListView.height = rows > 5
                    ? 5 * sfListView.sfDelegateHeight + (sfListView.spacing * 4)
                    : rows * sfListView.sfDelegateHeight + (sfListView.spacing * (rows - 1))
            root.canAddFolder = false
        }
        ToolTip {
            text: "Add new subtitles folder to the list"
        }
    }
}
