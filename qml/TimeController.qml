import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    readonly property bool playing: userPlay || recordPlay;
    property bool recordPlay: false
    property bool userPlay: false
    onPlayingChanged: updatePlayAnimation();

    readonly property bool flicking: flickable ? flickable.flicking : false
    readonly property bool animating: flickable ? flickable.animating : false
    property FlickableMouseArea flickable: null;

    Connections {
        target: flickable
        onAnimatingChanged: updatePlayAnimation();
        onMomentumXUpdated: myApp.model.setTime(myApp.model.time - (flickable.momentumX * 0.1));
        onReleased:  {
            if (clickCount != 1 || myApp.model.hasSelection)
                return;
            userPlay = (myApp.model.time < myApp.model.endTime) ? !userPlay : false
        }
    }

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
        property real mpf: userPlay ? myApp.model.mpf : myApp.model.recordingMpf

        onTickChanged: {
            var tickTime = (new Date()).getTime();
            var flickAdjust = flickable ? -flickable.momentumX : 1
            var timeIncrement = ((tickTime - lastTickTime) / mpf) * flickAdjust
            var newTime = myApp.model.time + timeIncrement
            myApp.model.setTime(newTime);
            lastTickTime = tickTime;
            if (newTime > myApp.model.endTime + 1)
                userPlay = false;
        }
    }
}

