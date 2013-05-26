import QtQuick 2.1
import QtQuick.Controls 1.0

import FileIO 1.0

Item {
    id: root
    clip: true
    property Stage stage: null
    property alias timelineGrid: timelineGrid
    property int currentTime: 0
    property alias ticksPerFrame: ticksPerFrameBox.value

    property int layerCount: 0
    property var layers: new Array()
    property var selectedLayers: new Array()
    property var selectedLayer: null
    property var selectedState: null

    property bool tweenMode: true

    onTweenModeChanged: {
        for (var l in root.layers) {
            var layer = layers[l];
            layer.sprite.updateSprite(tweenMode);
        }
    }

    TimelineGrid {
        id: timelineGrid
        anchors.top: titlebar.bottom
        anchors.bottom: root.bottom
        width: root.width
        cellHeight: 20
        cellWidth: 10
        selectedX: 0
        selectedY: 0
        model: layers
        property alias time: timelineGrid.selectedX

        onSelectedXChanged: {
            for (var l in root.layers) {
                var layer = layers[l];
                layer.sprite.setTime(selectedX, tweenMode);
                layer.currentState = layer.sprite._fromState;
                root.selectedState = layer.currentState;
            }
        }

        onDoubleClicked: {
            var layer = layers[selectedY];
            // Add the new state into the correct position in the array according to time:
            for (var i = layer.sprite.timeline.length - 1; i >= 0; --i) {
                var state = layer.sprite.timeline[i];
                if (time === state.time) {
                    // A state already exist at this time:
                    return;
                } else if (time > state.time) {
                    break;
                }
            }
            layer.currentState = layer.sprite.createState(time);
            root.selectedState = layer.currentState;
            timelineGrid.repaint()
        }
    }

    TitleBar {
        id: titlebar
        TitleBarRow {
            ToolButton {
                id: rewind
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: "<<"
                onClicked: {
                    for (var i = 0; i < layers.length; ++i)
                        layers[i].sprite.setTime(0);
                    timelineGrid.selectedX = 0;
                }
            }
            ToolButton {
                id: play
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: checked ? "Stop" : "Play"
                checkable: true
                onCheckedChanged: if (checked) playTimer.start(); else playTimer.stop()
            }
            ToolButton {
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: "Tween"
                checkable: true
                checked: true
                onCheckedChanged: tweenMode = checked
            }
            ToolButton {
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: "Save"
                onClicked: saveJSON();
            }
            SpinBox {
                id: ticksPerFrameBox
                value: 30
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        TitleBarRow {
            layoutDirection: Qt.RightToLeft
            Item { width: 10; height: 10 }
            Label {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                text: "Time: " + timelineGrid.time
            }
        }
    }

    Timer {
        id: playTimer
        interval: 1000 / 60
        repeat: true
        onTriggered: {
            for (var i = 0; i < layers.length; ++i)
                layers[i].sprite.tick();
            timelineGrid.selectedX = layers[0].sprite.spriteTime;
        }
    }

    onSelectedStateChanged: {
        if (selectedState && selectedLayer)
            timelineGrid.repaint();
    }

    function addLayer(layer)
    {
        unselectAllLayers();
        layers.push(layer);
        layer.layerIndex = layerCount++;
        layer.selected = false;
        layer.currentState = layer.sprite.createState(0);
        stage.layerAdded(layer);
        selectLayer(layer.layerIndex, true);
        timelineGrid.repaint()
    }

    function unselectAllLayers()
    {
        for (var i in selectedLayers) {
            var layer = layers[selectedLayers[i]];
            layer.selected = false;
            stage.layerSelected(layer, false);
        }
        selectedLayers = new Array();
    }

    function selectLayer(layerIndex, select)
    {
        var layer = layers[layerIndex] 
        if (select === layer.selected)
            return;
        layer.selected = select;
        if (select) {
            selectedLayers.push(layer.layerIndex)
            selectedLayer = layer;
            root.selectedState = layer.currentState;
        } else {
            var i = selectedLayers.indexOf(layerIndex);
            selectedLayers.splice(i, 1);
            if (selectedLayer == layer) {
                selectedLayer = null;
                root.selectedState = null;
            }
        }
        stage.layerSelected(layer, select)
    }
    
    function removeLayer(layerIndex)
    {
        var layer = layers[layerIndex]
        layers.splice(layerIndex, 1);
        if (layer.selected) {
            var i = selectedLayers.indexOf(layerIndex);
            selectedLayers.splice(i, 1);
        }
    }

    function setLayerIndex(oldIndex, newIndex)
    {
        var layer = layers[oldIndex]
        newIndex = Math.max(0, Math.min(layers.length - 1, newIndex));
        if (newIndex === oldIndex)
            return;
        layers.splice(oldIndex, 1);
        layers.splice(newIndex, 0, layer);
    }

    function getLayerAt(p, time)
    {
        // todo: respect time
        for (var i=layers.length - 1; i>=0; --i) {
            var sprite = layers[i].sprite
            if (p.x >= sprite.x && p.x <= sprite.x + sprite.width
                && p.y >= sprite.y && p.y <= sprite.y + sprite.height) {
                return layers[i]
            }
        }
    }

    FileIO {
        id: file
        source: "save.anim.js"
    }


    function saveJSON()
    {
        var f = ".pragma library\n\nvar sprites = [\n{ image: 'dummy.jpeg', states: [\n";

        for (var i = 0; i < layers.length; ++i) {
            var layer = layers[i];
            var timeline = layer.sprite.timeline;
            for (var j = 0; j < timeline.length; ++j) {
                var s = timeline[j];
                f += "   { time: " + s.time
                + ", x: " + s.x
                + ", y: " + s.y
                + ", z: " + s.z
                + ", rotation: " + s.rotation
                + ", scale: " + s.scale
                + ", opacity: " + s.opacity
                + ", name: '" + s.name + "'"
                + " }"
                if (j < timeline.length - 1)
                    f += ",\n"
            }
            f += (i < layers.length - 1) ? "\n]},{ image: 'dummy.jpeg', states: [\n" : "\n]}\n";
        }
        f += "]\n";

        file.write(f);
    }
}

