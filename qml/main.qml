import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    visible: true
//    visibility: Qt.Window
    width: 1500
    height: 600

    Component.onCompleted: width += 1

    property bool touchUI: Qt.platform.os === "ios"

    property alias stage: stage
    property alias playMenu: playMenu
    property alias timeFlickable: timeFlickable
    property alias searchView: searchView

    property TimelineMenu menu
    property Flickable timelineFlickable
    property Flickable layerTreeFlickable
    property FlickableMouseArea msPerFrameFlickable

    property Style style: Style {}
    property Model model: Model {}

    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true
        Component.onCompleted: forceActiveFocus()

        Keys.onReleased: {
            if (event.key === Qt.Key_P) {
                timeFlickable.userPlay = !timeFlickable.userPlay;
            } else if (event.key === Qt.Key_M) {
                menu.visible = !menu.visible
            } else if (event.key === Qt.Key_R) {
                menu.interactionPlayButton.checked = !menu.interactionPlayButton.checked;
            } else if (event.key === Qt.Key_S) {
                searchView.visible = true
            } else if (event.key === Qt.Key_Left) {
                model.setTime(0);
            } else if (event.key === Qt.Key_Up) {
                model.setTime(Math.max(0, model.time - 50));
            } else if (event.key === Qt.Key_Down) {
                model.setTime(model.time + 50);
            } else if (event.key === Qt.Key_Escape) {
                searchView.visible = false;
            }
        }

        Stage {
            id: stage
            anchors.fill: parent
            mouseArea: flickable
        }

        TimelineCanvas {
            width: parent.width
            height: 15
        }

        TimelineFlickable {
            id: timeFlickable
            anchors.fill: parent
            flickable: model.hasSelection ? null : flickable
        }

        FlickableMouseArea {
            id: flickable
            anchors.fill: parent
            momentumRestX: timeFlickable.playing ? -1 : 0
        }

        PlayMenu {
            id: playMenu
            width: parent.width
            height: 70
            anchors.bottom: parent.bottom
            opacity: 0
            visible: opacity !== 0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Connections {
                target: flickable
                onReleased: {
                    if (clickCount == 2)
                       playMenu.opacity = !playMenu.opacity
                }
            }
        }

        TimelineMenu {
            id: menu
            visible: false
            anchors.fill: parent
        }

        SearchView {
            id: searchView
            anchors.fill: parent
            visible: false
        }

    }

    Component {
        id: stageSpriteComponent
        StageSprite {
            id: stageSprite
            model: myApp.model
            property alias image: image;
            width: image.width
            height: image.height
            Image {
                id: image
                onStatusChanged: {
                    if (status === Image.Ready) {
                        anchorX = width / 2;
                        anchorY = height / 2;
                        for (var j = 0; j < keyframes.length; ++j) {
                            var keyframe = keyframes[j];
                            keyframe.anchorX = anchorX;
                            keyframe.anchorY = anchorY;
                        }
                    }
                }
            }
        }
    }

    property int nextSpriteNr: 0

    function addImage(url)
    {
        var layer = {}
        layer.sprite = stageSpriteComponent.createObject(stage.sprites, {"objectName":"sprite " + nextSpriteNr++, "image.source":url});
        model.addLayer(layer);
    }
}
