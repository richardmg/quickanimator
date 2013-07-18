import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property alias timelineCanvas: timelineCanvas
    property int selectedX: 0
    property int selectedY: 0
    property var model
    
    signal clicked
    signal doubleClicked

    clip: true
    focus: true

    Keys.onPressed: {
        event.accepted = true;
        switch (event.key) {
            case Qt.Key_Backspace:
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
}

