import QtQuick 2.1

Item {
    id: sprite

    property real anchorX: childrenRect.width / 2
    property real anchorY: childrenRect.height / 2
    property alias transRotation: tRotation.angle
    property alias transScaleX: tScale.xScale
    property alias transScaleY: tScale.yScale
    property alias rot: tRotation.angle

    transform: [
        Scale { id: tScale; xScale: 1; yScale: 1; origin.x: anchorX; origin.y: anchorY },
        Rotation { id: tRotation; angle: 0; origin.x: anchorX; origin.y: anchorY }
    ]

    property QtObject model: parent 
    property var keyframes: new Array()
    property int keyframeIndex: 0

    property real spriteTime: 0
    property string name: "keyframe"
    property bool playing: false

    property var _fromState
    property var _toState
    property bool _invalidCache: true

    property NumberAnimation _animation_x: NumberAnimation{ target: sprite; property: "x" }
    property NumberAnimation _animation_y: NumberAnimation{ target: sprite; property: "y" }
    property NumberAnimation _animation_z: NumberAnimation{ target: sprite; property: "z" }
    property NumberAnimation _animation_anchorX: NumberAnimation{ target: sprite; property: "anchorX" }
    property NumberAnimation _animation_anchorY: NumberAnimation{ target: sprite; property: "anchorY" }
    property NumberAnimation _animation_opacity: NumberAnimation{ target: sprite; property: "opacity" }
    property NumberAnimation _animation_rotation: NumberAnimation{ target: tRotation; property: "angle" }
    property NumberAnimation _animation_scale: NumberAnimation{ target: tScale; properties: "xScale, yScale" }
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
                var tmpIndex = keyframeIndex
                after(sprite);
                if (tmpIndex !== keyframeIndex)
                    return;
            }

            if (keyframeIndex < keyframes.length - 1) {
                keyframeIndex++;
                _fromState = _toState;
                _toState = (keyframeIndex === keyframes.length - 1) ? _fromState : keyframes[keyframeIndex + 1];
            }
            _play();
        }
    }

