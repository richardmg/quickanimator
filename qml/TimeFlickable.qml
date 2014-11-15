import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    readonly property bool playing: userPlay || stagePlay;
    property bool flicking: flickable ? flickable.flicking : false
    property bool animating: flickable ? flickable.animating : false

    property FlickableMouseArea flickable: null;

    property bool stagePlay: false
    property bool userPlay: false

    Connections {
        target: flickable
        onAnimatingChanged: updatePlayAnimation();
        onMomentumXUpdated: myApp.model.setTime(myApp.model.time - (flickable.momentumX * 0.1));
    }

    onPlayingChanged: updatePlayAnimation();

    function updatePlayAnimation()
    {
        animation.lastTickTime = new Date();
        animation.running = playing && (!flickable || !flickable.animating)
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
            var flickAdjust = flickable ? -flickable.momentumX : 0
            var timeIncrement = ((tickTime - lastTickTime) / myApp.model.msPerFrame) * flickAdjust
            myApp.model.setTime(myApp.model.time + timeIncrement);
            lastTickTime = tickTime;
        }
    }
}

