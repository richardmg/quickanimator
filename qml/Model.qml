import QtQuick 2.1

import FileIO 1.0

QtObject {
    id: root
    property real time: 0
    property int endTime: 0

    property var sprites: new Array
    property bool hasSelection: false
    property var selectedSprites: new Array

    // Milliseconds Per Frame (MPF)
    property real targetMpf: 200
    property real mpf: targetMpf
    property real recordingMpf: targetMpf
    property bool recording: false

    signal spritesUpdated(var removedSprite, var addedSprite)
    signal selectedSpritesUpdated(var unselectedSprite, var selectedSprite)
    signal keyframesUpdated(var sprite)
    signal parentHierarchyChanged(var sprite)

    property bool recordsPositionX: true
    property bool recordsPositionY: true
    property bool recordsRotation: false
    property bool recordsScale: false
    property bool recordsAnchorX: false
    property bool recordsAnchorY: false
    property bool recordsOpacity: false
    property bool recordsCut: false
    property bool recordsCutAll: false

    function clearRecordState()
    {
        recordsPositionX = false;
        recordsPositionY = false;
        recordsRotation = false;
        recordsScale = false;
        recordsAnchorX = false;
        recordsAnchorY = false;
        recordsOpacity = false;
        recordsCut = false;
        recordsCutAll = false;
    }

    function newMovie()
    {
        unselectAllSprites();
        keyframesUpdated(null);

        for (var i in sprites)
            sprites[i].destroy();

        sprites = new Array;
        setTime(0);
        endTime = 0;
    }

    function callbackKeyframeAdded(sprite, keyframe)
    {
        if (keyframe.time > endTime)
            endTime = keyframe.time;

        keyframesUpdated(sprite);

        for (var i in sprites)
            sprites[i].synchReparentKeyframe(sprite);
    }

    function callbackKeyframeRemoved(sprite, keyframe)
    {
// fixme: recalculate endTime
//        if (keyframe.time > endTime)
//            endTime = keyframe.time;

        keyframesUpdated(sprite);

        for (var i in sprites)
            sprites[i].synchReparentKeyframe(sprite);
    }

    function testAndSetEndTime(time)
    {
        if (time <= endTime)
            return;
        root.endTime = time;
    }

    function setTime(time)
    {
        root.time = Math.max(0, time);
        for (var i in sprites)
            sprites[i].setTime(time);
    }

    function addSprite(sprite)
    {
        unselectAllSprites();
        sprites.push(sprite);
        sprite.selected = false;

        // There should always be a keyframe at time 0 that can
        // never be deleted (it simplifies algorithms elsewhere)
        var keyframe = sprite.createKeyframe(0)
        sprite.addKeyframe(keyframe);
        sprite.setTime(time);
        sprite.parentChanged.connect(function() { if (root) root.parentHierarchyChanged(sprite); });

        if (time !== 0) {
            // Make it look like the layer appears at 'time' in the scene
            keyframe.visible = false;
            keyframe = sprite.createKeyframe(time)
            sprite.addKeyframe(keyframe);
        }

        selectSprite(sprite, true);
        spritesUpdated(-1, sprites.length);
        keyframesUpdated(sprite);
    }

    function unselectAllSprites()
    {
        for (var i in selectedSprites) {
            var sprite = selectedSprites[i];
            sprite.selected = false;
        }
        var unselectedSprites = selectedSprites;
        selectedSprites = new Array;
        hasSelection = false;
        for (i = 0; i < unselectedSprites.length; ++i)
            selectedSpritesUpdated(sprites.indexOf(unselectedSprites[i]), -1);
    }

    function selectSprite(sprite, select)
    {
        if (select === sprite.selected)
            return;
        sprite.selected = select;
        if (select) {
            selectedSprites.push(sprite)
            var index = sprites.indexOf(sprite);
            hasSelection = selectedSprites.length !== 0
            selectedSpritesUpdated(-1, index);
        } else {
            selectedSprites.splice(selectedSprites.indexOf(sprite), 1);
            index = sprites.indexOf(sprite);
            hasSelection = selectedSprites.length !== 0
            selectedSpritesUpdated(index, -1);
        }
    }
    
    function removeSprite(layer)
    {
        var index = layer.indexOf(layer);
        sprites.splice(index, 1);
        if (layer.selected) {
            selectedSprites.splice(selectedSprites.indexOf(layer), 1);
            selectedSpritesUpdated(layer.indexOf(layer), -1);
            hasSelection = selectedSprites.length !== 0
        }
        spritesUpdated(index, -1); 
    }

    function getSpriteIndentLevel(layer)
    {
        var indent = 0;
        var sprite = layer.sprite;
        while (sprite && sprite.parent !== myApp.stage.sprites) {
            indent++;
            sprite = sprite.parent;
        }
        return indent;
    }

    function descendantCount(index)
    {
        // Return number of levels that the sub
        // tree pointed to by index contains:
        var level = getSpriteIndentLevel(sprites[index]);
        for (var lastDescendantIndex = index + 1; lastDescendantIndex < sprites.length; ++lastDescendantIndex) {
            if (getSpriteIndentLevel(sprites[lastDescendantIndex]) <= level)
                break;
        }
        return lastDescendantIndex - index - 1;
    }

    function changeSpriteParent(index, targetIndex, targetIsSibling)
    {
        // Remove the layer to be moved out of
        // sprites and resolve key information:
        var spriteCount = descendantCount(index) + 1;
        var spriteTree = sprites.splice(index, spriteCount);
        if (targetIndex > index)
            targetIndex -= spriteCount;

        var layer = spriteTree[0];
        var parentSprite = targetIsSibling ? sprites[targetIndex].parentSprite : sprites[targetIndex];
        var newLevel = parentSprite ? getSpriteIndentLevel(parentSprite) + 1 : 0;
        var insertLevel = targetIsSibling ? newLevel + 1 : newLevel;

        for (var insertIndex = targetIndex + 1; insertIndex < sprites.length; ++insertIndex) {
            if (getSpriteIndentLevel(sprites[insertIndex]) < insertLevel)
                break;
        }

        for (var i = spriteTree.length - 1; i >= 0; --i)
            sprites.splice(insertIndex, 0, spriteTree[i]);
        layer.parentSprite = parentSprite;

        // Store the parent change (but not the geometry changes that will occur):
        var keyframe = getOrCreateKeyframe(layer);
        keyframe.parent = parentSprite ? parentSprite.sprite : myApp.stage.sprites;

        // Reparent sprite:
        layer.sprite.changeParent(keyframe.parent);
    }

    function setSpriteIndex(oldIndex, newIndex)
    {
        var layer = sprites[oldIndex]
        newIndex = Math.max(0, Math.min(sprites.length - 1, newIndex));
        if (newIndex === oldIndex)
            return;
        sprites.splice(oldIndex, 1);
        sprites.splice(newIndex, 0, layer);
    }

    property FileIO file: FileIO { source: "save.anim.js" }

    function saveJSON()
    {
        var f = ".pragma library\n\nvar sprites = [\n{ image: 'dummy.jpeg', keyframes: [\n";

        for (var i = 0; i < sprites.length; ++i) {
            var sprite = sprites[i];
            var keyframes = sprite.keyframes;
            for (var j = 0; j < keyframes.length; ++j) {
                var s = keyframes[j];
                f += "   { time: " + s.time
                + ", x: " + s.x.toFixed(2)
                + ", y: " + s.y.toFixed(2)
                + ", z: " + s.z.toFixed(2)
                + ", rotation: " + s.rotation.toFixed(2)
                + ", scale: " + s.scale.toFixed(2)
                + ", opacity: " + s.opacity.toFixed(2)
                + ", name: '" + s.name + "'"
                + " }"
                if (j < keyframes.length - 1)
                    f += ",\n"
            }
            f += (i < sprites.length - 1) ? "\n]},{ image: 'dummy.jpeg', keyframes: [\n" : "\n]}\n";
        }
        f += "]\n";

        file.write(f);
    }
}

