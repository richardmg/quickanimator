import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property FlickableMouseArea flickable: null

    property alias sprites: sprites

    property var pressStartPos: undefined
    property var currentAction: new Object()

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

    Connections {
        target: flickable

        function getAngleAndRadius(p1, p2)
        {
            var dx = p2.x - p1.x;
            var dy = p1.y - p2.y;
            return {
                angle: (Math.atan2(dx, dy) / Math.PI) * 180,
                radius: Math.sqrt(dx*dx + dy*dy)
            }; 
        }

        onPressed: {
            // start new action, drag or rotate:
            var pos = {x:mouseX, y:mouseY}
            pressStartPos = pos;

            if (!myApp.model.hasSelection)
                return;

            myApp.model.inLiveDrag = true;

            if (myApp.model.recordsPositionX) {
                currentAction = {
                    x: pos.x,
                    y: pos.y
                };
            } else if (myApp.model.selectedSprites.length !== 0) {
                currentAction = getAngleAndRadius(rotationCenterItem, pos);
            }
        }

        onPositionChanged: {
            if (!myApp.model.hasSelection)
                return;

            // drag or rotate current sprite:
            var pos = {x:mouseX, y:mouseY}

            if (myApp.model.selectedSprites.length !== 0) {
                if (myApp.model.recordsPositionX) {
                    // continue drag
                    var dx = pos.x - currentAction.x;
                    var dy = pos.y - currentAction.y;

                    if (false /* todo: come up with solution */) {
//                        // Move anchor
//                        var layer = myApp.model.selectedSprites[0];
//                        var sprite = layer.sprite
//                        var keyframe = myApp.model.getOrCreateKeyframe(layer);
//                        var globalPos = focusFrames.mapFromItem(sprite, keyframe.anchorX, keyframe.anchorY);
//                        var localDelta = focusFrames.mapToItem(sprite, globalPos.x + dx, globalPos.y + dy);
//                        keyframe.anchorX = localDelta.x;
//                        keyframe.anchorY = localDelta.y;

//                        // When changing origin of rotation, the focus rotate with it. But we want the focus
//                        // to follow the mouse, so move the sprite back so the focus ends up under the mouse again:
//                        var newGlobalPos = focusFrames.mapFromItem(sprite, keyframe.anchorX, keyframe.anchorY);
//                        sprite.x -= (newGlobalPos.x - globalPos.x) - dx;
//                        sprite.y -= (newGlobalPos.y - globalPos.y) - dy;
//                        keyframe.x = sprite.x;
//                        keyframe.y = sprite.y;
//                        myApp.model.syncReparentSprites(layer);
//                        if (myApp.model.recording)
//                            myApp.timelineFlickable.recordPlay = true;
                    } else {
                        // Move selected sprites
                        for (var i in myApp.model.selectedSprites) {
                            var sprite = myApp.model.selectedSprites[i];
                            var globalPos = sprites.mapFromItem(sprite.parent, sprite.x, sprite.y);
                            var newSpritePos = sprites.mapToItem(sprite.parent, globalPos.x + dx, globalPos.y + dy);

                            var changes = {}
                            if (model.recordsPositionX)
                                changes.x = newSpritePos.x;
                            if (model.recordsPositionY)
                                changes.y = newSpritePos.y;
                            sprite.updateKeyframe(myApp.model.time, changes, {propagate:!myApp.model.recording});

                            if (myApp.model.recording)
                                myApp.timelineFlickable.recordPlay = true;
                        }
                    }

                    currentAction.x = pos.x;
                    currentAction.y = pos.y;
                } else {
                    // continue rotate / scale
                    var aar = getAngleAndRadius(rotationCenterItem, pos);

                    for (i in myApp.model.selectedSprites) {
                        sprite = myApp.model.selectedSprites[i];

                        changes = {}
                        if (myApp.model.recordsRotation) {
                            var a = aar.angle - currentAction.angle;
                            var b = a - 360;
                            var c = a + 360;
                            a = Math.abs(a) < Math.abs(b) ? a : b;
                            a = Math.abs(a) < Math.abs(c) ? a : c;
                            changes.transRotation = sprite.transRotation + a;
                        }
                        if (myApp.model.recordsScale) {
                            changes.transScaleX = sprite.transScaleX * (aar.radius / currentAction.radius);
                            changes.transScaleY = sprite.transScaleY * (aar.radius / currentAction.radius);
                        }
                        sprite.updateKeyframe(myApp.model.time, changes, {propagate:!myApp.model.recording});

                        if (myApp.model.recording)
                            myApp.timelineFlickable.recordPlay = true;
                    }
                    currentAction.angle = aar.angle;
                    currentAction.radius = aar.radius;
                }
            }
        }

        onReleased: {
            var m = myApp.model;
            var pos = {x:mouseX, y:mouseY}
            var sprite = m.getSpriteAtScenePos(pos);

            if (clickCount == 1) {
                currentAction = {};

                if (m.hasSelection)
                    unselectAllSprites()
                else if (sprite)
                    m.selectSprite(sprite, true);
            } else if (clickCount == 2 && sprite) {
                m.selectSprite(sprite, true);
            }

            myApp.model.inLiveDrag = false;
            myApp.timelineFlickable.recordPlay = false;
        }
    }

    function unselectAllSprites()
    {
        var m = myApp.model;
        for (var i = m.selectedSprites.length - 1; i >= 0; --i)
            m.selectSprite(m.selectedSprites[i], false)
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

    Connections {
        target: myApp.model

        onSelectedSpritesUpdated: {
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

}

