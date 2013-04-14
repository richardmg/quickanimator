import QtQuick 2.1

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

    Timeline {
        id: timeline
        y: cellHeight
        width: root.width
        height: root.height - y
        cellHeight: 20
        cellWidth: 10
        rows: layerCount + 1
        selectedX: 0
        selectedY: 0

        onDoubleClicked: {
            var time = selectedX;
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
            layer.currentState = createStateFromItem(layer.image, time);
            layer.states.splice(i + 1, 0, layer.currentState);
        }
    }

    TitleBar {
        title: "0.0s"
    }

    function addLayer(layer)
    {
        layers.push(layer);
        layer.z = layerCount++;
        layer.selected = false;
        layer.states = new Array();
        layer.currentState = createStateFromItem(layer.image, 0);
        layer.states.push(layer.currentState);
        stage.layerAdded(layer);
    }

    function createStateFromItem(item, time)
    {
        var state = {
            x:item.x,
            y:item.y,
            width:item.width,
            height:item.height,
            rotation:item.rotation,
            scale:item.scale,
            time:time
        };
        return state;
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
        } else {
            var i = selectedLayers.indexOf(z);
            selectedLayers.splice(i, 1);
            if (selectedLayer == layer)
                selectedLayer = null;
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

