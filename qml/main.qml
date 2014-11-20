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
    property alias timelineFlickable: timelineFlickable
    property alias searchView: searchView

    property TimelineMenu menu
    property Flickable layerTreeFlickable
    property FlickableMouseArea msPerFrameFlickable

    property Style style: Style {}
    property Model model: Model {}

    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true
        Component.onCompleted: forceActiveFocus()

        Keys.onPressed: {
            if (event.key === Qt.Key_Escape) {
                searchView.visible = false;
                return;
            }

            if (!(event.modifiers & Qt.ControlModifier))
                return;

            if (event.key === Qt.Key_P) {
                timelineFlickable.userPlay = !timelineFlickable.userPlay;
            } else if (event.key === Qt.Key_M) {
               menuToggleButton.clicked(1)
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
            }
        }

        Stage {
            id: stage
            anchors.fill: parent
            flickable: (menuToggleButton.pressed || flickable.touchCount > 1) ? null : flickable
        }

        TimelineCanvas {
            width: parent.width
            height: 15
            opacity: timelineFlickable.userPlay ? 0 : 1
            visible: opacity !== 0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        TimelineFlickable {
            id: timelineFlickable
            anchors.fill: parent
            flickable: (model.hasSelection && !menuToggleButton.pressed && flickable.touchCount < 2) ? null : flickable
        }

        FlickableMouseArea {
            id: flickable
            anchors.fill: parent
            momentumRestX: timelineFlickable.playing ? -1 : 0
        }

        PlayMenu {
            id: playMenu
            x: menuToggleButton.width
            width: parent.width - x
            height: 70
            clip: true
            anchors.bottom: parent.bottom
            opacity: 0
            visible: opacity !== 0
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Connections {
                target: model
                onHasSelectionChanged: playMenu.showMenuBasedOnContext()
            }

            function showMenuBasedOnContext()
            {
                if (model.hasSelection)
                    playMenu.showSpriteMenu();
                else
                    playMenu.showRootMenu();
            }
        }

        MultiTouchButton {
            id: menuToggleButton
            width: 70
            height: playMenu.height
            anchors.bottom: parent.bottom
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: 2
                border.color: Qt.rgba(0, 0, 1, 0.5)
                radius: 4
            }

            onClicked: {
                if (clickCount === 1) {
                    timelineFlickable.userPlay = false
                    if (!playMenu.visible)
                        playMenu.showMenuBasedOnContext()
                    playMenu.toggleMenuVisible()
                } else if (clickCount === 2) {
                    playMenu.showRootMenu()
                    playMenu.opacity = 1
                }
                opacity = 0
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
