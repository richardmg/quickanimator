
.pragma library

var sprites = [
    [
        // walk (time: 0):
        { time: 0, x: 0, y: 0, rotation: 0, scale: 1, opacity: 1 },
        { time: 1, x: 200, y: 0, rotation: 0, scale: 1, opacity: 1 },
        { time: 2, x: 100, y: 0, rotation: 0, scale: 1, opacity: 1 }
    ],[
        // walk (time: 0):
        { time: 0, x: 200, y: 0, rotation: 0, scale: 1, opacity: 1 },
        { time: 1, x: 200, y: 200, rotation: 0, scale: 1, opacity: 1 },
        { time: 2, x: 200, y: 100, rotation: 0, scale: 1, opacity: 1 },
        { time: 4, x: 200, y: 100, rotation: 180, scale: 1.5, opacity: 0.5, after:
            function(sprite) {
                sprite.stage.setTime(0);
            }
        }
    ]
]
