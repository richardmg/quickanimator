import QtQuick 2.1
import "timelinedata.js" as TLD

Item {
    id: sprite
    parent: storyboard
    width: childrenRect.width
    height: childrenRect.height

    property Item storyboard: storyboard 
    property var spriteIndex: 0
    property int stateIndex: 0
    property var spriteTime: 0
    property int nextStateTime: 0
    property bool paused: false

    property var incX: 0
    property var incY: 0
    property var incScale: 0
    property var incRotation: 0
    property var incOpacity: 0

    function tick(time)
    {
        x += incX;
        y += incY;
        scale += incScale;
        rotation += incRotation;
        opacity += incOpacity;

        if (time === nextStateTime) {
            var after = TLD.sprites[spriteIndex][stateIndex].after;
            if (after) {
                var currentStateIndex = stateIndex;
                after(sprite);
                if (currentStateIndex !== stateIndex)
                    return;
            }
            var nextState = TLD.sprites[spriteIndex][++stateIndex];
            nextStateTime = nextState.time;
            var tickCount = Math.max(1, nextStateTime - time) * ticksPerFrame
            calculateIncrements(nextState, tickCount);
        }
    }

    function setTime(time)
    {
        var timeline = TLD.sprites[spriteIndex]

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

        stateIndex = i;
        spriteTime = time;
        var nextState = timeline[i];
        nextStateTime = nextState.time;

        if (nextStateTime <= time) {
            calculateIncrements(nextState, 1);
            tick();
        } else {
            calculateIncrements(nextState, (nextStateTime - time) * 60);
        }
    }

    function calculateIncrements(toState, tickCount)
    {
        incX = toState.x == undefined ? 0 : (toState.x - x) / tickCount;
        incY = toState.y == undefined ? 0 : (toState.y - y) / tickCount;
        incScale = toState.scale == undefined ? 0 : (toState.scale - scale) / tickCount;
        incRotation = toState.rotation == undefined ? 0 : (toState.rotation - rotation) / tickCount;
        incOpacity = toState.opacity == undefined ? 0 : (toState.opacity - opacity) / tickCount;
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
