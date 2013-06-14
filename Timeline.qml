import QtQuick 2.1
import QtQuick.Controls 1.0

import FileIO 1.0

TimelineGrid {
    id: root
    clip: true
    property int currentTime: 0

    property int layerCount: 0
    property var layers: new Array()
    property var selectedLayers: new Array()
    property var selectedState: null

    property bool tweenMode: true

    model: layers

    // Helper signal, since we cannot listen to pure JS array changes:
    signal selectedLayersArrayChanged

    onTweenModeChanged: {
        for (var l in root.layers) {
            var layer = layers[l];
            layer.sprite.updateSprite(tweenMode);
        }
    }

    onSelectedYChanged: {
        updateSelectedState();
    }

    onSelectedXChanged: {
        for (var l in root.layers) {
            var layer = layers[l];
            layer.sprite.setTime(selectedX, tweenMode);
        }
        updateSelectedState();
    }

    function updateSelectedState()
    {
        var foundState = null;
        if (!playTimer.running) {
            var layer = myApp.timeline.layers[myApp.timeline.selectedY];
            if (layer) {
                var state = layer.sprite.getCurrentState();
                if (state && state.time === state.sprite.spriteTime)
                    foundState = state;
            }
        }
        if (foundState != root.selectedState)
            root.selectedState = foundState;
    }

    onDoubleClicked: {
        var layer = layers[selectedY];
        if (!layer)
            return;
        var state = layer.sprite.getState(selectedX);
        if (!state || state.time != selectedX) {
            // Add the new state at time selectedX:
            layer.sprite.createState(selectedX);
            timelineList.repaint()
            updateSelectedState();
        }
    }

    function togglePlay(play)
    {
        playTimer.running = play
    }

    Timer {
        id: playTimer
        interval: 1000 / 60
        repeat: true

        onRunningChanged: updateSelectedState();
        onTriggered: {
            for (var i = 0; i < layers.length; ++i)
                layers[i].sprite.tick();
            selectedX = layers[0].sprite.spriteTime;
        }
    }

    function addLayer(layer)
    {
        unselectAllLayers();
        layers.push(layer);
        layer.selected = false;
        layer.sprite.createState(0);
        layer.sprite.setTime(root.time, false);
        myApp.stage.layerAdded(layer);
        selectLayer(layer, true);
        timelineList.repaint()
    }

    function unselectAllLayers()
    {
        selectedLayersArrayChanged();
        for (var i in selectedLayers) {
            var layer = selectedLayers[i];
            layer.selected = false;
            myApp.stage.layerSelected(layer, false);
        }
        selectedLayers = new Array();
    }

    function selectLayer(layer, select)
    {
        if (select === layer.selected)
            return;
        layer.selected = select;
        if (select) {
            selectedLayers.push(layer)
        } else {
            var i = selectedLayers.indexOf(layer);
            selectedLayers.splice(i, 1);
        }
        myApp.stage.layerSelected(layer, select)
        selectedLayersArrayChanged();
    }
    
    function removeLayer(layer)
    {
        layers.splice(layer.indexOf(layer), 1);
        if (layer.selected)
            selectedLayers.splice(selectedLayers.indexOf(layer), 1);
        selectedLayersArrayChanged();
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

