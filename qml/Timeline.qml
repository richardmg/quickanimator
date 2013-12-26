import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property real flickSpeed: 0.05
    property bool _playing: false
    clip: true
    Component.onCompleted: myApp.timeline = root

    Connections {
        target: myApp.model
        onTimeChanged: if (!flickable.moving) flickable.contentX = myApp.model.time / flickSpeed;
    }

    TimelineCanvas {
        width: flickable.width
        height: parent.height
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: 10000
        contentHeight: 20 * myApp.style.cellHeight
        onContentXChanged: if (!animation.running) myApp.model.setTime(contentX * flickSpeed);
        onMovingChanged: if (!moving && _playing) togglePlay(true);
        pixelAligned: true
        Component.onCompleted: myApp.timelineFlickable = flickable

        MouseArea {
            id: mouseArea
            height: parent.height
            x: flickable.contentX
            width: flickable.width
            onPressed: animation.running = false;
            onReleased: if (_playing) togglePlay(true);
            onClicked: togglePlay(!_playing);
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 1
        height: parent.height
        color: myApp.style.dark
    }

    function togglePlay(play)
    {
        _playing = play;
        animation.lastTickTime = new Date();
        animation.running = play;
    }

    NumberAnimation {
        id: animation
        target: animation
        property: "tick"
        duration: 1000
        loops: Animation.Infinite
        from: 0
        to: 1

        property real tick: 0
        property var lastTickTime: new Date()

        onTickChanged: {
            var tickTime = (new Date()).getTime();
            var timeIncrement = (tickTime - lastTickTime) / myApp.model.msPerFrame;
            myApp.model.setTime(myApp.model.time + timeIncrement);
            lastTickTime = tickTime;
        }
    }
}

