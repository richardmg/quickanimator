import QtQuick 2.1
import "timelinedata.js" as TLD

Item {
    id: sprite
    parent: storyboard
    property var spriteIndex: 0
    property int currentStateIndex: 0
    property var time: 0
    property int nextTime: 0
    property bool paused: false

    property var incX: 0
    property var incY: 0

    transitions: Transition {
        SequentialAnimation {
            NumberAnimation {
                properties: "x, y, width, height, rotation, scale, opacity"
                duration: timeToNextState
            }
            ScriptAction {
                script: {
                    if (sprite.paused)
                        return;

                    time = timeplan[currentStateIndex];
                    if (time > storyboard.time)
                        storyboard.time = time;

                    var after = states[currentStateIndex].after;
                    if (after) {
                        after();
                        if (setStateTimer.running || paused)
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

    function tick(time)
    {
//        print("tick:", time, nextTime);
        x += incX;
        y += incY;
        print("update...", x, time, nextTime)
        if (time === nextTime) {
            var nextState = TLD.sprites[spriteIndex][++currentStateIndex];
            nextTime = nextState.time;
            var timeDiff = Math.max(1, nextTime - time);
            var updateCount = (timeDiff) * ticksPerFrame;
            incX = (nextState.x - x) / updateCount;
            incY = (nextState.y - y) / updateCount;
            print("next:", x, nextState.x, timeDiff, updateCount)
        }
    }

    function setTime(time, timeSpan)
    {
        sprite.time = time
        var timeline = TLD.sprites[spriteIndex]
        print("len:", timeline.length);

        // Binary search timplan array:
        var low = 0, high = timeline.length - 1;
        var t, i = 0;

        while (low <= high) {
            i = Math.floor((low + high) / 2) - 1;
            if (i < 0) {
                i = 0;
                break;
            }
            t = timeline[i].time;
            if (time < t) {
                high = i - 1;
                continue;
            };
            if (time == t)
                break;
            t = timeline[++i].time;
            if (time <= t)
                break;
            low = i + 1;
        }

        currentStateIndex = i;

        var nextState = timeline[i];
        nextTime = timeSpan !== -1 ? time + timeSpan : nextState.time;
        var timeDiff = Math.max(1, nextTime - time);
        var updateCount = timeDiff * 60;

        incX = (nextState.x - x) / updateCount;
        incY = (nextState.y - y) / updateCount;

        tick(time);
//        setStateTimer.pendingState = states[i].name;
//        setStateTimer.restart();
    }

    onPausedChanged: {
        if (paused) {
            var _x = x;
            var _y = y;
            var _r = rotation;
            var _s = scale;
            var _o = opacity;
            timeToNextState = 0;
            state = "";
            x = _x;
            y = _y;
            rotation = _r;
            scale = _s;
            opacity = _o;
        }
    }
}
