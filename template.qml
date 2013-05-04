import QtQuick 2.1

Item {
    id: storyboard

    function walk(frames) { start("walk"); }
    function run(frames) { start("run"); }
    property var current: "walk"

    property var time: 0
    property real msPerFrame: 500
    
    property var _nextStateTime: 0

    // Create sprites:
    property list<Image> sprites: [
        Image {
            id: sprite1
            source: "dummy.jpeg";
            parent: storyboard
            property int currentStateIndex: 0
            property int timeToNextState: 0
            transitions: Transition {
                SequentialAnimation {
                    NumberAnimation {
                        properties: "x, y, width, height, rotation, scale"
                        duration: sprite1.timeToNextState
                    }
                    ScriptAction { script: nextStateTimer.restart(); }
                }
            }
            states: [
                State {
                    property int time: 0
                    PropertyChanges { target: sprite1; x: 0; y: 0 }
                },
                State {
                    property int time: 1
                    PropertyChanges { target: sprite1; x: 200; y: 50 }
                },
                State {
                    property int time: 4
                    PropertyChanges { target: sprite1; x: 100; y: 150; scale: 0.5 }
                }
            ]
        }//,
//        Image {
//            id: sprite2
//            source: "dummy.jpeg";
//            parent: storyboard
//            property int timeToNextState: 0
//            property int currentState: -1
//            transitions: Transition {
//                NumberAnimation {
//                    properties: "x, y, width, height, rotation, scale"
//                    duration: sprite2.timeToNextState
//                }
//            }
//            states: [
//                State {
//                    property int time: 0
//                    PropertyChanges { target: sprite2; x: 0; y: 100 }
//                }
//            ]
//        }
    ]

    Timer {
        id: nextStateTimer
        interval: 1
        onTriggered: updateAllSprites(false)
    }

    function updateAllSprites(immediate)
    {
        if (storyboard._nextStateTime === Number.MAX_VALUE) {
            // Done!
            return;
        }

        storyboard.time = storyboard._nextStateTime;
        print("update", storyboard.time);
        storyboard._nextStateTime = Number.MAX_VALUE;
        for (var i = 0; i < sprites.length; ++i)
            updateSprite(i, immediate);
    }

    function updateSprite(spriteIndex, immediatly)
    {
        var sprite = sprites[spriteIndex];
        var nextState = sprite.states[sprite.currentStateIndex];
        if (!nextState)
            return;

        // Check if this sprite has the shortest time until next state:
        var nextUpdateState = nextState;
        if (nextUpdateState.time == storyboard.time) {
            nextUpdateState = (sprite.states.length > sprite.currentStateIndex) ?
                sprite.states[sprite.currentStateIndex + 1] : null;
        }

        if (nextUpdateState && nextUpdateState.time < storyboard._nextStateTime) {
            // This sprite is next in line:
            storyboard._nextStateTime = nextUpdateState.time;
        }

        if (storyboard.time < nextState.time) {
            // The time has not reached nextState yet!
            return;
        }

        if (storyboard.time > nextState.time) {
            print("Whoops... we missed a state!");
            return;
        }

        sprite.currentStateIndex++;
        sprite.timeToNextState = immediatly ? 0 : nextState.time * msPerFrame;
        sprite.state = nextState.name;
    }

    function start(timelineName)
    {
        updateAllSprites(true);
    }

    width: 640
    height: 480
    Component.onCompleted: walk();
}
