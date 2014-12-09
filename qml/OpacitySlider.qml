import QtQuick 2.0

MenuRow {
    id: opacityMenu
    property bool guard: false
    property Item lastSprite: null

    unflickable: !myApp.model.hasSelection

    function syncWithSelectedLayer() {
        if (myApp.model.hasSelection) {
            var sprite = myApp.model.selectedSprites[0];
            lastSprite = sprite;
        } else {
            var useLast = myApp.model.sprites.indexOf(lastSprite) != -1;
            if (useLast)
                sprite = lastSprite;
        }
        if (!sprite)
            return
        guard = true
        x = sprite.opacity * (parent.width - width)
        guard = false
    }

    onIsCurrentChanged: syncWithSelectedLayer()

    Connections {
        target: isCurrent ? myApp.model : null
        onSelectedSpritesUpdated: syncWithSelectedLayer()
        onTimeChanged: syncWithSelectedLayer()
    }

    onXChanged: {
        if (guard)
            return;

        myApp.timeController.recordPlay = myApp.model.recording;
        for (var i in myApp.model.selectedSprites) {
            var sprite = myApp.model.selectedSprites[i];
            var changes = { opacity: x / (parent.width - width) }
            sprite.updateKeyframeSequence(myApp.model.time, changes);
        }
    }

    Connections {
        target: opacityMenu.isCurrent ? flickable : null
        onPressed: {
            beginRecordingTimer.restart();
            myApp.model.recordsOpacity = true;
            for (var i in myApp.model.selectedSprites) {
                var sprite = myApp.model.selectedSprites[i];
                var changes = { opacity: sprite.opacity }
                sprite.beginKeyframeSequence(myApp.model.time, changes);
            }
        }
        onReleased: {
            myApp.model.recordsOpacity = false
            for (var i in myApp.model.selectedSprites) {
                var sprite = myApp.model.selectedSprites[i];
                var changes = { opacity: sprite.opacity }
                sprite.endKeyframeSequence(myApp.model.time, changes);
            }
            myApp.timeController.recordPlay = false;
        }
    }

    Timer {
        id: beginRecordingTimer
        interval: 500
        onTriggered: myApp.timeController.recordPlay = myApp.model.recording;
    }

    Rectangle {
        width: 70
        height: parent.height
        color: unflickable ? "transparent" : border.color
        border.color: "blue"
        border.width: 4
    }
}
