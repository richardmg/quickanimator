import QtQuick 2.1
import "save.anim.js" as TLD

Item {
    id: runtimeStage

    function walk() { start("walk"); }
    function run() { start("run"); }

    property bool paused: true
    property var global: new Object()

    property real fps: 60
    readonly property int ticksPerFrame: 5
//    property var sprites: [sprite1, sprite2]
    property var sprites: [sprite1]

    function start(name)
    {
        if (name === "walk") {
            setTime(0);
            paused = false;
        }
    }

    function setTime(newTime)
    {
        for (var i = 0; i < sprites.length; ++i)
            sprites[i].setTime(newTime);
    }

    onPausedChanged: {
        for (var i = 0; i < sprites.length; ++i)
            sprites[i].paused = paused;
        masterTimer.running = !paused;
    }

    Timer {
        id: masterTimer
        interval: 1000 / fps;
        repeat: true
        onTriggered: {
            for (var i = 0; i < sprites.length; ++i)
                sprites[i].tick();
        }
    }

    StageSprite {
        id: sprite1
        spriteIndex: 0
        timeline: TLD.sprites[spriteIndex].states
        Image { source: TLD.sprites[sprite1.spriteIndex].image }
    }

//    StageSprite {
//        id: sprite2
//        spriteIndex: 1
//        timeline: TLD.sprites[spriteIndex]
//        Image { source: "dummy.jpeg" }
//    }

    MouseArea {
        anchors.fill: parent
        onClicked: paused = !paused
    }

    width: 640
    height: 480
    Component.onCompleted: {
        walk();
    }
}
