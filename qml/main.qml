import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    visible: true
    visibility: Qt.WindowFullScreen

    property alias stage: stage
    property alias menuButton: menuButton

    property Timeline timeline
    property Flickable timelineFlickable
    property Flickable layerTreeFlickable
    property FlickableMouseArea msPerFrameFlickable

    property Style style: Style {}
    property Model model: Model {}

    FocusScope {
        focus: true
        Component.onCompleted: forceActiveFocus()
        property double keyPressTime: 0

        Keys.onPressed: {
            if (event.key === Qt.Key_Space) {
                if (keyPressTime === 0) {
                    keyPressTime = new Date().getTime()
                    timeline.userPlay = !timeline.userPlay;
                }
            } else if (event.modifiers & Qt.ControlModifier) {
                if (event.key === Qt.Key_M)
                    menuButton.checked = !menuButton.checked;
                else if (event.key === Qt.Key_A)
                    menu.interactionPlayButton.checked = !menu.interactionPlayButton.checked;
                else if (event.key === Qt.Key_G)
                    menu.googleButton.clicked();
                else if (event.key === Qt.Key_Left)
                    model.setTime(0);
            }
        }

        Keys.onReleased: {
            if (event.key === Qt.Key_Space) {
                if (keyPressTime + 200 < new Date().getTime())
                    timeline.userPlay = !timeline.userPlay;
                keyPressTime = 0;
            }
        }
    }

    SplitView {
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.bottom: bottomMenu.top

        TimelineMenu {
            id: menu
            visible: false
            width: 250
            height: parent.height
            z: 1
        }

        Stage {
            id: stage
            Layout.fillWidth: true
        }
    }

    RowLayout {
        id: bottomMenu
        width: parent.width
        height: 50
        anchors.bottom: parent.bottom
        spacing: 0

        MultiTouchButton {
            id: menuButton
            checkable: true
            onCheckedChanged: menu.visible = checked;
        }

        Timeline {
            id: timeline
            height: parent.height
            Layout.fillWidth: true
            FlickableMouseArea {
                id: msPerFrameFlickView
                anchors.fill: parent
                enabled: false
                onMomentumXChanged: myApp.model.msPerFrame = Math.max(16, myApp.model.msPerFrame - momentumX);
                Component.onCompleted: myApp.msPerFrameFlickable = msPerFrameFlickView
            }
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
                    if (status === Image.Ready)
                        stageSprite.resetSpriteAnchors();
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
