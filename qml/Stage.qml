import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property FlickableMouseArea flickable: null

    property alias sprites: sprites

    property var pressStartPos: undefined
    property var currentAction: new Object()
    property bool timelineWasPlaying: false
    property bool timelinePlay: false

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
            // start new layer operation, drag or rotate:
            timelineWasPlaying = myApp.timelineFlickable.playing;
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
            } else if (myApp.model.selectedLayers.length !== 0) {
                var layer = myApp.model.selectedLayers[0];
                var sprite = layer.sprite
                currentAction = getAngleAndRadius(rotationCenterItem, pos);
            }
        }

        onPositionChanged: {
            if (!myApp.model.hasSelection)
                return;

            // drag or rotate current layer:
            var pos = {x:mouseX, y:mouseY}

            if (myApp.model.selectedLayers.length !== 0) {
                if (myApp.model.recordsPositionX) {
                    // continue drag
                    var dx = pos.x - currentAction.x;
                    var dy = pos.y - currentAction.y;

                    if (false /* todo: come up with solution */) {
                        // Move anchor
                        var layer = myApp.model.selectedLayers[0];
                        var sprite = layer.sprite
                        var keyframe = myApp.model.getOrCreateKeyframe(layer);
                        var globalPos = focusFrames.mapFromItem(sprite, keyframe.anchorX, keyframe.anchorY);
                        var localDelta = focusFrames.mapToItem(sprite, globalPos.x + dx, globalPos.y + dy);
                        keyframe.anchorX = localDelta.x;
                        keyframe.anchorY = localDelta.y;

                        // When changing origin of rotation, the focus rotate with it. But we want the focus
                        // to follow the mouse, so move the sprite back so the focus ends up under the mouse again:
                        var newGlobalPos = focusFrames.mapFromItem(sprite, keyframe.anchorX, keyframe.anchorY);
                        sprite.x -= (newGlobalPos.x - globalPos.x) - dx;
                        sprite.y -= (newGlobalPos.y - globalPos.y) - dy;
                        keyframe.x = sprite.x;
                        keyframe.y = sprite.y;
                        myApp.model.syncReparentLayers(layer);
                        if (timelinePlay)
                            myApp.timelineFlickable.stagePlay = true;
                    } else {
                        // Move selected sprites
                        for (var i in myApp.model.selectedLayers) {
                            layer = myApp.model.selectedLayers[i];
                            keyframe = myApp.model.getOrCreateKeyframe(layer);
                            sprite = layer.sprite
                            globalPos = sprites.mapFromItem(sprite.parent, sprite.x, sprite.y);
                            var newSpritePos = sprites.mapToItem(sprite.parent, globalPos.x + dx, globalPos.y + dy);
                            if (model.recordsPositionX) {
                                sprite.x = newSpritePos.x;
                                keyframe.x = sprite.x;
                            }
                            if (model.recordsPositionY) {
                                sprite.y = newSpritePos.y
                                keyframe.y = sprite.y;
                            }
                            myApp.model.syncReparentLayers(layer);
                            if (timelinePlay)
                                myApp.timelineFlickable.stagePlay = true;
                        }
                    }

                    currentAction.x = pos.x;
                    currentAction.y = pos.y;
                } else {
                    // continue rotate
                    layer = myApp.model.selectedLayers[0];
                    sprite = layer.sprite
                    keyframe = sprite.getCurrentKeyframe();
                    var aar = getAngleAndRadius(rotationCenterItem, pos);

                    for (var i in myApp.model.selectedLayers) {
                        layer = myApp.model.selectedLayers[i];
                        keyframe = myApp.model.getOrCreateKeyframe(layer);
                        if (myApp.model.recordsRotation) {
                            var a = aar.angle - currentAction.angle;
                            var b = a - 360;
                            var c = a + 360;
                            a = Math.abs(a) < Math.abs(b) ? a : b;
                            a = Math.abs(a) < Math.abs(c) ? a : c;
                            layer.sprite.transRotation += a;
                            keyframe.rotation = layer.sprite.transRotation;
                        }
                        if (myApp.model.recordsScale) {
                            keyframe.scale *= aar.radius / currentAction.radius;
                            layer.sprite.transScaleX *= aar.radius / currentAction.radius;
                            layer.sprite.transScaleY *= aar.radius / currentAction.radius;
                            keyframe.scale = layer.sprite.transScaleX;
                        }
                        myApp.model.syncReparentLayers(layer);
                        if (timelinePlay)
                            myApp.timelineFlickable.stagePlay = true;
                    }
                    currentAction.angle = aar.angle;
                    currentAction.radius = aar.radius;
                }
            }
        }

        onReleased: {
            var m = myApp.model;
            var pos = {x:mouseX, y:mouseY}
            var layer = m.getLayerAt(pos);

            if (clickCount == 1) {
                currentAction = {};

                if (m.hasSelection)
                    unselectAllLayers()
                else if (layer)
                    m.selectLayer(layer, true);
            } else if (clickCount == 2 && layer) {
                m.selectLayer(layer, true);
            }

            myApp.model.inLiveDrag = false;
            myApp.timelineFlickable.stagePlay = false;
        }
    }

    function unselectAllLayers()
    {
        var m = myApp.model;
        for (var i = m.selectedLayers.length - 1; i >= 0; --i)
            m.selectLayer(m.selectedLayers[i], false)
    }

    Component {
        id: layerFocus
        Rectangle {
            id: layerFocusItem
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
                layerFocusItem.x = mapped.x - (width / 2);
                layerFocusItem.y = mapped.y - (width / 2);
            }

            Connections {
                target: layerFocusItem.target
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

        onSelectedLayersUpdated: {
            if (unselectedLayer != -1) {
                var layer = myApp.model.layers[unselectedLayer];
                layer.focus.visible = false;
                layer.focus.destroy();
                layer.focus = null;
            }
            if (selectedLayer != -1) {
                layer = myApp.model.layers[selectedLayer];
                layer.focus = layerFocus.createObject(focusFrames);
                layer.focus.target = layer.sprite;
                layer.focus.syncFocusPosition();
            }
        }
    }

}

