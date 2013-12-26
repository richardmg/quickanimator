import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property real flickSpeed: 0.05
    property bool _playing: false
    clip: true
    Component.onCompleted: myApp.timeline = root

    TimelineCanvas {
        width: root.width
        height: parent.height
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        property var pressStartTime: new Date()
        property real prevMouseX: 0
        property real prevMouseY: 0
        property real dragged: 0
        property real momentum: 0

        property real flickTime: 0
        NumberAnimation {
            id: flickAnimation
            target: mouseArea
            property: "flickTime"
            easing.type: Easing.OutExpo
        }
        onFlickTimeChanged: myApp.model.setTime(flickTime);

        onPressed: {
            flickAnimation.stop();
            animation.running = false;
            prevMouseX = mouseX;
            prevMouseY = mouseY;
            pressStartTime = new Date();
            momentum = 0;
            dragged = 0;
        }

        onReleased: {
            if (Math.abs(momentum) > 1) {
                flickAnimation.from = myApp.model.time;
                flickAnimation.to = myApp.model.time + (momentum / 2);
                flickAnimation.duration = 1000;
                flickAnimation.restart();
            } else {
                var click = (new Date().getTime() - pressStartTime) < 300 && dragged < 20;
                togglePlay(click ? !_playing : _playing);
            }
        }

        onMouseXChanged: {
            var xDiff = prevMouseX - mouseX;
            var yDiff = prevMouseY - mouseY;
            dragged += Math.abs(xDiff) + Math.abs(yDiff)
            momentum = xDiff;
            prevMouseX = mouseX;
            prevMouseY = mouseY;

            myApp.model.setTime(myApp.model.time + (xDiff * flickSpeed));
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

