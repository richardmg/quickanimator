import QtQuick 2.0

MenuRow {
    id: opacityMenu
    property bool guard: false

    function syncWithSelectedLayer() {
        if (!myApp.model.hasSelection)
            return
        guard = true
        x = myApp.model.selectedSprites[0].opacity * (parent.width - width)
        guard = false
    }

    onIsCurrentChanged: syncWithSelectedLayer()

    Connections {
        target: opacityMenu.isCurrent ? myApp.model : null
        onSelectedSpritesUpdated: opacityMenu.syncWithSelectedLayer()
    }

    onXChanged: {
        if (guard)
            return;
        for (var i in myApp.model.selectedSprites) {
            var sprite = myApp.model.selectedSprites[i];
            var changes = { opacity: x / (parent.width - width) }
            sprite.updateKeyframeSequence(myApp.model.time, changes);
        }
    }

    Connections {
        target: opacityMenu.isCurrent ? flickable : null
        onPressed: {
            myApp.model.recordsOpacity = true
            for (var i in myApp.model.selectedSprites) {
                var sprite = myApp.model.selectedSprites[i];
                var changes = { opacity: sprite.opacity }
                sprite.beginKeyframeSequence(myApp.model.time, changes);
            }
            myApp.timelineFlickable.recordPlay = myApp.model.recording;
        }
        onReleased: {
            myApp.model.recordsOpacity = false
            for (var i in myApp.model.selectedSprites) {
                var sprite = myApp.model.selectedSprites[i];
                var changes = { opacity: sprite.opacity }
                sprite.endKeyframeSequence(myApp.model.time, changes);
            }
            myApp.timelineFlickable.recordPlay = false;
        }
    }

    Rectangle {
        width: 70
        height: parent.height
        color: "blue"
    }
}
