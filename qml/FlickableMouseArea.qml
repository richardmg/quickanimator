import QtQuick 2.1
import QtQuick.Controls 1.0

MultiPointTouchArea {
    id: root
    property real momentumX: 0
    property real momentumY: 0
    property alias momentumRestX: momentumXAnimation.to
    property alias momentumRestY: momentumYAnimation.to
    property real friction: 0.3

    property int mouseX: 0
    property int mouseY: 0
    property bool pressed: false
    property bool flicking: false

    property TouchPoint activeTouchPoint: null
    touchPoints: [ TouchPoint { id: tp1; }, TouchPoint { id: tp2; } ]


    onPressed: {
        if (activeTouchPoint)
            return;

        if (root.contains(Qt.point(tp1.x, tp1.y)))
            activeTouchPoint = tp1;
        else if (root.contains(Qt.point(tp2.x, tp2.y)))
            activeTouchPoint = tp2;
    }

    onUpdated: {
        if (!activeTouchPoint)
            return;

        root.mouseX = activeTouchPoint.x
        root.mouseY = activeTouchPoint.y
        root.pressed = activeTouchPoint.pressed;
    }

    onReleased: {
        activeTouchPoint = null;
        pressed = false
    }

    MouseArea {
        anchors.fill: parent

        onPressedChanged: {
            root.mouseX = mouseX;
            root.mouseY = mouseY;
            root.pressed = pressed;
        }

        onPositionChanged: {
            root.mouseX = mouseX;
            root.mouseY = mouseY;
        }
    }

    property real _prevMouseX: 0
    property real _prevMouseY: 0

    onPressedChanged: {
        if (pressed) {
            momentumXAnimation.running = false;
            momentumYAnimation.running = false;
            _prevMouseX = mouseX;
            _prevMouseY = mouseY;
            momentumX = momentumXAnimation.to;
            momentumY = momentumYAnimation.to;
            flicking = true;
        } else {
            if (Math.abs(momentumX) > 2) {
                momentumXAnimation.from = momentumX
                momentumXAnimation.duration = 1000
                momentumXAnimation.restart();
            } else {
                momentumX = momentumRestX;
            }
            if (Math.abs(momentumY) > 2) {
                momentumYAnimation.from = momentumY
                momentumYAnimation.duration = 1000
                momentumYAnimation.restart();
            } else {
                momentumY = momentumRestY;
            }

            if (!momentumXAnimation.running && !momentumYAnimation.running)
                flicking = false;
        }
    }

    onMouseXChanged: {
        if (!root.pressed)
            return;
        momentumX = (mouseX - _prevMouseX) * friction;
        _prevMouseX = mouseX;
    }

    onMouseYChanged: {
        if (!root.pressed)
            return;
        momentumY = (mouseY - _prevMouseY) * friction
        _prevMouseY = mouseY;
    }

    NumberAnimation {
        id: momentumXAnimation
        target: root
        property: "momentumX"
        duration: 1000
        to: 0
        easing.type: Easing.OutQuad
        onToChanged: if (!running) root.momentumX = to
        onStopped: if (!momentumYAnimation.running) flicking = false
    }

    NumberAnimation {
        id: momentumYAnimation
        target: root
        property: "momentumY"
        to: 0
        easing.type: Easing.OutQuad
        onToChanged: if (!running) root.momentumY = to
        onStopped: if (!momentumXAnimation.running) flicking = false
    }
}

