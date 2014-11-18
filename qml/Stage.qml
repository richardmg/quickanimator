import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property FlickableMouseArea mouseArea: null

    property alias sprites: sprites
    property int focusSize: 20

    property var pressStartTime: 0
    property var pressStartPos: undefined
    property var lastClickTime: 0
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
            visible: myApp.model.hasSelection && myApp.model.recordsRotation
            width: 5
            height: 5
            anchors.centerIn: parent
            color: "red"
        }
    }

    Connections {
        target: mouseArea

        onPressedChanged: {
            if (mouseArea.pressed)
                mousePressed(mouseArea.mouseX, mouseArea.mouseY)
            else
                mouseReleased(mouseArea.mouseX, mouseArea.mouseY)
        }

        function getAngleAndRadius(p1, p2)
        {
            var dx = p2.x - p1.x;
            var dy = p1.y - p2.y;
            return {
                angle: (Math.atan2(dx, dy) / Math.PI) * 180,
                radius: Math.sqrt(dx*dx + dy*dy)
            }; 
        }

        function overlapsHandle(pos)
        {
            var layers = myApp.model.layers;
            for (var i=layers.length - 1; i>=0; --i) {
                var sprite = layers[i].sprite
                var mapped = sprites.mapFromItem(sprite, sprite.anchorX, sprite.anchorY);
                var dx = pos.x - mapped.x;
                var dy = pos.y - mapped.y;
                var len = Math.sqrt((dx * dx) + (dy * dy))
                if (len < focusSize)
                    return layer
            }
            return null;
        }

        function mousePressed(mouseX, mouseY)
        {
            // start new layer operation, drag or rotate:
            timelineWasPlaying = myApp.timeFlickable.playing;
            var pos = {x:mouseX, y:mouseY}
            pressStartTime = new Date().getTime();
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
                            myApp.timeFlickable.stagePlay = true;
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
                                myApp.timeFlickable.stagePlay = true;
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
                            myApp.timeFlickable.stagePlay = true;
                    }
                    currentAction.angle = aar.angle;
                    currentAction.radius = aar.radius;
                }
            }
        }

        function mouseReleased(mouseX, mouseY)
        {
            var pos = {x:mouseX, y:mouseY}

            var time = new Date().getTime();
            var click = (time - pressStartTime) < 300
                && Math.abs(pos.x - pressStartPos.x) < 10
                && Math.abs(pos.y - pressStartPos.y) < 10;
            var multiClick = click && (time - lastClickTime < 600)

            if (click) {
                lastClickTime = time;
                var m = myApp.model;
                currentAction = {};
                var layer = m.getLayerAt(pos);
                var hasSelection = myApp.model.selectedLayers.length > 0

                if (hasSelection && !multiClick) {
                    unselectAllLayers()
                } else if (layer) {
                    if (!hasSelection)
                        m.selectLayer(layer, true);
                    else
                        changeRecordState();
                }
            }

            myApp.model.inLiveDrag = false;
            myApp.timeFlickable.stagePlay = false;
        }
    }

    function unselectAllLayers()
    {
        var m = myApp.model;
        for (var i = m.selectedLayers.length - 1; i >= 0; --i)
            m.selectLayer(m.selectedLayers[i], false)
    }

    function changeRecordState()
    {
        var m = myApp.model;
        if (m.recordsPositionX) {
            m.clearRecordState();
            m.recordsRotation = true;
        } else if (m.recordsRotation) {
            m.clearRecordState();
            m.recordsScale = true;
        } else {
            m.clearRecordState();
            m.recordsPositionX = true;
            m.recordsPositionY = true;
        }
    }

    Component {
        id: layerFocus
        Text {
            id: layerFocusItem
            property Item target: null
            width: focusSize * 2
            height: focusSize * 2
            color: "red"
            text: myApp.model.recordsPositionX ? "Move" : myApp.model.recordsRotation ? "Rotate" : "Scale"

            function syncFocusPosition()
            {
                var mapped = focusFrames.mapFromItem(target, target.anchorX, target.anchorY);
                layerFocusItem.x = mapped.x - focusSize;
                layerFocusItem.y = mapped.y - focusSize;
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

