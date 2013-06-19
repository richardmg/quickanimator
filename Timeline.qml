import QtQuick 2.1
import QtQuick.Controls 1.0

import FileIO 1.0

TimelineGrid {
    id: root
    clip: true
    model: myApp.model.layers
    property bool _block: false

    onSelectedXChanged: if (!_block) myApp.model.setTime(selectedX);
    onSelectedYChanged: if (!playTimer.running) myApp.model.setFocusLayer(selectedY);
    onDoubleClicked: myApp.model.getState(myApp.model.layers[selectedY], selectedX);

    Connections {
        target: myApp.model
        onStatesUpdated: timelineList.repaint();
        onLayersUpdated: timelineList.repaint();
        onTimeChanged: if (!_block) {
            selectedX = myApp.model.time;
            playTimer.tickTime = selectedX * myApp.model.ticksPerFrame;
        }
    }

    function togglePlay(play)
    {
        if (play) {
            playTimer.tickTime = selectedX * myApp.model.ticksPerFrame;
        } else {
            myApp.model.setTime(selectedX);
            myApp.model.setFocusLayer(selectedY);
        }
        playTimer.running = play
    }

    Timer {
        id: playTimer
        interval: 1000 / 60
        repeat: true
        property int tickTime: 0
        property var layers: myApp.model.layers

        onTriggered: {
            for (var i = 0; i < layers.length; ++i)
                layers[i].sprite.tick();

            _block = true;
            var t = Math.floor(tickTime++ / myApp.model.ticksPerFrame);
            if (t != selectedX) {
                selectedX = t;
                myApp.model.time = t;
            }
            _block = false;
        }
    }
}

