import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    visible: true
    visibility: Qt.WindowFullScreen

    property alias stage: stage
    property alias keyframeInfo: keyframeInfo
    property alias controlPanel: controlPanel;

    property Timeline timeline
    property Flickable timelineFlickable
    property Flickable layerTreeFlickable
    property FlickableMouseArea msPerFrameFlickable

    property Style style: Style {}
    property Model model: Model {}

    SplitView {
        orientation: Qt.Vertical
        anchors.fill: parent
        handleDelegate: SplitHandle {}

        SplitView {
            height: 2 * parent.height / 3
            width: parent.width
            handleDelegate: SplitHandle {}
            Layout.fillHeight: true

            KeyframeInfo {
                id: keyframeInfo
                width: parent.width / 3
                visible: false
            }

            Stage {
                id: stage
                clip: true
            }
        }

        SplitView {
            // Bottom left and bottom right
            width: parent.width
            handleDelegate: SplitHandle {}
            height: 200

            TimelineSprites {
                id: timelineSprites
                height: parent.height
                Component.onCompleted: width = controlPanel.width
            }

            Timeline {
                id: timeline
                width: parent.width / 3
                height: parent.height

                FlickableMouseArea {
                    id: msPerFrameFlickView
                    anchors.fill: parent
                    enabled: false
                    onMomentumXChanged: myApp.model.msPerFrame = Math.max(16, myApp.model.msPerFrame - momentumX);
                    Component.onCompleted: myApp.msPerFrameFlickable = msPerFrameFlickView
                }
            }

            // Sync the two timeline flickables:
//            Binding {
//                property Item t: layerTreeFlickable
//                target: t.moving ? null : t
//                property: "contentY"
//                value: timelineFlickable.contentY
//            }

//            Binding {
//                property Item t: timelineFlickable
//                target: t.moving ? null : t
//                property: "contentY"
//                value: layerTreeFlickable.contentY
//            }
        }
    }

    ControlPanel {
        id: controlPanel
        anchors.bottom: parent.bottom
    }

    Component {
        id: stageSpriteComponent
        StageSprite {
            model: myApp.model
            width: image.width
            height: image.height
            property alias image: image;
            Image { id: image }
        }
    }

    property int nextSpriteNr: 0

    function addImage(url)
    {
        var layer = {}
        layer.sprite = stageSpriteComponent.createObject(stage.sprites, {"objectName":"sprite " + nextSpriteNr++, "image.source":url});
        model.addLayer(layer);
        timelineSprites.model.append({});
    }
}
