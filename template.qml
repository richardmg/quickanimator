import QtQuick 2.1

Item {
    id: storyboard

    function walk(frames) { start("walk"); }
    function run(frames) { start("run"); }
    property var current: "walk"

    property var time: 0
    property real msPerFrame: 500

    // Create sprites:
    property list<Item> sprites: [
        StoryboardSprite {
            id: sprite1
            Image { source: "dummy.jpeg" }
            states: [
                State { property int time: 0; PropertyChanges { target: sprite1; x: 0; y: 0 } },
                State { property int time: 1; PropertyChanges { target: sprite1; x: 200; y: 50 } },
                State { property int time: 4; PropertyChanges { target: sprite1; x: 100; y: 150; scale: 0.5 } }
            ]
        },
        StoryboardSprite {
            id: sprite2
            Image { source: "dummy.jpeg" }
            states: [
                State { property int time: 0; PropertyChanges { target: sprite2; x: 0; y: 100 } },
                State { property int time: 2; PropertyChanges { target: sprite2; x: 0; y: 0; rotation: 45 } },
                State { property int time: 4; PropertyChanges { target: sprite2; x: 100; y: 150; scale: 0.5 } }
            ]
        }
    ]

    function start(timelineName)
    {
        for (var i = 0; i < sprites.length; ++i) {
            var sprite = sprites[i];
            var nextState = sprite.states[0];
            sprite.state = nextState.name;
        }
    }

    width: 640
    height: 480
    Component.onCompleted: walk();
}
