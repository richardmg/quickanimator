function StageClass(stage) {
    var selectedLayers = new Array
    var layers = new Array;

    var mousedown = false;
    var pressStartTime = 0;
    var pressStartPos = undefined;
    var currentAction = {};

    this.getAngleAndRadius = function(p1, p2)
    {
        var dx = p2.x - p1.x;
        var dy = p1.y - p2.y;
        return {
            angle: Math.atan2(dx, dy) - Math.PI/2,
            radius: Math.sqrt(dx*dx + dy*dy)
        }; 
    }

    this.getLayerAt = function(p)
    {
        for (var i=layers.length - 1; i>=0; --i) {
            var image = layers[i].image
            if (p.x >= image.x && p.x <= image.x + image.width
                && p.y >= image.y && p.y <= image.y + image.height)
                return layer
        }
    }

    this.overlapsHandle = function(pos)
    {
        for (var i in selectedLayers) {
            var layer = selectedLayers[i];
            var lpos = layer.canvasToLayer(pos);
            var image = layer.image
            if (lpos.x >= image.x-30 && lpos.x <= image.x+30
                    && lpos.y >= image.y-30 && lpos.y <= image.y+30)
                return layer;
        }
        return null;
    }

    this.pressStart = function(pos)
    {
        // start new layer operation, drag or rotate:
        mousedown = true;
        pressStartTime = new Date().getTime();
        pressStartPos = pos;

        if (selectedLayers.length !== 0) {
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
                var layer = selectedLayers[0];
                var center = { x: layer.image.x, y: layer.image.y };
                var lpos = layer.layerToCanvas(center);
                currentAction = this.getAngleAndRadius(lpos, pos);
                currentAction.rotating = true
            }
        }
    }

    this.pressDrag = function(pos)
    {
        // drag or rotate current layer:
        if (mousedown) {
            if (currentAction.selecting) {
                var layer = this.getLayerAt(pos);
                if (layer && !layer.selected) {
                    layer.select(true);
                    this.repaint();
                }
            } else if (selectedLayers.length !== 0) {
                if (currentAction.dragging) {
                    // continue drag
                    for (var i in selectedLayers) {
                        var image = selectedLayers[i].image;
                        image.x += pos.x - currentAction.x;
                        image.y += pos.y - currentAction.y;
                    }
                    currentAction.x = pos.x;
                    currentAction.y = pos.y;
                } else if (currentAction.rotating) {
                    // continue rotate
                    var layer = selectedLayers[0];
                    var center = { x: layer.image.x, y: layer.image.y };
                    var lpos = layer.layerToCanvas(center);
                    var aar = this.getAngleAndRadius(lpos, pos);
                    for (var i in selectedLayers) {
                        var image = selectedLayers[i].image;
                        image.rotation += aar.angle - currentAction.angle;
                        image.scale *= aar.radius / currentAction.radius;
                    }
                    currentAction.angle = aar.angle;
                    currentAction.radius = aar.radius;
                }
                this.repaint();
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
            var layer = this.getLayerAt(pos);
            if (!layer || !layer.selected)
                currentAction = {};
    //        this_canvas.callback.onClicked(layer);
        }
        this.repaint();
    }

    this.drawFocus = function(layer)
    {
        print("Draw focus not implemented!")
    }

    this.repaint = function()
    {
        for (var i in layers) {
            var layer = layers[i];
            if (layer.selected)
                drawFocus(layer);
        }
    }

    this.addLayer = function(layer)
    {
        layers.push(layer);
        layer.selected  = layer.selected || false;

        layer.canvasToLayer = function(p)
        {
            var g = this.getAngleAndRadius({x:layer.x, y:layer.y}, p);
            var angleNorm = g.angle - layer.rotation;
            return {
                x: layer.x + (Math.cos(angleNorm) * g.radius),
                y: layer.y + (Math.sin(angleNorm) * g.radius)
            }
        }

        layer.layerToCanvas = function(p)
        {
            var g = this.getAngleAndRadius({x:layer.x, y:layer.y}, p);
            var angleNorm = g.angle + layer.rotation;
            return {
                x: layer.x + (Math.cos(angleNorm) * g.radius),
                y: layer.y + (Math.sin(angleNorm) * g.radius)
            }
        }

        layer.containsPos = function(p, checkOpacity)
        {
            var image = layer.image;
            p = layer.canvasToLayer(p);
            var dx = image.scale * image.width/2;
            var dy = image.scale * image.height/2;
            if ((p.x >= image.x-dx && p.x <= image.x + dx)
                    && (p.y >= image.y-dy && p.y <= image.y+dy)) {
                // todo: get pixel, check for opacity
                if (checkOpacity === true)
                    return true
                else
                    return true;
            }
            return false;
        }

        layer.select = function(select)
        {
            if (select === layer.selected)
                return;
            layer.selected = select;

            if (select) {
                selectedLayers.push(layer);
            } else {
                var index = selectedLayers.indexOf(layer);
                selectedLayers.splice(index, 1);
            }
        }

        layer.remove = function()
        {
            layers.splice(layer.getZ(), 1);
            if (layer.selected) {
                var i = selectedLayers.indexOf(layer);
                selectedLayers.splice(i, 1);
            }
            this.repaint();
        }

        layer.setZ = function(z)
        {
            z = Math.max(0, Math.min(layers.length - 1, z));
            var currentZ = layer.getZ();
            if (z === currentZ)
                return;
            layers.splice(currentZ, 1);
            layers.splice(z, 0, layer);
        }

        layer.getZ = function()
        {
            return layers.indexOf(layer);
        }

        return layer;
    }
}
