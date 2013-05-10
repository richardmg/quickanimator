
.pragma library

var sprites = [
    [
        // walk (time: 0):
        { time: 0, x: 0, y: 0, rotation: 0, scale: 1 },
        { time: 1, x: 200, y: 0 },
        { time: 2, x: 100, y: 0, scale: 0.5 },
        // run (time: 5):
        { time: 5, x: 200, y: 200, rotation: 0},
        { time: 7, x: 200, y: 200, rotation: 180 }
    ],[
        // walk (time: 0):
        { time: 0, x: 0, y: 100, rotation: 0, scale: 1 },
        { time: 2, x: 0, y: 0, rotation: 45 },
        { time: 4, x: 100, y: 150, scale: 0.5, after: function(sprite) {
                if (!sprite.storyboard.global.loop)
                    sprite.storyboard.global.loop = 0;
                if (sprite.storyboard.global.loop++ < 1)
                    sprite.storyboard.setTime(0);
                else {
                    sprite.storyboard.run();
                }
            }
        },
        // run (time: 5):
        { time: 5, x: 100, y: 100, rotation: 180 },
        { time: 7, x: 100, y: 100, rotation: 360, after: function(sprite) {
                if (sprite.storyboard.global.loop-- > 0)
                    sprite.storyboard.setTime(5);
                else {
                    sprite.storyboard.walk(0);
                }
            }
        }
    ]
]
