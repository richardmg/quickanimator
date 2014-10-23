import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    readonly property bool playing: userPlay || stagePlay;
    readonly property alias flicking: flickable.flicking
    readonly property alias animating: flickable.animating

    property bool stagePlay: false
    property bool userPlay: false

    FlickableMouseArea {
        id: flickable
        visible: !myApp.menuButton.visible || myApp.menuButton.pressed || myApp.simulator
        width: parent.width
        height: parent.height
        momentumRestX: playing ? -1 : 0
        momentumYAnimationDuration: 0
        splitAngle: 60
        acceptedButtons: Qt.RightButton

        onAnimatingChanged: updatePlayAnimation();
        onRightClicked: myApp.model.shiftUserInterfaceState();
        onMomentumXUpdated: myApp.model.setTime(myApp.model.time - (momentumX * 0.1));

        property bool rotated: false

        onMomentumYUpdated: {
            if (Math.abs(momentumY) > 8 && !rotated) {
                myApp.playMenu.rotate(momentumY > 0);
                rotated = true;
            } else if (momentumY !== 0 && Math.abs(momentumY) <= 4) {
                rotated = false;
            }
        }

        onPressedChanged: {
            if (pressed)
                return;
            rotated = false;
        }
    }

    onPlayingChanged: updatePlayAnimation();

    function updatePlayAnimation()
    {
        animation.lastTickTime = new Date();
        animation.running = playing && !flickable.animating;
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

