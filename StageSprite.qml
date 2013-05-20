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

    property var _tickTime: 0

    property bool _invalidCache: true

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
                var currentStateIndex = _toState.temporaryIndex;
                after(sprite);
                if (currentStateIndex !== _toState.temporaryIndex)
                    return;
            }
            if (_toState.temporaryIndex >= timeline.length - 1) {
                finished = true;
            } else {
                _fromState = _toState;
                _toState = timeline[++_toState.temporaryIndex];
                if (_toState.time == _fromState.time)
                    _tickCount--;
            }
        }
    }

    function createState(time)
    {
        var index = timeline.length === 0 ? 0 : getState(time).temporaryIndex + 1;
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
            layer:layer.z,
            index:-1 // NB: index will be set for each getState call!
        };
        timeline.splice(index, 0, state);
        _invalidCache = true;
        return state;
    }

    function getCurrentState()
    {
        _updateToAndFromState(spriteTime);
        return _fromState;
    }

    function getState(time)
    {
        return (time >= _fromState.time && time < _toState.time) ? getCurrentState() : _getStateBinarySearch(time);
    }

    function setTime(time, tween)
    {
        _updateToAndFromState(time);
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

    function _updateToAndFromState(time)
    {
        _invalidCache = _invalidCache || !_fromState || !_toState || time < _fromState.time || time >= _toState.time;
        if (_invalidCache) {
            _fromState = _getStateBinarySearch(time);
            _toState = (_fromState.temporaryIndex === timeline.length - 1) ? _fromState : timeline[_fromState.temporaryIndex + 1];
            _invalidCache = false;
        }
    }

    function _getStateBinarySearch(time)
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
        var state = timeline[i];
        state.temporaryIndex = i;
        return state;
    }


}
