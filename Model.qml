import QtQuick 2.1

import FileIO 1.0

QtObject {
    id: root
    property int time: 0
    property int layerCount: 0
    property var layers: new Array()
    property var selectedLayers: new Array()
    property var focusState: null
    property int ticksPerFrame: 1

    signal layersUpdated(var removedLayer, var addedLayer)
    signal selectedLayersUpdated(var unselectedLayer, var selectedLayer)
    signal statesUpdated(var layer)

    property bool tweenMode: true

    onTweenModeChanged: {
        for (var l in layers) {
            var layer = layers[l];
            layer.sprite.updateSprite(tweenMode);
        }
    }

    function setTime(time)
    {
        root.time = time;
        for (var l in layers) {
            var layer = layers[l];
            layer.sprite.setTime(time, tweenMode);
        }
    }

    function setFocusLayer(layerIndex)
    {
        // Get the state that should be shown for the user to edit:
        var foundState = null;
        var layer = layers[layerIndex];
        if (layer) {
            var state = layer.sprite.getCurrentState();
            if (state && state.time === state.sprite.spriteTime)
                foundState = state;
        }
        if (foundState != root.focusState)
            root.focusState = foundState;
    }

    function addLayer(layer)
    {
        unselectAllLayers();
        layers.push(layer);
        layer.selected = false;
        layer.sprite.createState(0);
        layer.sprite.setTime(0, false);
        selectLayer(layer, true);
        layersUpdated(-1, layers.length);
    }

    function getState(layer, time)
    {
        // get state at time, or add a new
        // one if non existing:
        if (!layer)
            return;
        var state = layer.sprite.getState(time);
        if (!state || state.time != time) {
            // Add the new state at given time:
            var state = layer.sprite.createState(time);
            var index = layers.indexOf(layer);
            setFocusLayer(index);
            statesUpdated(index);
        }
        return state;
    }

    function unselectAllLayers()
    {
        for (var i in selectedLayers) {
            var layer = selectedLayers[i];
            layer.selected = false;
        }
        var unselectedLayers = selectedLayers;
        selectedLayers = new Array();
        for (var i = 0; i < unselectedLayers.length; ++i)
            selectedLayersUpdated(layers.indexOf(unselectedLayers[i]), -1);
    }

    function selectLayer(layer, select)
    {
        if (select === layer.selected)
            return;
        layer.selected = select;
        if (select) {
            selectedLayers.push(layer)
            selectedLayersUpdated(-1, layers.indexOf(layer));
        } else {
            selectedLayers.splice(selectedLayers.indexOf(layer), 1);
            selectedLayersUpdated(layers.indexOf(layer), -1);
        }
    }
    
    function removeLayer(layer)
    {
        var index = layer.indexOf(layer);
        layers.splice(index, 1);
        if (layer.selected) {
            selectedLayers.splice(selectedLayers.indexOf(layer), 1);
            selectedLayersUpdated(layer.indexOf(layer), -1);
        }
        layersUpdated(index, -1); 
    }

    function removeCurrentState()
    {
        selectedLayers[0].sprite.removeCurrentState(tweenMode);
        timelineList.repaint();
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

    function getLayerAt(p)
    {
        for (var i=layers.length - 1; i>=0; --i) {
            var sprite = layers[i].sprite
            if (p.x >= sprite.x && p.x <= sprite.x + sprite.width
                && p.y >= sprite.y && p.y <= sprite.y + sprite.height) {
                return layers[i]
            }
        }
    }

    property FileIO file: FileIO { source: "save.anim.js" }

    function saveJSON()
    {
        var f = ".pragma library\n\nvar sprites = [\n{ image: 'dummy.jpeg', states: [\n";

        for (var i = 0; i < layers.length; ++i) {
            var layer = layers[i];
            var timeline = layer.sprite.timeline;
            for (var j = 0; j < timeline.length; ++j) {
                var s = timeline[j];
                f += "   { time: " + s.time
                + ", x: " + s.x.toFixed(2)
                + ", y: " + s.y.toFixed(2)
                + ", z: " + s.z.toFixed(2)
                + ", rotation: " + s.rotation.toFixed(2)
                + ", scale: " + s.scale.toFixed(2)
                + ", opacity: " + s.opacity.toFixed(2)
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

