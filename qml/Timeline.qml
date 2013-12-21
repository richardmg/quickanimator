import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property Flickable flickable: flickable
    property var model: myApp.model.layers
    property var playStartTime: new Date()
    property real flickSpeed: 0.05

    property bool _playing: false

    clip: true

    TextArea {
        id: text
        anchors.fill: parent
        text: flickable.contentX * flickSpeed
    }

    Connections {
        target: myApp.model
        onTimeChanged: {
            if (mouseArea.pressed)
                return;
            flickable.contentX = myApp.model.time * flickSpeed;
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: 5000

        onContentXChanged: {
            if (mouseArea.pressed)
                myApp.model.setTime(contentX * flickSpeed);
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: {
            if (_playing) {
                myApp.model.setTime(flickable.contentX * flickSpeed);
                _play(false)
            }
        }

        onReleased: {
            if (_playing)
                _play(true)
        }
    }

    function togglePlay(play)
    {
        _playing = play;
        _play(_playing);
    }

    function _play(play)
    {
        var layers = myApp.model.layers;
        for (var i = 0; i < layers.length; ++i)
            layers[i].sprite.playing = play;
        animation.running = play;
    }

    NumberAnimation {
        id: animation
        property real tick: 0
        target: animation
        property: "tick"
        duration: 1000
        loops: Animation.Infinite
        from: 0
        to: 1

        onRunningChanged: {
            if (running)
                playStartTime = (myApp.model.time * myApp.model.msPerFrame) - (new Date()).getTime();
            else
                myApp.model.setTime(flickable.contentX * flickSpeed);
        }

        onTickChanged: {
            var ms = playStartTime + (new Date()).getTime();
            flickable.contentX = ms / (myApp.model.msPerFrame * flickSpeed);
        }
    }
}

