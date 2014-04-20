import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    visible: true
    visibility: Qt.WindowFullScreen

    property alias stage: stage

    property Timeline timeline
    property Flickable timelineFlickable
    property Flickable layerTreeFlickable
    property FlickableMouseArea msPerFrameFlickable

    property Style style: Style {}
    property Model model: Model {}

    SplitView {
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: timeline.top

        KeyframeInfo {
            id: menu
            visible: false
            width: 300
            z: 1
        }

        Stage {
            id: stage
            Layout.fillWidth: true
        }
    }

    MultiTouchButton {
        id: menuButton
        anchors.bottom: parent.bottom
        height: timeline.height
        checkable: true
        onCheckedChanged: menu.visible = checked;

        Rectangle {
            width: 1
            height: parent.height
            anchors.right: parent.right
            color: myApp.style.timelineline
        }
    }

    Timeline {
        id: timeline
        anchors.bottom: parent.bottom
        anchors.left: menuButton.right
        anchors.right: parent.right
        height: 50

        FlickableMouseArea {
            id: msPerFrameFlickView
            anchors.fill: parent
            enabled: false
            onMomentumXChanged: myApp.model.msPerFrame = Math.max(16, myApp.model.msPerFrame - momentumX);
            Component.onCompleted: myApp.msPerFrameFlickable = msPerFrameFlickView
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
