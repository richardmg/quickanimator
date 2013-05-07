import QtQuick 2.1

Item {
    id: storyboard

    function walk(frameCount) { _start(0, frameCount); }
    function run(frameCount) { _start(4, frameCount); }
    property var current: "walk"

    property var time: 0
    property real msPerFrame: 500
    property var global: new Object()

    onTimeChanged: print("time:", time)

    // Create sprites:
    property list<Item> sprites: [
        StoryboardSprite {
            id: sprite1
            Image { source: "dummy.jpeg" }
            timeplan: [0, 1, 4]
            states: [
                State { PropertyChanges { target: sprite1; x: 0; y: 0 } },
                State { PropertyChanges { target: sprite1; x: 200; y: 50 } },
                State { PropertyChanges { target: sprite1; x: 100; y: 150; scale: 0.5 } }
            ]
        },
        StoryboardSprite {
            id: sprite2
            Image { source: "dummy.jpeg" }
            timeplan: [0, 2, 4]
            states: [
                State { PropertyChanges { target: sprite2; x: 0; y: 100 } },
                State { PropertyChanges { target: sprite2; x: 0; y: 0; rotation: 45 } },
                State { PropertyChanges { target: sprite2; x: 100; y: 150; scale: 0.5 }
                    property var after: function() {
                        if (!global.loop)
                            global.loop = 0;
                        if (global.loop++ < 3)
                            setTime(0);
                        else
                            run(0);
                    }
                }
            ]
        }
    ]

    function setTime(time)
    {
        for (var i = 0; i < sprites.length; ++i)
            sprites[i].setTime(time, -1);
    }

    function _start(time, timeSpan)
    {
        for (var i = 0; i < sprites.length; ++i)
            sprites[i].setTime(time, timeSpan);
    }

    width: 640
    height: 480
    Component.onCompleted: walk();
}
