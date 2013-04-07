function StageClass() {
    var mousedown = false;
    var pressStartTime = 0;
    var pressStartPos = undefined;
    var currentAction = {};

    this.getAngleAndRadius = function(p1, p2)
    {
        var dx = p2.x - p1.x;
        var dy = p1.y - p2.y;
        return {
            angle: (Math.atan2(dx, dy) / Math.PI) * 180,
            radius: Math.sqrt(dx*dx + dy*dy)
        }; 
    }

    this.overlapsHandle = function(pos)
    {
        for (var i in storyBoard.selectedLayers) {
            var layer = storyBoard.layers[storyBoard.selectedLayers[i]]
            var image = layer.image
            var cx = image.x + (image.width / 2)
            var cy = image.y + (image.height / 2)
            var dx = pos.x - cx
            var dy = pos.y - cy
            var len = Math.sqrt((dx * dx) + (dy * dy))
            if (len < focusSize)
                return layer
        }
        return null;
    }

    this.pressStart = function(pos)
    {
        // start new layer operation, drag or rotate:
        mousedown = true;
        pressStartTime = new Date().getTime();
        pressStartPos = pos;

        if (storyBoard.selectedLayers.length !== 0) {
            var layer = this.overlapsHandle(pos);
            if (layer) {
                // start drag
                currentAction = {
                    layer: layer, 
                    dragging: true,
                    x: pos.x,
                    y:pos.y,
                };
            } else {
                // Start rotation
                var layer = storyBoard.layers[storyBoard.selectedLayers[0]]
                var center = { x: layer.image.x + (layer.image.width / 2), y: layer.image.y  + (layer.image.height / 2)};
                currentAction = this.getAngleAndRadius(center, pos);
                currentAction.rotating = true
            }
        }
    }

    this.pressDrag = function(pos)
    {
        // drag or rotate current layer:
        if (mousedown) {
            if (currentAction.selecting) {
                var layer = storyBoard.getLayerAt(pos, storyBoard.currentTime);
                if (layer && !layer.selected)
                    layer.select(true);
            } else if (storyBoard.selectedLayers.length !== 0) {
                if (currentAction.dragging) {
                    // continue drag
                    for (var i in storyBoard.selectedLayers) {
                        var image = storyBoard.layers[storyBoard.selectedLayers[i]].image;
                        image.x += pos.x - currentAction.x;
                        image.y += pos.y - currentAction.y;
                    }
                    currentAction.x = pos.x;
                    currentAction.y = pos.y;
                } else if (currentAction.rotating) {
                    // continue rotate
                    var layer = storyBoard.layers[storyBoard.selectedLayers[0]]
                    var center = { x: layer.image.x + (layer.image.width / 2), y: layer.image.y  + (layer.image.height / 2)};
                    var aar = this.getAngleAndRadius(center, pos);
                    for (var i in storyBoard.selectedLayers) {
                        var image = storyBoard.layers[storyBoard.selectedLayers[i]].image;
                        if (rotateFocusItems)
                            image.rotation += aar.angle - currentAction.angle;
                        if (scaleFocusItems)
                            image.scale *= aar.radius / currentAction.radius;
                    }
                    currentAction.angle = aar.angle;
                    currentAction.radius = aar.radius;
                }
            } else {
                var startSelect = (Math.abs(pos.x - pressStartPos.x) < 10 || Math.abs(pos.y - pressStartPos.y) < 10);
                currentAction.selecting = true;
            }
        }
    }

    this.pressEnd = function(pos)
    {
        mousedown = false;

        var click = (new Date().getTime() - pressStartTime) < 300 
            && Math.abs(pos.x - pressStartPos.x) < 10
            && Math.abs(pos.y - pressStartPos.y) < 10;

        if (click) {
            currentAction = {};
            var layer = storyBoard.getLayerAt(pos, storyBoard.currentTime);
            var select = layer && !layer.selected
            for (var i = storyBoard.selectedLayers.length - 1; i >= 0; --i)
                storyBoard.selectLayer(storyBoard.selectedLayers[i], false)
            if (select)
                storyBoard.selectLayer(layer.z, select)
        }
    }
}
