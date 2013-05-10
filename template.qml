import QtQuick 2.1

Item {
    id: storyboard

    function walk(frameCount) { _start(0, frameCount); }
    function run(frameCount) { _start(5, frameCount); }
    property var current: "walk"

    property var time: 0
    property bool paused: false
    property var global: new Object()

    property real fps: 10
    readonly property int ticksPerFrame: 20
    property real tickTime: 0

    function setTime(newTime)
    {
        time = newTime;
        tickTime = time * ticksPerFrame;
        for (var i = 0; i < sprites.length; ++i)
            sprites[i].setTime(time);
    }

//    onPausedChanged: {
//        for (var i = 0; i < sprites.length; ++i)
//            sprites[i].paused = paused;
//    }

    function _start(time, timeSpan)
    {
        for (var i = 0; i < sprites.length; ++i)
            sprites[i].setTime(time, timeSpan);
        masterTimer.restart();
    }

    Timer {
        id: masterTimer
        interval: 1000 / fps;
        repeat: true
        onTriggered: {
            tickTime++;
            var t = Math.floor(tickTime / ticksPerFrame);
            if (time != t)
                time = t;
            for (var i = 0; i < sprites.length; ++i)
                sprites[i].tick(time);
        }
    }

    property list<Item> sprites: [
        StoryboardSprite {
            id: sprite1
            spriteIndex: 0
            storyboard: storyboard
            Image { source: "dummy.jpeg" }
        }
        ,
        StoryboardSprite {
            id: sprite2
            spriteIndex: 1
            storyboard: storyboard
            Image { source: "dummy.jpeg" }
        }
    ]

    MouseArea {
        anchors.fill: parent
        onClicked: paused = !paused
    }

    width: 640
    height: 480
    Component.onCompleted: walk(0);
}
