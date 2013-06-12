import QtQuick 2.1
import QtQuick.Controls 1.0

ApplicationWindow {
    id: myApp
    width: 1024
    height: 768

    property alias timeline: timeline
    property alias spriteTree: spriteTree

    SplitView {
        orientation: Qt.Vertical
        anchors.fill: parent

        SplitView {
            width: parent.width
            height: 2 * parent.height / 3
            SpriteTree {
                id: spriteTree
                width: parent.width / 3
                height: parent.height
                onWidthChanged: timelineList.width = width
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
            width: parent.width
            height: parent.height / 3
            TimelineList {
                id: timelineList
                model: 50
                width: parent.width / 3
                height: parent.height
                onWidthChanged: spriteTree.width = width
                
                Binding {
                    target: timelineList.moving ? null : timelineList
                    property: "contentY"
                    value: timeline.timelineGrid.timelineList.contentY
                }
            }
            Timeline {
                id: timeline
                width: 2 * parent.width / 3
                height: parent.height
                Binding {
                    property Item t: timeline.timelineGrid.timelineList
                    target: t.moving ? null : t
                    property: "contentY"
                    value: timelineList.contentY
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
