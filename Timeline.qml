import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    clip: true
    property Stage stage: null
    property alias timelineGrid: timelineGrid
    property int currentTime: 0

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
            layer.currentState = layer.sprite.getStateAtTime(time, true);
            root.selectedState = layer.currentState;
            timelineGrid.repaint()
        }
    }

    TitleBar {
        id: titlebar
        TitleBarRow {
            ToolButton {
                id: play
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: "Play"
                onClicked: play();
            }
            ToolButton {
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: "Tween"
                checkable: true
                checked: true
                onCheckedChanged: tweenMode = checked
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
        layer.currentState = layer.sprite.getStateAtTime(0, true);
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
        var layer = layers[z] 
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
        var layer = layers[z]
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

}

