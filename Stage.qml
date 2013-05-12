import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    property Item storyBoard
    property alias images: layers
    property int focusSize: 20

    property var pressStartTime: 0
    property var pressStartPos: undefined
    property var currentAction: new Object()

    onStoryBoardChanged: {
        storyBoard.stage = root
    }

    Rectangle {
        id: layers
        color: "white"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
    }

    Item {
        id: focusFrames
        anchors.fill: layers
    }

    MouseArea {
        anchors.fill: images

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
            for (var i in storyBoard.selectedLayers) {
                var layer = storyBoard.layers[storyBoard.selectedLayers[i]]
                var image = layer.image
                var cx = image.x + (image.width / 2)
                var cy = image.y + (image.height / 2)
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

            if (storyBoard.selectedLayers.length !== 0) {
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
                    var layer = storyBoard.layers[storyBoard.selectedLayers[0]]
                    var center = { x: layer.image.x + (layer.image.width / 2), y: layer.image.y  + (layer.image.height / 2)};
                    currentAction = getAngleAndRadius(center, pos);
                    currentAction.rotating = true
                }
            }
        }

        onPositionChanged: {
            // drag or rotate current layer:
            var pos = {x:mouseX, y:mouseY}
            if (currentAction.selecting) {
                var layer = storyBoard.getLayerAt(pos, storyBoard.currentTime);
                if (layer && !layer.selected)
                    storyBoard.selectLayer(layer.z, true);
            } else if (storyBoard.selectedLayers.length !== 0) {
                if (currentAction.dragging) {
                    // continue drag
                    for (var i in storyBoard.selectedLayers) {
                        var layer = storyBoard.layers[storyBoard.selectedLayers[i]];
                        var state = layer.currentState;
                        var image = layer.image
                        if (xBox.checked)
                            image.x += pos.x - currentAction.x;
                        if (yBox.checked)
                            image.y += pos.y - currentAction.y;
                        state.x = image.x;
                        state.y = image.y;
                    }
                    currentAction.x = pos.x;
                    currentAction.y = pos.y;
                } else if (currentAction.rotating) {
                    // continue rotate
                    var layer = storyBoard.layers[storyBoard.selectedLayers[0]]
                    var center = { x: layer.image.x + (layer.image.width / 2), y: layer.image.y  + (layer.image.height / 2)};
                    var aar = getAngleAndRadius(center, pos);
                    for (var i in storyBoard.selectedLayers) {
                        var layer = storyBoard.layers[storyBoard.selectedLayers[i]];
                        var state = layer.currentState;
                        var image = layer.image
                        if (rotateBox.checked)
                            image.rotation += aar.angle - currentAction.angle;
                        if (scaleBox.checked)
                            image.scale *= aar.radius / currentAction.radius;
                        state.rotation = image.rotation;
                        state.scale = image.scale;
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
                var layer = storyBoard.getLayerAt(pos, storyBoard.currentTime);
                var select = layer && !layer.selected
                for (var i = storyBoard.selectedLayers.length - 1; i >= 0; --i)
                    storyBoard.selectLayer(storyBoard.selectedLayers[i], false)
                if (select)
                    storyBoard.selectLayer(layer.z, select)
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
            layer.focus.target = layer.image
        } else {
            layer.focus.destroy()
        }
    }

}

