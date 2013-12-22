import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property Flickable flickable: flickable
    property var model: myApp.model.layers
    property real flickSpeed: 0.05

    property bool _playing: false

    clip: true

    TextArea {
        id: text
        anchors.fill: parent
        text: myApp.model.time + " : " + flickable.contentX * flickSpeed
    }

    Connections {
        target: myApp.model
        onTimeChanged: flickable.contentX = myApp.model.time / flickSpeed;
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: Number.MAX_VALUE
        onContentXChanged: if (!animation.running) myApp.model.setTime(contentX * flickSpeed);
        onMovingChanged: if (!moving && _playing) togglePlay(true);

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onPressed: animation.running = false;
            onReleased: if (_playing) togglePlay(true);
            onClicked: togglePlay(!_playing);
        }
    }

    function togglePlay(play)
    {
        _playing = play;
        animation.playStartTime = (myApp.model.time * myApp.model.msPerFrame) - (new Date()).getTime();
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
        property var playStartTime: new Date()

        onTickChanged: {
            var ms = playStartTime + (new Date()).getTime();
            myApp.model.setTime(ms / myApp.model.msPerFrame);
        }
    }
}

