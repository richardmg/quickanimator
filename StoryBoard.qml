import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    clip: true
    property Stage stage: null
    property alias timeline: timeline
    property int currentTime: 0

    property int layerCount: 0
    property var layers: new Array()
    property var selectedLayers: new Array()
    property var selectedLayer: null
    property var selectedState: null

    Timeline {
        id: timeline
        y: cellHeight
        width: root.width
        height: root.height - y
        cellHeight: 20
        cellWidth: 10
        selectedX: 0
        selectedY: 0
        model: layers
        property alias time: timeline.selectedX

        onSelectedXChanged: {
            for (var l in root.layers) {
                var layer = layers[l];
                for (var i = 0; i < layer.states.length - 1; ++i) {
                    var stateBefore = layer.states[i];
                    var stateAfter = layer.states[i + 1];
                    if (time >= stateBefore.time && time < stateAfter.time)
                        break;
                }
                layer.currentState = layer.states[i];
                updateItemState(layer);
                root.selectedState = layer.currentState;
            }
        }

        onDoubleClicked: {
            var layer = layers[selectedY];
            // Add the new state into the correct position in the array according to time:
            for (var i = layer.states.length - 1; i >= 0; --i) {
                var state = layer.states[i];
                if (time === state.time) {
                    // A state already exist at this time:
                    return;
                } else if (time > state.time) {
                    break;
                }
            }
            layer.currentState = createStateFromItem(layer, time);
            layer.states.splice(i + 1, 0, layer.currentState);
            timeline.updateModel()
            root.selectedState = layer.currentState;
        }
    }

    TitleBar {
        ToolButton {
            id: play
            anchors.left: parent.left
            anchors.leftMargin: 2
            text: "Play"
            x: 2
            height: parent.height - 4
            anchors.verticalCenter: parent.verticalCenter
            onClicked: play();
        }
        Label {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: play.right
            anchors.leftMargin: 10
            text: "Time: " + timeline.time
        }
        ToolButton {
            anchors.right: parent.right
            text: "+"
            x: 2
            height: parent.height - 4
            anchors.verticalCenter: parent.verticalCenter
            onClicked: myApp.addImage("dummy.jpeg") 
        }
    }

    onSelectedStateChanged: {
        if (selectedState && selectedLayer)
            timeline.setHighlight(selectedState.time, selectedLayer.z);
    }

    function updateItemState(layer)
    {
        var item = layer.image;
        var state = layer.currentState;
        item.x = state.x;
        item.y = state.y;
        item.rotation = state.rotation;
        item.scale = state.scale;
    }

    function addLayer(layer)
    {
        unselectAllLayers();
        layers.push(layer);
        layer.z = layerCount++;
        layer.selected = false;
        layer.states = new Array();
        layer.currentState = createStateFromItem(layer, 0);
        layer.states.push(layer.currentState);
        stage.layerAdded(layer);
        selectLayer(layer.z, true);
        timeline.updateModel()
    }

    function createStateFromItem(layer, time)
    {
        var item = layer.image
        var state = {
            x:item.x,
            y:item.y,
            name:"state_" + time + "_" + layer.z,
            width:item.width,
            height:item.height,
            rotation:item.rotation,
            scale:item.scale,
            time:time,
            layer: layer.z
        };
        return state;
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

    function selectLayer(z, select)
    {
        var layer = layers[z] 
        if (select === layer.selected)
            return;
        layer.selected = select;
        if (select) {
            selectedLayers.push(layer.z)
            selectedLayer = layer;
            root.selectedState = layer.currentState;
        } else {
            var i = selectedLayers.indexOf(z);
            selectedLayers.splice(i, 1);
            if (selectedLayer == layer) {
                selectedLayer = null;
                root.selectedState = null;
            }
        }
        stage.layerSelected(layer, select)
    }
    
    function removeLayer(z)
    {
        var layer = layers[z]
        layers.splice(z, 1);
        if (layer.selected) {
            var i = selectedLayers.indexOf(z);
            selectedLayers.splice(i, 1);
        }
    }

    function setLayerZ(oldZ, newZ)
    {
        var layer = layers[oldZ]
        newZ = Math.max(0, Math.min(layers.length - 1, newZ));
        if (newZ === oldZ)
            return;
        layers.splice(oldZ, 1);
        layers.splice(newZ, 0, layer);
    }

    function getLayerAt(p, time)
    {
        // todo: respect time
        for (var i=layers.length - 1; i>=0; --i) {
            var image = layers[i].image
            if (p.x >= image.x && p.x <= image.x + image.width
                && p.y >= image.y && p.y <= image.y + image.height) {
                return layers[i]
            }
        }
    }

}

