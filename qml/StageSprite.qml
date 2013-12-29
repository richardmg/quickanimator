import QtQuick 2.1

Item {
    id: sprite

    property real anchorX: childrenRect.width / 2
    property real anchorY: childrenRect.height / 2
    property alias transRotation: tRotation.angle
    property alias transScaleX: tScale.xScale
    property alias transScaleY: tScale.yScale

    transform: [
        Scale { id: tScale; xScale: 1; yScale: 1; origin.x: anchorX; origin.y: anchorY },
        Rotation { id: tRotation; angle: 0; origin.x: anchorX; origin.y: anchorY }
    ]

    property QtObject model: parent 
    property var keyframes: new Array()
    property int keyframeIndex: 0

    property real spriteTime: 0
    property string name: "keyframe"

    property var _fromState
    property var _toState
    property bool _invalidCache: true

    function getKeyframe(time)
    {
        var intTime = Math.floor(time);
        return (intTime >= _fromState.time && intTime < _toState.time)
                ? getCurrentKeyframe() : _getKeyframeBinarySearch(intTime);
    }

    function getCurrentKeyframe()
    {
        _updateToAndFromState(spriteTime);
        return _fromState;
    }

    function addKeyframe(keyframe)
    {
        var index = keyframes.length === 0 ? 0 : getKeyframe(keyframe.time).volatileIndex + 1;
        keyframes.splice(index, 0, keyframe);
        myApp.model.testAndSetEndTime(keyframe.time);
        _invalidCache = true;
    }

    function createKeyframe(time)
    {
        return {
            time:time,
            parent:null,
            sprite:sprite,
            x:sprite.x,
            y:sprite.y,
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

    function synch()
    {
        _updateToAndFromState()
//        changeParent(keyframe.parent);
        _fromState.x = x;
        _fromState.y = y;
        _fromState.z = z;
        _fromState.anchorX = anchorX;
        _fromState.anchorY = anchorY;
        _fromState.rotation = transRotation;
        _fromState.scale = transScaleX;
        _fromState.opacity = opacity;
    }

    function removeKeyframe(keyframe)
    {
        keyframes.splice(keyframes.indexOf(keyframe), 1);
        _invalidCache = true;
        setTime(spriteTime);
    }

    function setTime(time)
    {
        _updateToAndFromState(time);
        spriteTime = time;
        if (!myApp.model.inLiveDrag)
            _interpolate(spriteTime);
    }

    function _interpolate(time)
    {
        var effectiveKeyframe = _fromState.effectiveKeyframe ? _fromState.effectiveKeyframe : _fromState;
        if (_toState.time === effectiveKeyframe.time) {
            x = effectiveKeyframe.x;
            y = effectiveKeyframe.y;
            anchorX = effectiveKeyframe.anchorX;
            anchorY = effectiveKeyframe.anchorY;
            transScaleX = transScaleY = effectiveKeyframe.scale;
            transRotation = effectiveKeyframe.rotation;
            opacity = effectiveKeyframe.opacity;
        } else {
            var effectiveKeyframeMs = effectiveKeyframe.time * model.msPerFrame
            var advanceMs = (spriteTime * model.msPerFrame) - effectiveKeyframeMs;
            x = _interpolated(effectiveKeyframe.x, _toState.x, advanceMs, "linear");
            y = _interpolated(effectiveKeyframe.y, _toState.y, advanceMs, "linear");
            z = _interpolated(effectiveKeyframe.z, _toState.z, advanceMs, "linear");
            anchorX = _interpolated(effectiveKeyframe.anchorX, _toState.anchorX, advanceMs, "linear");
            anchorY = _interpolated(effectiveKeyframe.anchorY, _toState.anchorY, advanceMs, "linear");
            transScaleX = transScaleY = _interpolated(effectiveKeyframe.scale, _toState.scale, advanceMs, "linear");
            transRotation = _interpolated(effectiveKeyframe.rotation, _toState.rotation, advanceMs, "linear");
            opacity = _interpolated(effectiveKeyframe.opacity, _toState.opacity, advanceMs, "linear");
        }
    }

    function _interpolated(from, to, advanceMs, curve)
    {
        // Ignore curve for now:
        var fromStateMs = _fromState.time * model.msPerFrame
        var totalTimeBetweenStatesMs = (_toState.time * model.msPerFrame) - fromStateMs;
        return from + (((to - from) / totalTimeBetweenStatesMs) * advanceMs);
    }

    function _updateToAndFromState(time)
    {
        var intTime = Math.floor(time);
        _invalidCache = _invalidCache || !_fromState || !_toState || intTime < _fromState.time || intTime >= _toState.time;
        if (_invalidCache) {
            _fromState = _getKeyframeBinarySearch(intTime);
            keyframeIndex = _fromState.volatileIndex;
            _toState = (keyframeIndex === keyframes.length - 1) ? _fromState : keyframes[keyframeIndex + 1];
            _invalidCache = false;

            // Set parent:
            for (var i = _fromState.volatileIndex; i >= 0; i--) {
                var p = keyframes[i].parent;
                if (p) {
                    break;
                }
            }
            parent = p ? p : parent.hasOwnProperty("spriteTime") ? parent.parent : parent;
        }
    }

    function _getKeyframeBinarySearch(time)
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
            if (i === high || time < keyframes[i + 1].time)
                break;
            low = i + 1
        }
        var state = keyframes[i];
        state.volatileIndex = i;
        return state;
    }

    function changeParent(newParent)
    {
        if (parent === newParent)
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
        var currentKeyframe = getCurrentKeyframe();
        var effectiveKeyframe = createKeyframe(currentKeyframe.time);
        effectiveKeyframe.parent = newParent;
        currentKeyframe.effectiveKeyframe = effectiveKeyframe;
        if (!myApp.model.inLiveDrag)
            _interpolate(spriteTime);
    }

}
