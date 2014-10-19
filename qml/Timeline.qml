import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    readonly property bool playing: userPlay || stagePlay;
    readonly property alias flicking: flickable.flicking

    property bool stagePlay: false
    property bool userPlay: false

    Component.onCompleted: {
        myApp.timeline = root
    }

    TimelineCanvas {
        width: parent.width
        height: 20
    }

    FlickableMouseArea {
        id: flickable
        width: parent.width
        height: parent.height
        momentumRestX: playing ? -1 : 0
        onAnimatingChanged: updatePlayAnimation();
        onMomentumXUpdated: updateTime()
        onMomentumYUpdated: updateTime()

//        onClicked: userPlay = !userPlay;
        onRightClicked: myApp.model.shiftUserInterfaceState();

        function updateTime()
        {
            var r = Math.sqrt(momentumX * momentumX + momentumY * momentumY);
            r = momentumX < 0 ? -r : r;
            myApp.model.setTime(myApp.model.time - (r * 0.04));
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

