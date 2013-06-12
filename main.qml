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
                onWidthChanged: keyFrameInfo.width = width
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
            KeyFrameInfo {
                id: keyFrameInfo
                width: parent.width / 3
                height: parent.height
                onWidthChanged: spriteTree.width = width
            }
            Timeline {
                id: timeline
                width: 2 * parent.width / 3
                height: parent.height
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
