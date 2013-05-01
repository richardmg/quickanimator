import QtQuick 2.1

Item {
    id: storyboard

    function walk(frames) { start("walk"); }
    function run(frames) { start("run"); }
    property var current: "walk"

    property int time: 0
    property real msPerFrame: 500

    // Create sprites:
    property list<Image> sprites: [
        Image { source: "dummy.jpeg"; parent: storyboard },
        Image { source: "dummy.jpeg"; parent: storyboard }
    ]

    // Create one animation per sprite:
    property list<NumberAnimation> animations: [
        NumberAnimation {
            target: sprites[0]
            properties: "x, y, width, height, rotation, scale"
            duration: 500//<time to state>
        },
        NumberAnimation {
            target: sprites[1]
            properties: "x, y, width, height, rotation, scale"
            duration: 500//<time to state>
        }
    ]

    // Create an array of states per timeline:
    property var timeline_walk: [
        { spriteNr: 0, time: 0, x: 0, y: 0 },
        { spriteNr: 1, time: 0, x: 0, y: 100 },
        { spriteNr: 1, time: 5, x: 10, y: 10 },
        { spriteNr: 0, time: 10, x: 100, y: 150 }
    ]

    Timer { id: nextStateTimer }

    function start(timelineName)
    {
        current = timelineName;
        var timeline = storyboard["timeline_" + timelineName];

        // Move all sprites to states at time 0:
        for (var i = 0; i < timeline.length; ++i) {
            var state = timeline[i];
            if (state.time != 0)
                break;
            var sprite = sprites[state.spriteNr];
            sprite.x = state.x;
            sprite.y = state.y;
        }

        // Get next state (and all states at the same time)
        var nextStateTime = state.time;
        for (; i < timeline.length; ++i) {
            state = timeline[i];
            animations[state.spriteNr].duration = state.time * msPerFrame;
            sprite = sprites[state.spriteNr];
            sprite.x = state.x;
            sprite.y = state.y;
        }

    }

    width: 640
    height: 480
    Component.onCompleted: walk();
}
