import QtQuick 2.0

PlayMenuRow {
    id: opacityMenu
    property bool guard: false

    function syncWithSelectedLayer() {
        if (!myApp.model.hasSelection)
            return
        guard = true
        x = myApp.model.selectedLayers[0].sprite.opacity * (parent.width - width)
        guard = false
    }

    function writeOpacityToKeyframes()
    {
        for (var i in myApp.model.selectedLayers) {
            var layer = myApp.model.selectedLayers[i];
            var keyframe = myApp.model.getOrCreateKeyframe(layer);
            var sprite = layer.sprite
            sprite.opacity = x / (parent.width - width)
            keyframe.opacity = sprite.opacity
        }
    }

    onIsCurrentChanged: syncWithSelectedLayer()
    onXChanged: if (!guard) writeOpacityToKeyframes()

    Connections {
        target: opacityMenu.isCurrent ? myApp.model : null
        onSelectedLayersUpdated: opacityMenu.syncWithSelectedLayer()
        onTimeChanged: {
            if (flickable.isPressed && myApp.stage.timelinePlay)
                opacityMenu.writeOpacityToKeyframes()
            else
                opacityMenu.syncWithSelectedLayer()
        }
    }

    Connections {
        target: opacityMenu.isCurrent ? flickable : null
        onPressed: {
            myApp.model.recordsOpacity = true
            myApp.model.inLiveDrag = true
            if (myApp.stage.timelinePlay)
                myApp.timeFlickable.stagePlay = true;
        }
        onReleased: {
            myApp.model.recordsOpacity = false
            myApp.model.inLiveDrag = false
            if (myApp.stage.timelinePlay)
                myApp.timeFlickable.stagePlay = false;
        }
    }

    Rectangle {
        width: 70
        height: parent.height
        color: "blue"
    }
}
