import QtQuick 2.1
import QtQuick.Controls 1.0

ApplicationWindow {
    id: myApp
    width: 1024
    height: 768

    property color accent: Qt.rgba(0.4, 0.4, 0.4, 1.0)
    property color text: Qt.darker(myApp.accent, 1.5)
    property int cellHeight: 30
    property alias timeline: timeline

    SplitView {
        orientation: Qt.Vertical
        anchors.fill: parent
        handleDelegate: SplitHandle {}

        SplitView {
            // Top left and top right
            width: parent.width
            height: 2 * parent.height / 3
            handleDelegate: SplitHandle {}
            SpriteTree {
                id: topLeft
                width: parent.width / 3
                height: parent.height
                onWidthChanged: timelineSprites.width = width
            }
            Stage {
                id: stage
                width: 2 * parent.width / 3
                height: parent.height
                clip: true
                timeline: timeline
            }
        }
        SplitView {
            // Bottom left and bottom right
            width: parent.width
            height: parent.height / 3
            handleDelegate: SplitHandle {}
            TimelineSprites {
                id: timelineSprites
                width: parent.width / 3
                height: parent.height
                onWidthChanged: topLeft.width = width
            }
            Timeline {
                id: timeline
                width: 2 * parent.width / 3
                height: parent.height
                Binding {
                    property Item t: timeline.timelineGrid.timelineList
                    target: t.moving ? null : t
                    property: "contentY"
                    value: timelineSprites.timelineList.contentY
                }
            }
        }
    }

    Component {
        id: stageSpriteComponent
        StageSprite {
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
        layer.sprite.name =  "sprite_" + nextSpriteNr++;
        timeline.addLayer(layer);
    }
}
