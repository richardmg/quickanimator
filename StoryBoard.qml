import QtQuick 2.1

Item {
    id: root
    clip: true
    property Stage stage: null
    property alias timeline: timeline

    property var layers: new Array()
    property var selectedLayers: new Array()
    property int layerCount: 0

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

    function add(layer)
    {
        layers[layerCount] = new Array()
        layers[layerCount][0] = layer
        layer.z = layerCount
        stage.api.addLayer(layer)
        layerCount++;
    }

    function select(z, select)
    {
        var layer = layers[z] 
        if (select === layer.selected)
            return;
        layer.selected = select;
        stage.select(layer, select)
    }
    
    function remove(z)
    {
        var layer = layers[z]
        layers.splice(z, 1);
        if (layer.selected) {
            var i = selectedLayers.indexOf(layer);
            selectedLayers.splice(i, 1);
        }
    }

    function setZ(oldZ, newZ)
    {
        var layer = layers[oldZ]
        newZ = Math.max(0, Math.min(layers.length - 1, newZ));
        if (newZ === oldZ)
            return;
        layers.splice(oldZ, 1);
        layers.splice(newZ, 0, layer);
    }
}

