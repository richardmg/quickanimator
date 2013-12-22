import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    property alias sprites: sprites
    property int focusSize: 20

    property var pressStartTime: 0
    property var pressStartPos: undefined
    property var currentAction: new Object()

    Rectangle {
        id: sprites
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        gradient: myApp.style.stageGradient
    }

    Item {
        id: focusFrames
        anchors.fill: sprites
    }

    MouseArea {
        anchors.fill: sprites

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
            // start new layer operation, drag or rotate:
            var pos = {x:mouseX, y:mouseY}
            pressStartTime = new Date().getTime();
            pressStartPos = pos;

            if (myApp.model.selectedLayers.length !== 0) {
                var layer = overlapsHandle(pos);
                if (layer) {
                    // start drag
                    currentAction = {
                        layer: layer, 
                        dragging: true,
                        x: pos.x,
                        y: pos.y
                    };
                } else {
                    // Start rotation
                    var layer = myApp.model.selectedLayers[0];
                    var sprite = layer.sprite
                    var globalPos = sprites.mapFromItem(sprite.parent, sprite.x + sprite.anchorX, sprite.y + sprite.anchorY);
                    var center = {x: globalPos.x, y: globalPos.y};
                    currentAction = getAngleAndRadius(center, pos);
                    currentAction.rotating = true
                }
            }
        }

        onPositionChanged: {
            // drag or rotate current layer:
            var pos = {x:mouseX, y:mouseY}
            if (currentAction.selecting) {
                var layer = myApp.model.getLayerAt(pos);
                if (layer && !layer.selected)
                    myApp.model.selectLayer(layer, true);
            } else if (myApp.model.selectedLayers.length !== 0) {
                if (currentAction.dragging) {
                    // continue drag
                    var dx = pos.x - currentAction.x;
                    var dy = pos.y - currentAction.y;

                    if (mouse.modifiers & Qt.ControlModifier) {
                        // Move anchor
                        var layer = myApp.model.selectedLayers[0];
                        var sprite = layer.sprite
                        var keyframe = myApp.model.getState(layer, myApp.model.time);
                        var globalPos = focusFrames.mapFromItem(sprite, keyframe.anchorX, keyframe.anchorY);
                        var localDelta = focusFrames.mapToItem(sprite, globalPos.x + dx, globalPos.y + dy);
                        keyframe.anchorX = localDelta.x;
                        keyframe.anchorY = localDelta.y;
                        sprite.synchSpriteWithAnchorKeyframe(keyframe);

                        // When changing origin of rotation, the focus rotate with it. But we want the focus
                        // to follow the mouse, so move the sprite back so the focus ends up under the mouse again:
                        var newGlobalPos = focusFrames.mapFromItem(sprite, keyframe.anchorX, keyframe.anchorY);
                        sprite.x -= (newGlobalPos.x - globalPos.x) - dx;
                        sprite.y -= (newGlobalPos.y - globalPos.y) - dy;
                        keyframe.x = sprite.x;
                        keyframe.y = sprite.y;
                        layer.focus.syncFocusPosition();
                    } else {
                        // Move selected sprites
                        for (var i in myApp.model.selectedLayers) {
                            layer = myApp.model.selectedLayers[i];
                            sprite = layer.sprite
                            globalPos = sprites.mapFromItem(sprite.parent, sprite.x, sprite.y);
                            var newSpritePos = sprites.mapToItem(sprite.parent, globalPos.x + dx, globalPos.y + dy);
                            if (xBox.checked)
                                sprite.x = newSpritePos.x
                            if (yBox.checked)
                                sprite.y = newSpritePos.y

                            myApp.model.syncLayerPosition(layer);
                        }
                    }

                    currentAction.x = pos.x;
                    currentAction.y = pos.y;
                } else if (currentAction.rotating) {
                    // continue rotate
                    layer = myApp.model.selectedLayers[0];
                    sprite = layer.sprite
                    keyframe = sprite.getCurrentState();
                    globalPos = sprites.mapFromItem(sprite.parent, sprite.x + sprite.anchorX, sprite.y + sprite.anchorY);
                    var center = {x: globalPos.x, y: globalPos.y};
                    var aar = getAngleAndRadius(center, pos);
                    for (var i in myApp.model.selectedLayers) {
                        layer = myApp.model.selectedLayers[i];
                        var state = myApp.model.getState(layer, myApp.model.time);
                        if (rotateBox.checked)
                            state.rotation += aar.angle - currentAction.angle;
                        if (scaleBox.checked)
                            state.scale *= aar.radius / currentAction.radius;
                        layer.sprite.synchSpriteWithRotationKeyframe(keyframe);
                    }
                    currentAction.angle = aar.angle;
                    currentAction.radius = aar.radius;
                }
            } else {
                var startSelect = (Math.abs(pos.x - pressStartPos.x) < 10 || Math.abs(pos.y - pressStartPos.y) < 10);
                currentAction.selecting = true;
            }
        }

        onReleased: {
            var pos = {x:mouseX, y:mouseY}

            var click = (new Date().getTime() - pressStartTime) < 300 
                && Math.abs(pos.x - pressStartPos.x) < 10
                && Math.abs(pos.y - pressStartPos.y) < 10;

            if (click) {
                currentAction = {};
                var layer = myApp.model.getLayerAt(pos);
                var select = layer && !layer.selected
                for (var i = myApp.model.selectedLayers.length - 1; i >= 0; --i)
                    myApp.model.selectLayer(myApp.model.selectedLayers[i], false)
                if (select)
                    myApp.model.selectLayer(layer, select)
            }
        }
    }

    TitleBar {
        id: title
        title: "Stage"
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            CheckBox {
                id: xBox
                text: "X"
                checked: true
            }
            CheckBox {
                id: yBox
                text: "Y"
                checked: true
            }
            CheckBox {
                id: rotateBox
                text: "Rotate"
                checked: true
            }
            CheckBox {
                id: scaleBox
                text: "Scale"
                checked: false
            }
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
            radius: focusSize
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
            if (unselectedLayer != -1)
                myApp.model.layers[unselectedLayer].focus.destroy();
            if (selectedLayer != -1) {
                var layer = myApp.model.layers[selectedLayer];
                layer.focus = layerFocus.createObject(0);
                layer.focus.parent = focusFrames;
                layer.focus.target = layer.sprite;
                layer.focus.syncFocusPosition();
            }
        }
    }

}

