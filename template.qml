import QtQuick 2.1

Item {
    id: storyboard

    function walk(frames) { start("walk"); }
    function run(frames) { start("run"); }
    property var current: "walk"

    property int time: 0
    property real msPerFrame: 500
    
    property int _nextStateSpriteIndex: 0
    property int _nextStateTime: 0

    // Create sprites:
    property list<Image> sprites: [
        Image {
            id: sprite1
            source: "dummy.jpeg";
            parent: storyboard
            property int stateNr: 0
            property int timeToNextState: 0
            transitions: Transition {
                NumberAnimation {
                    properties: "x, y, width, height, rotation, scale"
                    duration: sprite1.timeToNextState
                }
            }
            states: [
                State {
                    property int time: 0
                    PropertyChanges { target: sprite1; x: 0; y: 0 }
                },
                State {
                    property int time: 2
                    PropertyChanges { target: sprite1; x: 200; y: 50 }
                }
            ]
        },
        Image {
            id: sprite2
            source: "dummy.jpeg";
            parent: storyboard
            property int timeToNextState: 0
            transitions: Transition {
                NumberAnimation {
                    properties: "x, y, width, height, rotation, scale"
                    duration: sprite2.timeToNextState
                }
            }
            states: [
                State {
                    property int time: 0
                    PropertyChanges { target: sprite2; x: 0; y: 100 }
                }
            ]
        }
    ]

    Timer {
        id: nextStateTimer
        onTriggered: {
            // Move all sprites to first state:
            for (var i = 0; i < sprites.length; ++i) {
                var sprite = sprites[i];
                var state = sprite.states[0];
                sprite.timeToNextState = state.time * msPerFrame;
                sprite.state = state.name;
                if (sprite.states.length > 1) {
                    var time = sprite.states[1].time;
                    print(storyboard._nextStateTime)
                    if (time > storyboard._nextStateTime) {
                        storyboard._nextStateSpriteIndex = i;
                        storyboard._nextStateTime = time;
                    }
                }
            }

            // Prepare for next state:
            if (storyboard._nextStateTime > 0) {
                nextStateTimer.interval = storyboard._nextStateTime * msPerFrame;
                nextStateTimer.start();
            }
        }
    }

    function start(timelineName)
    {
        // Move all sprites to first state:
        for (var i = 0; i < sprites.length; ++i) {
            var sprite = sprites[i];
            var state = sprite.states[0];
            sprite.timeToNextState = state.time * msPerFrame;
            sprite.state = state.name;
            if (sprite.states.length > 1) {
                var time = sprite.states[1].time;
                print(storyboard._nextStateTime)
                if (time > storyboard._nextStateTime) {
                    storyboard._nextStateSpriteIndex = i;
                    storyboard._nextStateTime = time;
                }
            }
        }

        // Prepare for next state:
        if (storyboard._nextStateTime > 0) {
            nextStateTimer.interval = storyboard._nextStateTime * msPerFrame;
            nextStateTimer.start();
        }
    }

    width: 640
    height: 480
    Component.onCompleted: walk();
}
