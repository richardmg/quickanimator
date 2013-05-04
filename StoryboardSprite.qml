import QtQuick 2.1

Item {
    id: sprite
    parent: storyboard
    property int currentStateIndex: 0
    property int timeToNextState: 0
    property var timeplan: []
    property Timer timer: Timer {
        interval: 1
        onTriggered: {
            var nextState = sprite.states[++currentStateIndex];
            if (nextState) {
                sprite.timeToNextState = timeplan[currentStateIndex] * msPerFrame;
                state = nextState.name;
            }
        }
    }
    transitions: Transition {
        SequentialAnimation {
            NumberAnimation {
                properties: "x, y, width, height, rotation, scale"
                duration: timeToNextState
            }
            ScriptAction { script: timer.restart(); }
        }
    }
}
