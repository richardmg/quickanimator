import QtQuick 2.1

Item {
    id: storyboards

    function walk(frames) { start(walk); }
    function run(frames) { start(run); }

    property int time: 0
    property QtObject current: walk

    Image { id: sprite1 }
    Image { id: sprite2 }

    NumberAnimation {
        id: sprite1Animation
        target: sprite1
        properties: "x, y, width, height, rotation, scale"
        duration: <time to state>
    }

    NumberAnimation {
        id: sprite2Animation
        target: sprite2
        properties: "x, y, width, height, rotation, scale"
        duration: <time to state>
    }

    QtObject {
        id: walk
        property var timeline: [
            { name: "state_0_0", time: 0, x: 0, y: 0 },
            { name: "state_1_0", time: 0, x: 0, y: 0 },
            { name: "state_1_5", time: 5, x: 10, y: 10 },
            { name: "state_0_10", time: 10, x: 100, y: 150 }
        ]
    }

    Timer {
        id: nextStateTimer
    }

    function start(storyBoard)
    {
        // - 1 move all sprites to states at time 0 in current
        // - get next state (and all states at the same time)
        // - 
    }

}
