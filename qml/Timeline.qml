import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    id: root

    readonly property bool playing: _timelinePlay || stagePlay;

    property bool stagePlay: false
    property bool _timelinePlay: false

    focus: true
    Keys.onReleased: {
        if (event.key === Qt.Key_Space) {
            _timelinePlay = !_timelinePlay
            updatePlayAnimation();
        }
    }

    Component.onCompleted: {
        myApp.timeline = root
        forceActiveFocus()
    }

    color: myApp.style.dark

    TimelineCanvas {
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.bottomMargin: 2
    }

    FlickableMouseArea {
        id: flickable
        anchors.fill: parent
        friction: 0.1
        momentumRestX: playing ? -1 : 0
        onFlickingChanged: updatePlayAnimation();
        onMomentumXChanged: myApp.model.setTime(myApp.model.time + (-momentumX * 20 / myApp.model.msPerFrame));

        onClicked: {
            _timelinePlay = !_timelinePlay;
            updatePlayAnimation();
        }
    }

    onPlayingChanged: updatePlayAnimation();

    function updatePlayAnimation()
    {
        animation.lastTickTime = new Date();
        animation.running = playing && !flickable.flicking;
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

