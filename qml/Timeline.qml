import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property bool _playing: false

    clip: true
    Component.onCompleted: myApp.timeline = root

    TimelineCanvas {
        width: root.width
        height: parent.height
    }

    FlickableMouseArea {
        id: flickable
        anchors.fill: parent
        property var pressStartTime: new Date()
        property real prevMouseX: 0
        property real prevMouseY: 0
        property real dragged: 0

        momentumRestX: _playing ? -1 : 0

        onPressed: {
            animation.running = false;
            pressStartTime = new Date();
            dragged = 0;
        }

        onReleased: {
            if (flicking()) {
                animation.lastTickTime = new Date();
                animation.running = true;
            } else {
                var click = (new Date().getTime() - pressStartTime) < 300 && dragged < 20;
                togglePlay(click ? !_playing : _playing);
            }
        }

        onMouseXChanged: {
            dragged += Math.abs(momentumX)
            myApp.model.setTime(myApp.model.time + (-momentumX * 20 / myApp.model.msPerFrame));
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 1
        height: parent.height
        color: "red"
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
            var timeIncrement = ((tickTime - lastTickTime) / myApp.model.msPerFrame) * -flickable.momentumX;
            myApp.model.setTime(myApp.model.time + timeIncrement);
            lastTickTime = tickTime;
        }
    }
}

