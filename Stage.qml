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
                var m = sprite.mapFromItem(sprites, pos.x, pos.y);

                if (m.x < 0 || m.x > sprite.width || m.y < 0 && m.y > sprite.height)
                    continue;

                var dx = m.x - (sprite.width / 2);
                var dy = m.y - (sprite.height / 2);
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
                    var center = { x: layer.sprite.x + (layer.sprite.width / 2), y: layer.sprite.y  + (layer.sprite.height / 2)};
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
                    for (var i in myApp.model.selectedLayers) {
                        var layer = myApp.model.selectedLayers[i];
                        var state = myApp.model.getState(layer, myApp.model.time);
                        var sprite = layer.sprite
                        if (xBox.checked)
                            sprite.x += pos.x - currentAction.x;
                        if (yBox.checked)
                            sprite.y += pos.y - currentAction.y;
                        state.x = sprite.x;
                        state.y = sprite.y;
                    }
                    currentAction.x = pos.x;
                    currentAction.y = pos.y;
                } else if (currentAction.rotating) {
                    // continue rotate
                    var layer = myApp.model.selectedLayers[0];
                    var center = { x: layer.sprite.x + (layer.sprite.width / 2), y: layer.sprite.y  + (layer.sprite.height / 2)};
                    var aar = getAngleAndRadius(center, pos);
                    for (var i in myApp.model.selectedLayers) {
                        var layer = myApp.model.selectedLayers[i];
                        var state = myApp.model.getState(layer, myApp.model.time);
                        var sprite = layer.sprite
                        if (rotateBox.checked)
                            sprite.rotation += aar.angle - currentAction.angle;
                        if (scaleBox.checked)
                            sprite.scale *= aar.radius / currentAction.radius;
                        state.rotation = sprite.rotation;
                        state.scale = sprite.scale;
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
            property Item target: root
            x: focusFrames.mapFromItem(target, (target.width / 2), (target.height / 2)).x - focusSize
            y: focusFrames.mapFromItem(target, (target.width / 2), (target.height / 2)).y - focusSize
            width: focusSize * 2
            height: focusSize * 2
            color: "transparent"
            radius: focusSize
            border.width: 3
            border.color: Qt.rgba(255, 0, 0, 0.7)
            smooth: true

            Connections {
                target: layerFocusItem.target
                onXChanged: layerFocusItem.x = focusFrames.mapFromItem(target,
                            (target.width / 2), (target.height / 2)).x - focusSize;
                onYChanged: layerFocusItem.y = focusFrames.mapFromItem(target,
                            (target.width / 2), (target.height / 2)).y - focusSize;
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
            }
        }
    }

}

