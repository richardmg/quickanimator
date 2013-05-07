import QtQuick 2.1

Item {
    id: sprite
    parent: storyboard
    property int currentStateIndex: 0
    property int timeToNextState: 0
    property var timeplan: []
    property var time: 0

    Timer {
        id: setStateTimer
        interval: 1
        property string pendingState
        onTriggered: sprite.state = pendingState
    }

    transitions: Transition {
        SequentialAnimation {
            NumberAnimation {
                properties: "x, y, width, height, rotation, scale"
                duration: timeToNextState
            }
            ScriptAction {
                script: {
                    time = timeplan[currentStateIndex];
                    if (time > storyboard.time)
                        storyboard.time = time;

                    var after = states[currentStateIndex].after;
                    if (after) {
                        after();
                        if (setStateTimer.running)
                            return;
                    }

                    var nextState = states[++currentStateIndex];
                    if (nextState) {
                        timeToNextState = (timeplan[currentStateIndex] - time) * msPerFrame;
                        setStateTimer.pendingState = nextState.name;
                        setStateTimer.restart();
                    }
                }
            }
        }
    }

    function setTime(time, timeSpan)
    {
        sprite.time = time

        // Binary search timplan array:
        var low = 0, high = timeplan.length - 1;
        var t, i = 0;

        while (low <= high) {
            i = Math.floor((low + high) / 2) - 1;
            t = timeplan[i];
            if (time < t) {
                high = i - 1;
                continue;
            };
            if (time == t)
                break;
            t = timeplan[++i];
            if (time <= t)
                break;
            low = i + 1;
        }

        currentStateIndex = i;
        timeToNextState = Math.max(0, timeSpan === -1 ? timeplan[i] - time : timeSpan) * msPerFrame;
        setStateTimer.pendingState = states[i].name;
        setStateTimer.restart();
    }
}
