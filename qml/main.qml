import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    visible: true
    visibility: Qt.WindowFullScreen

    property alias stage: stage
    property alias controlPanel: controlPanel;

    property Timeline timeline
    property Flickable timelineFlickable
    property Flickable layerTreeFlickable
    property FlickableMouseArea msPerFrameFlickable

    property Style style: Style {}
    property Model model: Model {}

    Stage {
        id: stage
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: bottomRow.top
    }

    Row {
        id: bottomRow
        width: parent.width
        height: childrenRect.height
        anchors.bottom: parent.bottom

        Rectangle {
            color: "red"
        }

        MultiTouchButton {
            id: recordButton
            text: ""
            onClicked: myApp.model.recording = !myApp.model.recording

            Rectangle {
                width: 1
                height: parent.height
                anchors.right: parent.right
                color: myApp.style.timelineline
            }

            Rectangle {
                width: 20
                height: 20
                radius: 20
                anchors.centerIn: parent
                color: myApp.model.recording ? "#ff0000" : "#550000"
            }
        }

        Timeline {
            id: timeline
            width: parent.width
            height: parent.height

            FlickableMouseArea {
                id: msPerFrameFlickView
                anchors.fill: parent
                enabled: false
                onMomentumXChanged: myApp.model.msPerFrame = Math.max(16, myApp.model.msPerFrame - momentumX);
                Component.onCompleted: myApp.msPerFrameFlickable = msPerFrameFlickView
            }
        }
    }

    ControlPanel {
        id: controlPanel
        y: 400
    }

    Component {
        id: stageSpriteComponent
        StageSprite {
            model: myApp.model
            property alias image: image;
            width: image.width
            height: image.height
            Image { id: image }
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
