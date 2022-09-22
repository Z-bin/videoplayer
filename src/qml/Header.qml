import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

ToolBar {
    id: root
    position: ToolBar.Header

    RowLayout {
        id: headerRow
        width: parent.width

        RowLayout {
            id: headerRowLeft
            Layout.alignment: Qt.AlignLeft
            ToolButton {
                icon.name: "document-open"
                text: qsTr("Open")

                onReleased: {
                    openMenu.open();
                    mpv.focus = true
                }

                Menu {
                    id: openMenu
                    y:  parent.height

                    MenuItem {
                        action: openAction
                    }

                    MenuItem {
                        action: openUrlAction
                    }

                }
            }

            ToolButton {
                icon.name: "media-view-subtitles-symbolic"
                text: qsTr("Subtitles")
                onClicked: {
                    subtitleMenuInstantiator.model = mpv.subtitleTracksModel()
                }

                onReleased: {
                    subtitleMenu.open()
                    mpv.focus = true
                }

                Menu {
                    id: subtitleMenu
                    y: parent.height

                    Instantiator {
                        id: subtitleMenuInstantiator
                        model: 0
                        onObjectAdded: subtitleMenu.insertItem( index, object )
                        onObjectRemoved: subtitleMenu.removeItem( object )
                        delegate: MenuItem {
                            id: subtitleMenuItem
                            checkable: true
                            checked: model.selected
                            text: `${model.language}: ${model.title} ${model.codec}`
                            onTriggered: {
                                mpv.setSubtitle(model.id, checked)
                                mpv.subtitleTracksModel().updateSelectedTrack(model.id)
                            }
                        }
                    }
                }
            }

            ToolButton {
                icon.name: "audio-volume-high"
                text: qsTr("Audio")
                onClicked: {
                    audioMenuInstantiator.model = mpv.audioTracksModel()
                }

                Menu {
                    id: audioMenu
                    y: parent.height

                    Instantiator {
                        id: audioMenuInstantiator
                        model: 0
                        onObjectAdded: audioMenu.insertItem( index, object )
                        onObjectRemoved: audioMenu.removeItem( object )
                        delegate: MenuItem {
                            id: audioMenuItem
                            checkable: true
                            checked: model.selected
                            text: `${model.language}: ${model.title} ${model.codec}`
                            onTriggered: {
                                mpv.setAudio(model.id)
                                mpv.audioTracksModel().updateSelectedTrack(model.id)
                            }
                        }
                    }
                }

                onReleased: audioMenu.open()
            }

        }

        RowLayout {
            id: headerRowCenter
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            id: headerRowRight
            Layout.alignment: Qt.AlignRight

            ToolButton {
                icon.name: "view-media-playlist"
                text: qsTr("Playlist")
                onClicked: (playList.state === "hidden") ? playList.state = "visible" : playList.state = "hidden"
            }

            ToolButton {
                action: appQuitAction
            }
        }
    }
}
