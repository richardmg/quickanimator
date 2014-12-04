import QtQuick 2.0

PlayMenuRow {
    id: opacityMenu
    property bool guard: false

    function syncWithSelectedLayer() {
        if (!myApp.model.hasSelection)
            return
        guard = true
        x = myApp.model.selectedSprites[0].opacity * (parent.width - width)
        guard = false
    }

    function writeOpacityToKeyframes()
    {
        for (var i in myApp.model.selectedSprites) {
            var sprite = myApp.model.selectedSprites[i];
            var changes = {
                opacity: x / (parent.width - width)
            }
            sprite.updateKeyframe(myApp.model.time, changes, {propagate:!myApp.stage.timelinePlay});
        }
    }

    onIsCurrentChanged: syncWithSelectedLayer()
    onXChanged: if (!guard) writeOpacityToKeyframes()

    Connections {
        target: opacityMenu.isCurrent ? myApp.model : null
        onSelectedSpritesUpdated: opacityMenu.syncWithSelectedLayer()
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
                myApp.timelineFlickable.stagePlay = true;
        }
        onReleased: {
            myApp.model.recordsOpacity = false
            myApp.model.inLiveDrag = false
            if (myApp.stage.timelinePlay)
                myApp.timelineFlickable.stagePlay = false;
        }
    }

    Rectangle {
        width: 70
        height: parent.height
        color: "blue"
    }
}
