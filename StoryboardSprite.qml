import QtQuick 2.1
import "timelinedata.js" as TLD

Item {
    id: sprite
    width: childrenRect.width
    height: childrenRect.height

    property Item storyboard: parent 

    property var spriteIndex: 0
    property var spriteTime: 0

    property bool paused: false
    property bool finished: false

    property var _fromState
    property var _toState
    property int _toStateIndex: 0

    property var _tickTime: 0

    Component.onCompleted: {
        _toState = _fromState = TLD.sprites[spriteIndex][0];
        if (!_toState)
            print("Warning: sprite", spriteIndex, "needs at least one state!");
    }

    function tick()
    {
        if (paused || finished)
            return;

        _tickTime++;
        var t = Math.floor(_tickTime / storyboard.ticksPerFrame);
        if (spriteTime != t)
            spriteTime = t;

        _updateSprite();

        if (spriteTime === _toState.time) {
            var after = _toState.after;
            if (after) {
                var currentStateIndex = _toStateIndex;
                after(sprite);
                if (currentStateIndex !== _toStateIndex)
                    return;
            }
            if (_toStateIndex >= TLD.sprites[spriteIndex].length - 1) {
                finished = true;
            } else {
                _fromState = _toState;
                _toState = TLD.sprites[spriteIndex][++_toStateIndex];
                if (_toState.time == _fromState.time)
                    _tickCount--;
            }
        }
    }

    function getStateIndexBefore(time)
    {
        var timeline = TLD.sprites[spriteIndex]

        // Binary search timeline:
        var low = 0, high = timeline.length - 1;
        var t, i;

        while (low <= high) {
            i = Math.floor((low + high) / 2) - 1;
            if (i < 0) 
                return 0;
            t = timeline[i].time;
            if (time <= t) {
                high = i - 1;
                continue;
            };
            if (time == t)
                return i;
            t = timeline[i + 1].time;
            if (time <= t)
                return i;
            low = i + 2;
        }
        return 0;
    }

    function setTime(time)
    {
        if ((_fromState && time < _fromState.time) || (_toState && time > _toState.time)) {
            var fromStateIndex = getStateIndexBefore(time);
            var timeline = TLD.sprites[spriteIndex]
            _fromState = timeline[fromStateIndex];
            if (_fromState.time === time) {
                _toStateIndex = fromStateIndex;
                _toState = _fromState;
            } else {
                _toStateIndex = fromStateIndex + 1;
                _toState = timeline[_toStateIndex];
            }
        }

        spriteTime = time;
        // Subract 1 to let the first call to tick land on \a time:
        _tickTime = (time * storyboard.ticksPerFrame) - 1;
        finished = false;
    }

    function _updateSprite()
    {
        if (_toState.time === _fromState.time) {
            x = _toState.x;
            y = _toState.y;
            scale = _toState.scale;
            rotation = _toState.rotation;
            opacity = _toState.opacity;
        } else {
            var advance = _tickTime - (_fromState.time * storyboard.ticksPerFrame);
            var tickRange = (_toState.time - _fromState.time) * storyboard.ticksPerFrame;
            x = _getValue(_fromState.x, _toState.x, tickRange, advance, "linear");
            y = _getValue(_fromState.y, _toState.y, tickRange, advance, "linear");
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