//    property var _props: ["x", "y", "z", "rotation", "scale", "opacity", "anchorX", "anchorY"];
    property var _props: ["x", "y"];
    onPlayingChanged: if (playing) _play(); else _stop();

    function _play()
    {
        // Move sprite to fromState:
        _interpolatePosition(spriteTime);
        // Animate to toState:
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

    function getPositionKeyframe(time)
    {
        var intTime = Math.round(time);
        return (intTime >= _fromState.time && intTime < _toState.time)
                ? getCurrentPositionKeyframe() : _getPositionKeyframeBinarySearch(intTime);
    }

    function getCurrentPositionKeyframe()
    {
        _updateToAndFromState(spriteTime);
        return _fromState;
    }

    function addPositionKeyframe(keyframe)
    {
        var index = keyframes.length === 0 ? 0 : getPositionKeyframe(keyframe.time).lastSearchIndex + 1;
        keyframes.splice(index, 0, keyframe);
        _invalidCache = true;
    }

    function createPositionKeyframe(time)
    {
        return {
            time:time,
            parent:parent,
            x:sprite.x,
            y:sprite.y,
            sprite:sprite
        };
    }

    function create_changeme_Keyframe(time)
    {
        return {
            time:time,
            sprite:sprite,
            z:sprite.z,
            anchorX: tScale.origin.x,
            anchorY: tScale.origin.y,
            name:name + time,
            width:sprite.width,
            height:sprite.height,
            rotation:transRotation,
            scale:transScaleX,
            opacity:sprite.opacity
        };
    }

    function synchSpriteWithPostitionKeyframe(keyframe)
    {
        x = keyframe.x;
        y = keyframe.y;
    }

    function synchSpriteWith_changeme_Keyframe(keyframe)
    {
        changeParent(keyframe.parent);
        x = keyframe.x;
        y = keyframe.y;
        z = keyframe.z;
        anchorX = keyframe.anchorX;
        anchorY = keyframe.anchorY;
        transRotation = keyframe.rotation;
        transScaleX = transScaleY = keyframe.scale;
        opacity = keyframe.opacity;
    }

    function removePositionKeyframe(keyframe)
    {
        keyframes.splice(keyframes.indexOf(keyframe), 1);
        _invalidCache = true;
        setTime(spriteTime);
    }

    function setTime(time)
    {
        _updateToAndFromState(time);
        spriteTime = time;
        _interpolatePosition(spriteTime);
        if (playing)
            _play();
    }

    function _interpolatePosition(time)
    {
        var effectiveFromState = _fromState.effectiveKeyframe ? _fromState.effectiveKeyframe : _fromState;
        if (_toState.time === effectiveFromState.time) {
            x = effectiveFromState.x;
            y = effectiveFromState.y;
        } else {
            var effectiveFromStateMs = effectiveFromState.time * model.msPerFrame;
            var advanceMs = (time * model.msPerFrame) - effectiveFromStateMs;
            x = _interpolate(effectiveFromState.x, _toState.x, advanceMs, "linear");
            y = _interpolate(effectiveFromState.y, _toState.y, advanceMs, "linear");
        }
        parent = _fromState.parent;
    }

    function _update_changeme_Properties(tween)
    {
        var effectiveFromState = _fromState.effectiveKeyframe ? _fromState.effectiveKeyframe : _fromState;
        if (!tween || _toState.time === effectiveFromState.time) {
            x = effectiveFromState.x;
            y = effectiveFromState.y;
            anchorX = effectiveFromState.anchorX;
            anchorY = effectiveFromState.anchorY;
            transScaleX = transScaleY = effectiveFromState.scale;
            transRotation = effectiveFromState.rotation;
            opacity = effectiveFromState.opacity;
        } else {
            var effectiveFromStateMs = effectiveFromState.time * model.msPerFrame
            var advanceMs = (spriteTime * model.msPerFrame) - effectiveFromStateMs;
            x = _interpolate(effectiveFromState.x, _toState.x, advanceMs, "linear");
            y = _interpolate(effectiveFromState.y, _toState.y, advanceMs, "linear");
            z = _interpolate(effectiveFromState.z, _toState.z, advanceMs, "linear");
            anchorX = _interpolate(effectiveFromState.anchorX, _toState.anchorX, advanceMs, "linear");
            anchorY = _interpolate(effectiveFromState.anchorY, _toState.anchorY, advanceMs, "linear");
            transScaleX = transScaleY = _interpolate(effectiveFromState.scale, _toState.scale, advanceMs, "linear");
            transRotation = _interpolate(effectiveFromState.rotation, _toState.rotation, advanceMs, "linear");
            opacity = _interpolate(effectiveFromState.opacity, _toState.opacity, advanceMs, "linear");
        }
        parent = _fromState.parent;
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
        var intTime = Math.round(time);
        _invalidCache = _invalidCache || !_fromState || !_toState || intTime < _fromState.time || intTime >= _toState.time;
        if (_invalidCache) {
            _fromState = _getPositionKeyframeBinarySearch(intTime);
            keyframeIndex = _fromState.lastSearchIndex;
            _toState = (keyframeIndex === keyframes.length - 1) ? _fromState : keyframes[keyframeIndex + 1];
            _invalidCache = false;
        }
    }

    function _getPositionKeyframeBinarySearch(time)
    {
        // Binary search keyframes:
        var low = 0, high = keyframes.length - 1;
        var t, i;

        while (low <= high) {
            i = Math.floor((low + high) / 2);
            t = keyframes[i].time;
            if (time < t) {
                high = i - 1;
                continue;
            }
            if (i == high || time < keyframes[i + 1].time)
                break;
            low = i + 1
        }
        var state = keyframes[i];
        state.lastSearchIndex = i;
        return state;
    }

    function changeParent(newParent)
    {
        if (parent == newParent)
            return;

        // Get current sprite geometry in scene/global coordinates:
        var hotspotX = (width / 2);
        var hotspotY = (height / 2);
        var gHotspot = mapToItem(myApp.stage.sprites, hotspotX, hotspotY);
        var gRefPoint = mapToItem(myApp.stage.sprites, hotspotX + 1, hotspotY);
        var dx = gRefPoint.x - gHotspot.x;
        var dy = gRefPoint.y - gHotspot.y;
        var gRotation = (Math.atan2(dy, dx) * 180 / Math.PI);
        var gScale = Math.sqrt((dx * dx) + (dy * dy));

        // Get current parent geometry in scene/global coordinates:
        var parentHotspotX = (newParent.width / 2);
        var parentHotspotY = (newParent.height / 2);
        var gParentHotspot = newParent.mapToItem(myApp.stage.sprites, parentHotspotX, parentHotspotY);
        var gParentRefPoint = newParent.mapToItem(myApp.stage.sprites, parentHotspotX + 1, parentHotspotY);
        var parentDx = gParentRefPoint.x - gParentHotspot.x;
        var parentDy = gParentRefPoint.y - gParentHotspot.y;
        var gParentRotation = (Math.atan2(parentDy, parentDx) * 180 / Math.PI);
        var gParentScale = Math.sqrt((parentDx * parentDx) + (parentDy * parentDy));

        // Reparent sprite:
        parent = null;
        parent = newParent

        // Move sprite to the same stage geometry as before reparenting:
        var newHotspot = parent.mapFromItem(myApp.stage.sprites, gHotspot.x, gHotspot.y);
        x = newHotspot.x - (sprite.width / 2);
        y = newHotspot.y - (sprite.height / 2);
        transRotation = gRotation - gParentRotation;
        transScaleX = transScaleY = gScale / gParentScale;

        // Store the geometry conversion in the fromKeyframe:
        getCurrentPositionKeyframe().effectiveKeyframe = createPositionKeyframe(spriteTime);
        _interpolatePosition(spriteTime);
    }

}
