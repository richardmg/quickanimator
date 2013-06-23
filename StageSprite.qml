import QtQuick 2.1

Item {
    id: sprite
    width: childrenRect.width
    height: childrenRect.height

    property QtObject model: parent 
    property var timeline: new Array()

    property var spriteIndex: 0
    property var spriteTime: 0

    property bool paused: false
    property bool finished: false

    property string name: "unknown"

    property var _fromState
    property var _toState
    property int _fromStateMs
    property int _totalTimeBetweenStatesMs
    property var _currentIndex: 0

    property bool _invalidCache: true

    function tick(ms)
    {
        if (paused || finished)
            return;

        updateSprite(ms, true);
        return;

        var t = Math.floor(ms / model.msPerFrame);
        if (spriteTime != t)
            spriteTime = t;

        if (spriteTime === _toState.time) {
            var after = _toState.after;
            if (after) {
                var tmpIndex = _currentIndex
                after(sprite);
                if (tmpIndex !== _currentIndex)
                    return;
            }
            if (_currentIndex >= timeline.length - 1) {
                finished = true;
            } else {
                _currentIndex++;
                _fromState = _toState;
                _toState = (_currentIndex === timeline.length - 1) ? _fromState : timeline[_currentIndex + 1];
                _fromStateMs = _fromState.time * model.msPerFrame
                _totalTimeBetweenStatesMs = (_toState.time * model.msPerFrame) - _fromStateMs;
            }
        }
    }

    function createState(time)
    {
        var index = timeline.length === 0 ? 0 : getState(time).lastSearchIndex + 1;
        var state = {
            x:sprite.x,
            y:sprite.y,
            z:sprite.z,
            name:name + "_" + time,
            width:sprite.width,
            height:sprite.height,
            rotation:sprite.rotation,
            scale:sprite.scale,
            opacity:sprite.opacity,
            time:time,
            sprite:sprite,
        };
        timeline.splice(index, 0, state);
        _invalidCache = true;
        return state;
    }

    function removeState(state, tween)
    {
        timeline.splice(timeline.indexOf(state), 1);
        _invalidCache = true;
        setTime(spriteTime, tween);
    }

    function removeCurrentState(tween)
    {
        removeState(getCurrentState(), tween);
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
        _fromStateMs = _fromState.time * model.msPerFrame
        _totalTimeBetweenStatesMs = (_toState.time * model.msPerFrame) - _fromStateMs;
        updateSprite(time * model.msPerFrame, tween);
        finished = false;
    }

    function updateSprite(ms, tween)
    {
        if (!tween || _toState.time === _fromState.time) {
            x = _fromState.x;
            y = _fromState.y;
            scale = _fromState.scale;
            rotation = _fromState.rotation;
            opacity = _fromState.opacity;
        } else {
            var advanceMs = ms - _fromStateMs;
            x = _getValue(_fromState.x, _toState.x, advanceMs, "linear");
            y = _getValue(_fromState.y, _toState.y, advanceMs, "linear");
            z = _getValue(_fromState.z, _toState.z, advanceMs, "linear");
            scale = _getValue(_fromState.scale, _toState.scale, advanceMs, "linear");
            rotation = _getValue(_fromState.rotation, _toState.rotation, advanceMs, "linear");
            opacity = _getValue(_fromState.opacity, _toState.opacity, advanceMs, "linear");
        }
    }

    function _getValue(from, to, advanceMs, curve)
    {
        // Ignore curve for now:
        return from + (((to - from) / _totalTimeBetweenStatesMs) * advanceMs);
    }

    property var lastx: 0
    function _getValueX(from, to, advanceMs, curve)
    {
        // Ignore curve for now:
        var newx = from + (((to - from) / _totalTimeBetweenStatesMs) * advanceMs);
        print("xdiff:", newx - lastx)
        lastx = newx;
        return newx;
    }

    function _updateToAndFromState(time)
    {
        _invalidCache = _invalidCache || !_fromState || !_toState || time < _fromState.time || time >= _toState.time;
        if (_invalidCache) {
            _fromState = _getStateBinarySearch(time);
            _currentIndex = _fromState.lastSearchIndex;
            _toState = (_currentIndex === timeline.length - 1) ? _fromState : timeline[_currentIndex + 1];
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
        state.lastSearchIndex = i;
        return state;
    }


}
