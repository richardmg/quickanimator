import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property FlickableMouseArea flickable: null
    property alias sprites: sprites
    property var _prevState: null

    Connections {
        target: flickable

        onPressed: {
            // Record first keyframe on press'n'hold or position change
            if (stageShouldRecord())
                beginKeyframeSequenceTimer.restart()
        }

        onPositionChanged: {
            if (!_prevState) {
                if (beginKeyframeSequenceTimer.running)
                    beginKeyframeSequenceTimer.triggered()
                else
                    return;
            }

            var newState = createState(mouseX, mouseY);
            updateKeyframes(_prevState, newState, "updateKeyframeSequence");
            _prevState = newState;
        }

        onReleased: {
            if (_prevState) {
                var newState = createState(mouseX, mouseY);
                updateKeyframes(_prevState, newState, "endKeyframeSequence");
                _prevState = null;
                myApp.timeController.recordPlay = false;
            } else if (!myApp.timeController.playing) {
                beginKeyframeSequenceTimer.stop()
                selectOrUnselectSprites(mouseX, mouseY, clickCount)
            }
        }
    }

    Timer {
        id: beginKeyframeSequenceTimer
        interval: 500
        onTriggered: {
            stop()
            _prevState = createState(flickable.mouseX, flickable.mouseY);
            updateKeyframes(_prevState, _prevState, "beginKeyframeSequence");
            myApp.timeController.recordPlay = myApp.model.recording;
        }
    }

    Connections {
        target: myApp
        onFlickingChanged: {
            beginKeyframeSequenceTimer.stop()
            if (myApp.flicking && _prevState) {
                updateKeyframes(_prevState, _prevState, "endKeyframeSequence");
                _prevState = null;
            }
        }
    }

    Connections {
        target: myApp.model

        onSelectedSpritesUpdated: {
            beginKeyframeSequenceTimer.stop()
            if (_prevState) {
                updateKeyframes(_prevState, _prevState, "endKeyframeSequence");
                _prevState = null;
            }
            if (unselectedSprite != -1) {
                var sprite = myApp.model.sprites[unselectedSprite];
                sprite.focusIndicator.visible = false;
                sprite.focusIndicator.destroy();
                sprite.focusIndicator = null;
            }
            if (selectedSprite != -1) {
                sprite = myApp.model.sprites[selectedSprite];
                sprite.focusIndicator = focusIndicatorComponent.createObject(focusFrames);
                sprite.focusIndicator.target = sprite;
                sprite.focusIndicator.syncFocusPosition();
            }
        }
    }

    Rectangle {
        id: sprites
        anchors.fill: parent
        color: "white"
        objectName: "stage"
    }

    Item {
        id: focusFrames
        anchors.fill: sprites

        Rectangle {
            id: rotationCenterItem
            width: 5
            height: 5
            radius: width
            color: "red"
            visible: myApp.model.hasSelection && (myApp.model.recordsRotation || myApp.model.recordsScale)
            anchors.bottom: focusFrames.bottom
            anchors.right: focusFrames.right
            anchors.rightMargin: 100
            anchors.bottomMargin: 150
        }
    }

    function stageShouldRecord()
    {
        var m = myApp.model;
        return !myApp.flicking
                && m.hasSelection
                && (m.recordsPositionX
                || m.recordsPositionY
                || m.recordsScale
                || m.recordsRotation
                || m.recordsAnchorX
                || m.recordsAnchorY)
    }

    function createState(mouseX, mouseY)
    {
        var dx = mouseX - rotationCenterItem.x;
        var dy = rotationCenterItem.y - mouseY;
        return {
            x:mouseX,
            y:mouseY,
            angle: (Math.atan2(dx, dy) / Math.PI) * 180,
            radius: Math.sqrt(dx*dx + dy*dy)
        }
    }

    function selectOrUnselectSprites(mouseX, mouseY, clickCount)
    {
        var model = myApp.model;
        var sprite = getSpriteAtPos(mouseX, mouseY);

        if (clickCount === 1) {
            if (model.hasSelection) {
                for (var i = model.selectedSprites.length - 1; i >= 0; --i)
                    model.selectSprite(model.selectedSprites[i], false)
            } else if (sprite) {
                model.selectSprite(sprite, true);
            }
        } else if (clickCount === 2 && sprite) {
            model.selectSprite(sprite, true);
        }
    }

    function getSpriteAtPos(x, y)
    {
        for (var i = sprites.children.length - 1; i >= 0; --i) {
            var sprite = sprites.children[i];
            var m = sprite.mapFromItem(sprites, x, y);
            if (m.x >= 0 && m.x <= sprite.width && m.y >= 0 && m.y <= sprite.height)
                return sprite
        }
    }

    function updateKeyframes(_prevState, newState, call)
    {
        for (var i in myApp.model.selectedSprites) {
            var sprite = myApp.model.selectedSprites[i];
            var changes = new Object

            if (model.recordsPositionX || myApp.model.recordsPositionY) {
                var dx = newState.x - _prevState.x;
                var dy = newState.y - _prevState.y;
                var globalPos = sprites.mapFromItem(sprite.parent, sprite.x, sprite.y);
                var newSpritePos = sprites.mapToItem(sprite.parent, globalPos.x + dx, globalPos.y + dy);
                if (model.recordsPositionX)
                    changes.x = newSpritePos.x;
                if (model.recordsPositionY)
                    changes.y = newSpritePos.y;
            } else {
                if (myApp.model.recordsRotation) {
                    var a = newState.angle - _prevState.angle;
                    var b = a - 360;
                    var c = a + 360;
                    a = Math.abs(a) < Math.abs(b) ? a : b;
                    a = Math.abs(a) < Math.abs(c) ? a : c;
                    changes.transRotation = sprite.transRotation + a;
                }
                if (myApp.model.recordsScale) {
                    changes.transScaleX = sprite.transScaleX * (newState.radius / _prevState.radius);
                    changes.transScaleY = sprite.transScaleY * (newState.radius / _prevState.radius);
                }
            }

            sprite[call](myApp.model.time, changes);
        }
    }

    Component {
        id: focusIndicatorComponent
        Rectangle {
            id: focusIndicator
            property Item target: null
            width: 8
            height: width
            color: "transparent"

            Rectangle {
                anchors.centerIn: parent
                width: parent.height
                height: width
                color: "black"
                radius: width
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width -2
                    height: width
                    color: "white"
                    radius: width
                }
            }

            function syncFocusPosition()
            {
                var mapped = focusFrames.mapFromItem(target, target.anchorX, target.anchorY);
                focusIndicator.x = mapped.x - (width / 2);
                focusIndicator.y = mapped.y - (width / 2);
            }

            Connections {
                target: focusIndicator.target
                onXChanged: syncFocusPosition();
                onYChanged: syncFocusPosition();
                onAnchorXChanged: syncFocusPosition();
                onAnchorYChanged: syncFocusPosition();
                onParentChanged: syncFocusPosition();
            }
        }
    }

}

