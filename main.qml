import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    width: 1024
    height: 768

    property alias timeline: timeline
    property alias stage: stage
    property MainToolbar mainToolbar
    property alias keyframeInfo: keyframeInfo

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
            }

            // Sync the two timeline flickables:
            Binding {
                property Item t: timelineSprites.flickable
                target: t.moving ? null : t
                property: "contentY"
                value: myApp.timeline.timelineCanvas.flickable.contentY
            }

            Binding {
                property Item t: timeline.timelineCanvas.flickable
                target: t.moving ? null : t
                property: "contentY"
                value: timelineSprites.flickable.contentY
            }
        }
    }

    Component {
        id: stageSpriteComponent
        StageSprite {
            model: myApp.model
            Image {
                source: "dummy.jpeg"
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
