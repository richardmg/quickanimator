import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    width: 1024
    height: 768

    property alias stage: stage
    property MainToolbar mainToolbar
    property Item timeline

    property Style style: Style {}
    property Model model: Model {}

    Stage {
        id: stage
        clip: true
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: mainToolbar.top
    }

    MainToolbar {
        id: mainToolbar
        Component.onCompleted: myApp.mainToolbar = mainToolbar
        anchors.bottom: parent.bottom
        width: parent.width
        height: 100
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

        //timelineSprites.model.append({});
    }
}
