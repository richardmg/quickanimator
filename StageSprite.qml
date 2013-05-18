import QtQuick 2.1

Item {
    id: sprite
    width: childrenRect.width
    height: childrenRect.height

    property Item stage: parent 
    property var timeline: new Array()

    property var spriteIndex: 0
    property var spriteTime: 0

    property bool paused: false
    property bool finished: false

    property var _fromState
    property var _toState
    property int _toStateIndex: 0

    property var _tickTime: 0

    Component.onCompleted: {
        _toState = _fromState = timeline[0];
        if (!_toState)
            print("Warning: sprite", spriteIndex, "needs at least one state!");
    }

    function tick()
    {
        if (paused || finished)
            return;

        _tickTime++;
        var t = Math.floor(_tickTime / stage.ticksPerFrame);
        if (spriteTime != t)
            spriteTime = t;

        updateSprite(true);

        if (spriteTime === _toState.time) {
            var after = _toState.after;
            if (after) {
                var currentStateIndex = _toStateIndex;
                after(sprite);
                if (currentStateIndex !== _toStateIndex)
                    return;
            }
            if (_toStateIndex >= timeline.length - 1) {
                finished = true;
            } else {
                _fromState = _toState;
                _toState = timeline[++_toStateIndex];
                if (_toState.time == _fromState.time)
                    _tickCount--;
            }
        }
    }

    function getStateIndexBefore(time)
    {
        // Binary search timeline:
        var low = 0, high = timeline.length - 1;
        var t, i = 0;

        while (low < high) {
            i = Math.floor((low + high) / 2);
            t = timeline[i].time;
            if (time < t) {
                high = --i;
                continue;
            }
            t = timeline[++i].time;
            if (time <= t)
                return i - 1;
            low = i + 1;
        }
        return i;
    }

    function setTime(time, tween)
    {
        if ((!_fromState || time < _fromState.time) || (!_toState || time > _toState.time)) {
            var fromStateIndex = getStateIndexBefore(time);
            _fromState = timeline[fromStateIndex];
            if (_fromState.time === time || fromStateIndex === timeline.length - 1) {
                _toStateIndex = fromStateIndex;
                _toState = _fromState;
            } else {
                _toStateIndex = fromStateIndex + 1;
                _toState = timeline[_toStateIndex];
            }
        }

        spriteTime = time;
        _tickTime = (time * stage.ticksPerFrame);
        updateSprite(tween);
        finished = false;
    }

    function updateSprite(tween)
    {
        if (!tween || _toState.time === _fromState.time) {
            x = _fromState.x;
            y = _fromState.y;
            scale = _fromState.scale;
            rotation = _fromState.rotation;
            opacity = _fromState.opacity;
        } else {
            var advance = _tickTime - (_fromState.time * stage.ticksPerFrame);
            var tickRange = (_toState.time - _fromState.time) * stage.ticksPerFrame;
            x = _getValue(_fromState.x, _toState.x, tickRange, advance, "linear");
            y = _getValue(_fromState.y, _toState.y, tickRange, advance, "linear");
            z = _getValue(_fromState.z, _toState.z, tickRange, advance, "linear");
            scale = _getValue(_fromState.scale, _toState.scale, tickRange, advance, "linear");
            rotation = _getValue(_fromState.rotation, _toState.rotation, tickRange, advance, "linear");
            opacity = _getValue(_fromState.opacity, _toState.opacity, tickRange, advance, "linear");
        }
    }

    function _getValue(from, to, tickdiff, advance, curve)
    {
        // Ignore curve for now:
        return from + ((to - from) / tickdiff) * advance;
    }

}
