import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    id: root

    property bool _playing: false

    Component.onCompleted: myApp.timeline = root
    color: myApp.style.dark

    TimelineCanvas {
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.bottomMargin: 2
    }

    FlickableMouseArea {
        id: flickable
        anchors.fill: parent
        property var pressStartTime: new Date()
        property real prevMouseX: 0
        property real prevMouseY: 0
        property real dragged: 0

        momentumRestX: _playing ? -1 : 0

        onFlickingChanged: {
            if (flicking) {
                pressStartTime = new Date();
                animation.running = false;
                dragged = 0;
            } else {
                togglePlay(_playing);
            }
        }

        onMomentumXChanged: {
            dragged += Math.abs(momentumX)
            myApp.model.setTime(myApp.model.time + (-momentumX * 20 / myApp.model.msPerFrame));
        }

        onClicked: togglePlay(!_playing);
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
        if (!flickable.flicking) {
            animation.lastTickTime = new Date();
            animation.running = play;
        }
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

