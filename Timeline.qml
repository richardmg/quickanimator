import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property alias timelineCanvas: timelineCanvas
    property int selectedX: 0
    property int selectedY: 0
    property var model: myApp.model.layers

    property bool _block: false
    
    signal clicked
    signal doubleClicked

    onSelectedXChanged: if (!_block) myApp.model.setTime(selectedX);
    onSelectedYChanged: if (!playTimer.running) myApp.model.setFocusLayer(selectedY);
    onDoubleClicked: myApp.model.getState(myApp.model.layers[selectedY], selectedX);

    clip: true
    focus: true

    Connections {
        target: myApp.model
        onStatesUpdated: timelineCanvas.repaint();
        onLayersUpdated: timelineCanvas.repaint();
        onTimeChanged: if (!_block) {
            selectedX = myApp.model.time;
            playTimer.startTimeMs = (selectedX * myApp.model.msPerFrame) - (new Date()).getTime();
            var layers = myApp.model.layers;
            for (var i = 0; i < layers.length; ++i)
                layers[i].sprite.setTime(myApp.model.time);
        }
    }

    Keys.onPressed: {
        event.accepted = true;
        switch (event.key) {
            case Qt.Key_Backspace:
                myApp.model.removeCurrentState();
                break;
            case Qt.Key_Left:
                if (event.modifiers & Qt.ControlModifier) {
                    selectedX = 0;
                } else if (event.modifiers & Qt.ShiftModifier) {
                    var layer = myApp.model.layers[selectedY];
                    if (layer) {
                        var sprite = layer.sprite;
                        var keyframe = sprite.keyframes[sprite.keyframeIndex];
                        if (keyframe) {
                            if (keyframe.time == selectedX)
                                keyframe = sprite.keyframes[sprite.keyframeIndex - 1];
                            if (keyframe)
                                selectedX = keyframe.time
                        }
                    }
                } else if (selectedX > 0) {
                    selectedX--;
                }
                break;
            case Qt.Key_Right:
                if (event.modifiers & Qt.ControlModifier) {
                    selectedX = 50;
                } else if (event.modifiers & Qt.ShiftModifier) {
                    var layer = myApp.model.layers[selectedY];
                    if (layer) {
                        var sprite = layer.sprite;
                        var keyframe = sprite.keyframes[sprite.keyframeIndex + 1];
                        if (keyframe)
                            selectedX = keyframe.time
                    }
                } else {
                    selectedX++;
                }
                break;
            case Qt.Key_Up:
                if (event.modifiers & Qt.ShiftModifier)
                    selectedY = 0;
                 else if (selectedY > 0)
                    selectedY--;
                break;
            case Qt.Key_Down:
                selectedY++;
                break;
            case Qt.Key_R:
                if (event.modifiers & Qt.ControlModifier)
                    togglePlay(!playTimer.running);
                break;
            default:
                event.accepted = false;
        }
    }

    TimelineCanvas {
        id: timelineCanvas
        anchors.fill: parent
        model: root.model
        onClicked: {
            root.selectedX = mouseX;
            root.selectedY = mouseY;
            root.clicked()
        }
        onDoubleClicked: root.doubleClicked()
    }

    Rectangle {
        id: selectorLine
        color: Qt.darker(myApp.style.accent, 1.3);
        x: selectorHandle.x + (myApp.style.cellWidth / 2) - 1;
        width: 1
        height: parent.height - y
    }

    Rectangle {
        id: selectorHandle
        x: 1 + (selectedX * myApp.style.cellWidth) - timelineCanvas.flickable.contentX
        y: (selectedY * myApp.style.cellHeight) - timelineCanvas.flickable.contentY
        z: 10
        width: timelineCanvas.cellWidth - 2
        height: myApp.style.cellHeight - 1
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: Qt.rgba(0.9, 0.9, 0.9, 1.0)
            }
            GradientStop {
                position: 1.0;
                color: Qt.rgba(0.8, 0.8, 0.8, 1.0)
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        property bool acceptEvents: true

        onPressed: {
            root.focus = true
            var pos = mouseArea.mapToItem(selectorHandle, mouseX, mouseY)
            acceptEvents = (pos.x > 0 && pos.y > 0 && pos.x < selectorHandle.width && pos.y < selectorHandle.height)
            mouse.accepted = acceptEvents;
        }

        onMouseXChanged: {
            if (!acceptEvents) {
                mouse.accepted = false;
                return;
            }

            var pos = mouseArea.mapToItem(timelineCanvas.flickable.contentItem, mouseX, mouseY)
            var newX = Math.max(0, Math.floor(pos.x / myApp.style.cellWidth));
            if (newX != selectedX)
                selectedX = newX;
        }

        onMouseYChanged: {
            if (!acceptEvents) {
                mouse.accepted = false;
                return;
            }

            var pos = mouseArea.mapToItem(timelineCanvas.flickable.contentItem, mouseX, mouseY)
            var newY = Math.max(0, Math.floor(pos.y / myApp.style.cellHeight));
            if (newY != selectedY)
                selectedY = newY;
        }
    }

    function togglePlay(play)
    {
        var layers = myApp.model.layers;
        for (var i = 0; i < layers.length; ++i)
            layers[i].sprite.playing = play;

        if (play) {
            fps.fps2 = 0;
            playTimer.startTimeMs = (selectedX * myApp.model.msPerFrame) - (new Date()).getTime();
            myApp.model.setFocusLayer(-1);
        } else {
            myApp.model.setTime(selectedX);
            myApp.model.setFocusLayer(selectedY);
        }
        playTimer.running = play
    }

    Timer {
        id: fps
        interval: 1000
        repeat: true
        running: false//playTimer.running
        property int fps2: 0
        onTriggered: {
            print("fps:", fps2);
            fps2 = 0;
        }
    }

    Timer {
        id: playTimer
        interval: 1000 / 60
        repeat: true
        property var layers: myApp.model.layers
        property var startTimeMs: 0

        onTriggered: {
            fps.fps2++;
            var ms = startTimeMs + (new Date()).getTime();

            _block = true;
            var t = Math.floor(ms / myApp.model.msPerFrame);
            if (t != selectedX) {
                selectedX = t;
                myApp.model.time = t;
            }
            _block = false;
        }
    }
}

