import QtQuick 2.1

Item {
    id: sprite
    width: childrenRect.width
    height: childrenRect.height

    property QtObject model: parent 
    property var timeline: new Array()

    property var spriteTime: 0
    property string name: "unknown"
    property bool playing: false

    property var _fromState
    property var _toState
    property var _currentIndex: 0
    property bool _invalidCache: true

    property NumberAnimation _animation_x: NumberAnimation{ target: sprite; property: "x" }
    property NumberAnimation _animation_y: NumberAnimation{ target: sprite; property: "y" }
    property NumberAnimation _animation_z: NumberAnimation{ target: sprite; property: "z" }
    property NumberAnimation _animation_rotation: NumberAnimation{ target: sprite; property: "rotation" }
    property NumberAnimation _animation_scale: NumberAnimation{ target: sprite; property: "scale" }
    property NumberAnimation _animation_opacity: NumberAnimation{ target: sprite; property: "opacity" }
    property NumberAnimation _nextStateAnimation: NumberAnimation {
        target: _nextStateAnimation;
        property int goToNextState
        property: "goToNextState"
        from: 0; to: 1
        onRunningChanged: {
            if (!goToNextState || !playing)
                return;

            spriteTime = _toState.time;

            var after = _toState.after;
            if (after) {
                var tmpIndex = _currentIndex
                after(sprite);
                if (tmpIndex !== _currentIndex)
                    return;
            }

            if (_currentIndex < timeline.length - 1) {
                _currentIndex++;
                _fromState = _toState;
                _toState = (_currentIndex === timeline.length - 1) ? _fromState : timeline[_currentIndex + 1];
            }
            _play();
        }
    }

    property var _props: ["x", "y", "z", "rotation", "scale", "opacity"];
    onPlayingChanged: if (playing) _play(); else _stop();

    function _play()
    {
        _updateProperties(true);
        var duration = (_toState.time - spriteTime) * model.msPerFrame;
        if (duration <= 0)
            return;
        for (var i in _props) {
            var prop = _props[i];
            sprite["_animation_" + prop].to = _toState[prop];
            sprite["_animation_" + prop].duration = duration;
            sprite["_animation_" + prop].restart();
        }
        _nextStateAnimation.duration = duration;
        _nextStateAnimation.restart();
    }

    function _stop()
    {
        for (var i in _props)
            sprite["_animation_" + _props[i]].stop();
        _nextStateAnimation.stop();
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
        _updateProperties(tween);
        if (playing)
            _play();
    }

    function _updateProperties(tween)
    {
        if (!tween || _toState.time === _fromState.time) {
            x = _fromState.x;
            y = _fromState.y;
            scale = _fromState.scale;
            rotation = _fromState.rotation;
            opacity = _fromState.opacity;
        } else {
            var fromStateMs = _fromState.time * model.msPerFrame
            var advanceMs = (spriteTime * model.msPerFrame) - fromStateMs;
            x = _interpolate(_fromState.x, _toState.x, advanceMs, "linear");
            y = _interpolate(_fromState.y, _toState.y, advanceMs, "linear");
            z = _interpolate(_fromState.z, _toState.z, advanceMs, "linear");
            scale = _interpolate(_fromState.scale, _toState.scale, advanceMs, "linear");
            rotation = _interpolate(_fromState.rotation, _toState.rotation, advanceMs, "linear");
            opacity = _interpolate(_fromState.opacity, _toState.opacity, advanceMs, "linear");
        }
    }

    function _interpolate(from, to, advanceMs, curve)
    {
        // Ignore curve for now:
        var fromStateMs = _fromState.time * model.msPerFrame
        var totalTimeBetweenStatesMs = (_toState.time * model.msPerFrame) - fromStateMs;
        return from + (((to - from) / totalTimeBetweenStatesMs) * advanceMs);
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
