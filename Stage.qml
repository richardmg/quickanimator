import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    property Item timeline
    property alias sprites: sprites
    property int focusSize: 20

    property var pressStartTime: 0
    property var pressStartPos: undefined
    property var currentAction: new Object()

    onTimelineChanged: {
        timeline.stage = root
    }

    Rectangle {
        id: sprites
        color: "white"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom

        property int ticksPerFrame: 1
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
            for (var i in timeline.selectedLayers) {
                var layer = timeline.layers[timeline.selectedLayers[i]]
                var sprite = layer.sprite
                var cx = sprite.x + (sprite.width / 2)
                var cy = sprite.y + (sprite.height / 2)
                var dx = pos.x - cx
                var dy = pos.y - cy
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

            if (timeline.selectedLayers.length !== 0) {
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
                    var layer = timeline.layers[timeline.selectedLayers[0]]
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
                var layer = timeline.getLayerAt(pos, timeline.currentTime);
                if (layer && !layer.selected)
                    timeline.selectLayer(layer.z, true);
            } else if (timeline.selectedLayers.length !== 0) {
                if (currentAction.dragging) {
                    // continue drag
                    for (var i in timeline.selectedLayers) {
                        var layer = timeline.layers[timeline.selectedLayers[i]];
                        var state = layer.currentState;
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
                    var layer = timeline.layers[timeline.selectedLayers[0]]
                    var center = { x: layer.sprite.x + (layer.sprite.width / 2), y: layer.sprite.y  + (layer.sprite.height / 2)};
                    var aar = getAngleAndRadius(center, pos);
                    for (var i in timeline.selectedLayers) {
                        var layer = timeline.layers[timeline.selectedLayers[i]];
                        var state = layer.currentState;
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
                var layer = timeline.getLayerAt(pos, timeline.currentTime);
                var select = layer && !layer.selected
                for (var i = timeline.selectedLayers.length - 1; i >= 0; --i)
                    timeline.selectLayer(timeline.selectedLayers[i], false)
                if (select)
                    timeline.selectLayer(layer.z, select)
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
            property Item target: root
            x: target.x + (target.width / 2) - focusSize
            y: target.y + (target.height / 2) - focusSize
            width: focusSize * 2
            height: focusSize * 2
            color: "transparent"
            radius: focusSize
            border.width: 3
            border.color: Qt.rgba(255, 0, 0, 0.7)
            smooth: true
        }
    }

    function layerAdded(layer)
    {
    }

    function layerSelected(layer, select)
    {
        if (select) {
            layer.focus = layerFocus.createObject(0)
            layer.focus.parent = focusFrames
            layer.focus.target = layer.sprite
        } else {
            layer.focus.destroy()
        }
    }

}

