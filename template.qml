import QtQuick 2.1

Item {
    id: storyboard

    function walk(frames) { start("walk"); }
    function run(frames) { start("run"); }

    property int time: 0
    property var current: "walk"

    // Create sprites:
    Image { id: sprite1; source: "dummy.jpeg" }
    Image { id: sprite2; source: "dummy.jpeg" }

    // Create one animation per sprite:
    NumberAnimation {
        id: sprite1Animation
        target: sprite1
        properties: "x, y, width, height, rotation, scale"
        duration: 500//<time to state>
    }

    NumberAnimation {
        id: sprite2Animation
        target: sprite2
        properties: "x, y, width, height, rotation, scale"
        duration: 500//<time to state>
    }

    // Create an array of states per timeline:
    property var timeline_walk: [
        { name: "state_0_0", time: 0, x: 0, y: 0 },
        { name: "state_1_0", time: 0, x: 0, y: 0 },
        { name: "state_1_5", time: 5, x: 10, y: 10 },
        { name: "state_0_10", time: 10, x: 100, y: 150 }
    ]

    Timer { id: nextStateTimer }

    function start(timelineName)
    {
        current = timelineName;
        var timeline = storyboard["timeline_" + timelineName];
        // - 1 move all sprites to states at time 0 in current
        // - get next state (and all states at the same time)
        // - 
    }

    width: 640
    height: 480
    Component.onCompleted: walk();
}
