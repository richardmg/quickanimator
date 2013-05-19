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

    property bool _invalid: true

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

    function getStateAtTime(time, create)
    {
        var fromStateIndex = getFromStateIndex(time);
        var state = timeline[fromStateIndex];
        if (state && (state.time === time || !create))
            return state;
        var state = {
            x:sprite.x,
            y:sprite.y,
            z:sprite.z,
            name:"state_" + spriteIndex + "_" + time,
            width:sprite.width,
            height:sprite.height,
            rotation:sprite.rotation,
            scale:sprite.scale,
            opacity:sprite.opacity,
            time:time,
            layer:layer.z
        };
        timeline.splice(fromStateIndex + 1, 0, state);
        _invalid = true;
        return state;
    }

    function getFromStateIndex(time)
    {
        // Binary search timeline:
        var low = 0, high = timeline.length - 1;
        var t, i;

        while (low <= high) {
            i = Math.floor((low + high) / 2);
            t = timeline[i].time;
            if (time < t) {
                high = i - 1;
                continue;
            }
            if (i == high || time < timeline[i + 1].time)
                break;
            low = i + 1
        }
        return i;
    }

    function setTime(time, tween)
    {
        _invalid = _invalid || !_fromState || !_toState || time < _fromState.time || time >= _toState.time;
        if (_invalid) {
            var fromStateIndex = getFromStateIndex(time);
            _fromState = timeline[fromStateIndex];
            if (_fromState.time === time || fromStateIndex === timeline.length - 1)
                _toStateIndex = fromStateIndex;
            else
                _toStateIndex = fromStateIndex + 1;
            _toState = timeline[_toStateIndex];
            _invalid = false;
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
