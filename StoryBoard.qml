import QtQuick 2.1

Item {
    id: root
    clip: true
    property Stage stage: null
    property alias timeline: timeline

    property int layerCount: 0
    property var layers: new Array()
    property var selectedLayers: new Array()

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
    }

    TitleBar {
        title: "0.0s"
    }

    function getCurrentKeyFrame(z)
    {
        return layers[z][0]
    }

    function addLayer(layer)
    {
        layers[layerCount] = new Array()
        layers[layerCount] = layer
        layer.keyframes = new Array()
        layer.z = layerCount++
        layer.selected = false
        addKeyframe(layer.z, 0)
        stage.layerAdded(layer)
    }

    function addKeyframe(z, time)
    {
        // todo: respect time
        layers[z].keyframes.push({
            x:0,
            y:0,
            width:0,
            height:0,
            rotation:0,
            scale:1,
            time:time
        })
    }

    function selectLayer(z, select)
    {
        var layer = layers[z] 
        if (select === layer.selected)
            return;
        layer.selected = select;
        if (select) {
            selectedLayers.push(layer.z)
        } else {
            var i = selectedLayers.indexOf(z);
            selectedLayers.splice(i, 1);
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
}

