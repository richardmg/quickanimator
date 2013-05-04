import QtQuick 2.1

Item {
    id: sprite
    parent: storyboard
    property int currentStateIndex: 0
    property int timeToNextState: 0
    property Timer timer: Timer {
        interval: 1
        onTriggered: {
            var nextState = sprite.states[++sprite.currentStateIndex];
            if (nextState) {
                sprite.timeToNextState = nextState.time * msPerFrame;
                sprite.state = nextState.name;
            }
        }
    }
    transitions: Transition {
        SequentialAnimation {
            NumberAnimation {
                properties: "x, y, width, height, rotation, scale"
                duration: sprite.timeToNextState
            }
            ScriptAction { script: sprite.timer.restart(); }
        }
    }
}
