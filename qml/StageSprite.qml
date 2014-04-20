import QtQuick 2.1

Item {
    id: sprite

    x: parent.width / 2
    y: parent.height / 2

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

    property var _fromState
    property var _toState
    property bool _invalidCache: true

    objectName: "unknown sprite"

    onChildrenRectChanged: {
        // for image loaded over the net, this will happen late
        anchorX = childrenRect.width / 2;
        anchorY = childrenRect.height / 2;
        for (var j = 0; j < keyframes.length; ++j) {
            var keyframe = keyframes[j];
            keyframe.anchorX = anchorX;
            keyframe.anchorY = anchorY;
        }
    }

    function setTime(time)
    {
        _updateToAndFromState(time);
        spriteTime = time;
        if (!myApp.model.inLiveDrag)
            _interpolate(spriteTime);
    }

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

    function removeKeyframe(keyframe)
    {
        keyframes.splice(keyframes.indexOf(keyframe), 1);
        _invalidCache = true;
        setTime(spriteTime);
    }

    function createKeyframe(time)
    {
        return {
            time:time,
            sprite:sprite,
            name:objectName + "," + time,
            x:sprite.x,
            y:sprite.y,
            z:sprite.z,
            anchorX: tScale.origin.x,
            anchorY: tScale.origin.y,
            width:sprite.width,
            height:sprite.height,
            rotation:transRotation,
            scale:transScaleX,
            opacity:sprite.opacity,
            visible: sprite.visible
        };
    }

    function _createKeyframeRelativeToParent(time, keyframeParent)
    {
        // Create a keyframe from the current sprite geometry
        // described relative to keyframeParent rather than actual parent:
        var currentKeyframe = getCurrentKeyframe();

        if (keyframeParent === parent)
            return _fromState.reparentKeyframe ? _fromState.reparentKeyframe : _fromState;

        var commonParent = myApp.stage.sprites;

        // Get current sprite geometry in commonParent coordinates:
        var hotspotX = (width / 2);
        var hotspotY = (height / 2);
        var gHotspot = mapToItem(commonParent, hotspotX, hotspotY);
        var gRefPoint = mapToItem(commonParent, hotspotX + 1, hotspotY);
        var dx = gRefPoint.x - gHotspot.x;
        var dy = gRefPoint.y - gHotspot.y;
        var gRotation = (Math.atan2(dy, dx) * 180 / Math.PI);
        var gScale = Math.sqrt((dx * dx) + (dy * dy));

        // Get keyframeParent geometry in commonParent coordinates:
        var itemHotspotX = (keyframeParent.width / 2);
        var itemHotspotY = (keyframeParent.height / 2);
        var gItemHotspot = keyframeParent.mapToItem(commonParent, itemHotspotX, itemHotspotY);
        var gItemRefPoint = keyframeParent.mapToItem(commonParent, itemHotspotX + 1, itemHotspotY);
        var itemDx = gItemRefPoint.x - gItemHotspot.x;
        var itemDy = gItemRefPoint.y - gItemHotspot.y;
        var gItemRotation = (Math.atan2(itemDy, itemDx) * 180 / Math.PI);
        var gItemScale = Math.sqrt((itemDx * itemDx) + (itemDy * itemDy));

        // Translate sprite to keyframeParent, preserving rotation and scale:
        var translatedHotspot = keyframeParent.mapFromItem(commonParent, gHotspot.x, gHotspot.y);
        var translatedKeyframe = createKeyframe(time);
        translatedKeyframe.parent = keyframeParent;
        translatedKeyframe.x = translatedHotspot.x - (sprite.width / 2);
        translatedKeyframe.y = translatedHotspot.y - (sprite.height / 2);
        translatedKeyframe.rotation = gRotation - gItemRotation;
        translatedKeyframe.scale = gScale / gItemScale;

        return translatedKeyframe;
    }

    function synchReparentKeyframe(changedSprite)
    {
        // Since changedSprite has changed, all descandant of it has changed as well (relative
        // to Stage, not parent). As such, we need to synch their keyframes left-side, so that
        // they end up with the geometry they now got upon reparenting.
        _updateToAndFromState()
        if (!_fromState.reparentKeyframe || _fromState.time !== changedSprite._fromState.time)
            return;

        var p = getKeyframeParent(_fromState.volatileIndex - 1);
        var translated = _createKeyframeRelativeToParent(_fromState.time, p);
        _fromState.x = translated.x;
        _fromState.y = translated.y;
        _fromState.scale = translated.scale;
        _fromState.rotation = translated.rotation;
    }

    function _interpolate(time)
    {
        var keyframe = _fromState.reparentKeyframe ? _fromState.reparentKeyframe : _fromState;
        visible = keyframe.visible;
        if (!visible)
            return;

        if (_toState.time === keyframe.time) {
            x = keyframe.x;
            y = keyframe.y;
            anchorX = keyframe.anchorX;
            anchorY = keyframe.anchorY;
            transScaleX = transScaleY = keyframe.scale;
            transRotation = keyframe.rotation;
            opacity = keyframe.opacity;
        } else {
            var reparentKeyframeMs = keyframe.time * model.msPerFrame
            var advanceMs = (spriteTime * model.msPerFrame) - reparentKeyframeMs;
            x = _interpolated(keyframe.x, _toState.x, advanceMs, "linear");
            y = _interpolated(keyframe.y, _toState.y, advanceMs, "linear");
            z = _interpolated(keyframe.z, _toState.z, advanceMs, "linear");
            anchorX = _interpolated(keyframe.anchorX, _toState.anchorX, advanceMs, "linear");
            anchorY = _interpolated(keyframe.anchorY, _toState.anchorY, advanceMs, "linear");
            transScaleX = transScaleY = _interpolated(keyframe.scale, _toState.scale, advanceMs, "linear");
            transRotation = _interpolated(keyframe.rotation, _toState.rotation, advanceMs, "linear");
            opacity = _interpolated(keyframe.opacity, _toState.opacity, advanceMs, "linear");
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
        if (!_invalidCache)
            return;

        _invalidCache = false;
        _fromState = _getKeyframeBinarySearch(intTime);
        keyframeIndex = _fromState.volatileIndex;
        if (keyframeIndex === keyframes.length - 1) {
            _toState = _fromState;
        } else {
            _toState = keyframes[keyframeIndex + 1];
            _toState.volatileIndex = keyframeIndex + 1;
        }

        var p = getKeyframeParent(_fromState.volatileIndex);
        if (p.parent === sprite) {
            // Sprites cannot be children of each other
            p.parent = null;
        }
        parent = p;
    }

    function getKeyframeParent(keyframeIndex)
    {
        for (var i = keyframeIndex; i >= 0; --i) {
            var reparentKeyframe = keyframes[i].reparentKeyframe;
            if (reparentKeyframe) {
                var p = reparentKeyframe.parent;
                break;
            }
        }
        // fixme: find root parent by searching
        // up, instead of relying on myApp.stage.sprites
        return p ? p : myApp.stage.sprites;
    }

//    onParentChanged: {
//        print("------");
//        if (parent)
//            print(objectName, "is child of", parent.objectName);
//        else
//            print(objectName, "is parented out!");
//        console.trace();
//    }

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

        var currentKeyframe = getCurrentKeyframe();
        if (getKeyframeParent(currentKeyframe.volatileIndex - 1) === newParent)
            currentKeyframe.reparentKeyframe = null;
        else
            currentKeyframe.reparentKeyframe = _createKeyframeRelativeToParent(currentKeyframe.time, newParent);

        // Reparent sprite:
        parent = null;
        parent = newParent

        if (!myApp.model.inLiveDrag)
            _interpolate(spriteTime);
    }

}
