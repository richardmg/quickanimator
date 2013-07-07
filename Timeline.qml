import QtQuick 2.1
import QtQuick.Controls 1.0

import FileIO 1.0

TimelineWithSelector {
    id: root
    clip: true
    model: myApp.model.layers
    property bool _block: false

    onSelectedXChanged: if (!_block) myApp.model.setTime(selectedX);
    onSelectedYChanged: if (!playTimer.running) myApp.model.setFocusLayer(selectedY);
    onDoubleClicked: myApp.model.getState(myApp.model.layers[selectedY], selectedX);

    Connections {
        target: myApp.model
        onStatesUpdated: timelineCanvas.repaint();
        onLayersUpdated: timelineCanvas.repaint();
        onTimeChanged: if (!_block) {
            selectedX = myApp.model.time;
            playTimer.startTimeMs = (selectedX * myApp.model.msPerFrame) - (new Date()).getTime();
            var layers = myApp.model.layers;
            for (var i = 0; i < layers.length; ++i)
                layers[i].sprite.setTime(myApp.model.time);
        }
    }

    function togglePlay(play)
    {
        var layers = myApp.model.layers;
        for (var i = 0; i < layers.length; ++i)
            layers[i].sprite.playing = play;

        if (play) {
            fps.fps2 = 0;
            playTimer.startTimeMs = (selectedX * myApp.model.msPerFrame) - (new Date()).getTime();
        } else {
            myApp.model.setTime(selectedX);
            myApp.model.setFocusLayer(selectedY);
        }
        playTimer.running = play
    }

    Timer {
        id: fps
        interval: 1000
        repeat: true
        running: false//playTimer.running
        property int fps2: 0
        onTriggered: {
            print("fps:", fps2);
            fps2 = 0;
        }
    }

    Timer {
        id: playTimer
        interval: 1000 / 60
        repeat: true
        property var layers: myApp.model.layers
        property var startTimeMs: 0

        onTriggered: {
            fps.fps2++;
            var ms = startTimeMs + (new Date()).getTime();

            _block = true;
            var t = Math.floor(ms / myApp.model.msPerFrame);
            if (t != selectedX) {
                selectedX = t;
                myApp.model.time = t;
            }
            _block = false;
        }
    }
}

