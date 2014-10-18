import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    property alias sprites: sprites
    property int focusSize: 20

    property var pressStartTime: 0
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
    }

    MouseArea {
        anchors.fill: sprites
        acceptedButtons: Qt.LeftButton | Qt.RightButton

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

        onPressed: {
            if (mouse.button === Qt.RightButton)
                return;

            // start new layer operation, drag or rotate:
            timelineWasPlaying = myApp.timeline.playing;
            var pos = {x:mouseX, y:mouseY}
            pressStartTime = new Date().getTime();
            pressStartPos = pos;

            if (myApp.model.recordsPositionX) {
                currentAction = {
                    x: pos.x,
                    y: pos.y
                };
                myApp.model.inLiveDrag = true;
            } else if (myApp.model.selectedLayers.length !== 0) {
                var layer = myApp.model.selectedLayers[0];
                var sprite = layer.sprite
                var globalPos = sprites.mapFromItem(sprite.parent, sprite.x + sprite.anchorX, sprite.y + sprite.anchorY);
                var center = {x: globalPos.x, y: globalPos.y};
                currentAction = getAngleAndRadius(center, pos);
            }
        }

        onPositionChanged: {
            if (mouse.button === Qt.RightButton)
                return;

            // drag or rotate current layer:
            var pos = {x:mouseX, y:mouseY}

            if (myApp.model.selectedLayers.length !== 0) {
                if (myApp.model.recordsPositionX) {
                    // continue drag
                    var dx = pos.x - currentAction.x;
                    var dy = pos.y - currentAction.y;

                    if (mouse.modifiers & Qt.ShiftModifier) {
                        // Move anchor
                        var layer = myApp.model.selectedLayers[0];
                        var sprite = layer.sprite
                        keyframe = myApp.model.getOrCreateKeyframe(layer);
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
                            myApp.timeline.stagePlay = true;
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
                                myApp.timeline.stagePlay = true;
                        }
                    }

                    currentAction.x = pos.x;
                    currentAction.y = pos.y;
                } else {
                    // continue rotate
                    layer = myApp.model.selectedLayers[0];
                    sprite = layer.sprite
                    var keyframe = sprite.getCurrentKeyframe();
                    globalPos = sprites.mapFromItem(sprite.parent, sprite.x + sprite.anchorX, sprite.y + sprite.anchorY);
                    var center = {x: globalPos.x, y: globalPos.y};
                    var aar = getAngleAndRadius(center, pos);

                    for (var i in myApp.model.selectedLayers) {
                        layer = myApp.model.selectedLayers[i];
                        keyframe = myApp.model.getOrCreateKeyframe(layer);
                        if (myApp.model.recordsRotation) {
                            var a = aar.angle - currentAction.angle;
                            var b = a - 360;
                            var c = a + 360;
                            a = Math.abs(a) < Math.abs(b) ? a : b;
                            a = Math.abs(a) < Math.abs(c) ? a : c;
                            keyframe.rotation += a;
                            layer.sprite.transRotation = keyframe.rotation;
                        }
                        if (myApp.model.recordsScale) {
                            keyframe.scale *= aar.radius / currentAction.radius;
                            layer.sprite.transScaleX = keyframe.scale;
                            layer.sprite.transScaleY = keyframe.scale;
                        }
                        myApp.model.syncReparentLayers(layer);
                        if (timelinePlay)
                            myApp.timeline.stagePlay = true;
                    }
                    currentAction.angle = aar.angle;
                    currentAction.radius = aar.radius;
                }
            }
        }

        onReleased: {
            if (mouse.button === Qt.RightButton)
                return;

            var pos = {x:mouseX, y:mouseY}

            var click = (new Date().getTime() - pressStartTime) < 300 
                && Math.abs(pos.x - pressStartPos.x) < 10
                && Math.abs(pos.y - pressStartPos.y) < 10;

            if (click) {
                var m = myApp.model;
                currentAction = {};
                var layer = m.getLayerAt(pos);

                if (!layer || !layer.selected)
                    unselectAllLayers();

                if (layer) {
                    if (!layer.selected)
                        m.selectLayer(layer, true);
                    else
                        changeRecordState();
                }
            }

            myApp.model.inLiveDrag = false;
            myApp.timeline.stagePlay = false;
        }

        onClicked: {
            if (mouse.button === Qt.RightButton)
                myApp.model.shiftUserInterfaceState()
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
            m.recordsScale = true;
            m.recordsRotation = true;
        } else {
            m.clearRecordState();
            m.recordsPositionX = true;
            m.recordsPositionY = true;
        }
    }

    Component {
        id: layerFocus
        Rectangle {
            id: layerFocusItem
            property Item target: null
            width: focusSize * 2
            height: focusSize * 2
            color: "transparent"
            radius: myApp.model.recordsPositionX ? 0 : focusSize
            border.width: 3
            border.color: Qt.rgba(255, 0, 0, 0.7)
            smooth: true

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

