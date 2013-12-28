import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    width: 1024
    height: 768

    property alias stage: stage
    property MainToolbar mainToolbar
    property alias keyframeInfo: keyframeInfo

    property Timeline timeline
    property Flickable timelineFlickable
    property Flickable layerTreeFlickable
    property FlickableMouseArea msPerFrameFlickable

    property Style style: Style {}
    property Model model: Model {}

    SplitView {
        orientation: Qt.Vertical
        anchors.fill: parent
        handleDelegate: MainToolbar {
            id: mainToolbar
            Component.onCompleted: myApp.mainToolbar = mainToolbar
        }

        SplitView {
            height: 2 * parent.height / 3
            width: parent.width
            handleDelegate: SplitHandle {}
            KeyframeInfo {
                id: keyframeInfo
                width: parent.width / 3
                visible: false
                onWidthChanged: timelineSprites.width = width
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

            TimelineSprites {
                id: timelineSprites
                width: parent.width / 3
                height: parent.height
                onWidthChanged: keyframeInfo.width = width
            }

            Timeline {
                id: timeline
                width: 2 * parent.width / 3
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
            Binding {
                property Item t: layerTreeFlickable
                target: t.moving ? null : t
                property: "contentY"
                value: timelineFlickable.contentY
            }

            Binding {
                property Item t: timelineFlickable
                target: t.moving ? null : t
                property: "contentY"
                value: layerTreeFlickable.contentY
            }
        }
    }

    Component {
        id: stageSpriteComponent
        StageSprite {
            model: myApp.model
            width: image.width
            height: image.height
            Image {
                id: image
                source: "../dummy.jpeg"
            }
        }
    }

    property int nextSpriteNr: 0

    function addImage(url)
    {
        var layer = {}
        layer.sprite = stageSpriteComponent.createObject(stage.sprites)
        layer.name =  "sprite_" + nextSpriteNr++;
        model.addLayer(layer);
        timelineSprites.model.append({});
    }
}
