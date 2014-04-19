import QtQuick 2.1
import QtQuick.Controls 1.0

MultiPointTouchArea {
    id: root
    property real momentumX: 0
    property real momentumY: 0
    property alias momentumRestX: momentumXAnimation.to
    property alias momentumRestY: momentumYAnimation.to
    property real friction: 1

    property int mouseX: 0
    property int mouseY: 0
    property bool pressed: false
    property bool flicking: false

    signal clicked
    property var _pressTime
    property real _pressMouseX
    property real _pressMouseY

    property real _prevMouseX: 0
    property real _prevMouseY: 0
    property bool _mouseDetected: false

    property TouchPoint activeTouchPoint: null
    touchPoints: [ TouchPoint { id: tp1; }, TouchPoint { id: tp2; } ]

    onPressed: {
        if (activeTouchPoint || _mouseDetected)
            return;

        if (root.contains(Qt.point(tp1.x, tp1.y)))
            activeTouchPoint = tp1;
        else if (root.contains(Qt.point(tp2.x, tp2.y)))
            activeTouchPoint = tp2;
    }

    onUpdated: {
        if (activeTouchPoint || _mouseDetected)
            return;

        root.mouseX = activeTouchPoint.x
        root.mouseY = activeTouchPoint.y
        root.pressed = activeTouchPoint.pressed;
    }

    onReleased: {
        if (activeTouchPoint || _mouseDetected)
            return;

        activeTouchPoint = null;
        pressed = false
    }

    MouseArea {
        anchors.fill: parent

        onPressedChanged: {
            _mouseDetected = true;
            root.mouseX = mouseX;
            root.mouseY = mouseY;
            root.pressed = pressed;
        }

        onPositionChanged: {
            root.mouseX = mouseX;
            root.mouseY = mouseY;
        }

        onWheel: {
            flicking = true;
            momentumX = wheel.pixelDelta.x * friction;
            momentumY = wheel.pixelDelta.y * friction;
            animateMomentumToRest(0);
        }
    }

    onPressedChanged: {
        if (pressed) {
            momentumXAnimation.running = false;
            momentumYAnimation.running = false;
            _prevMouseX = mouseX;
            _prevMouseY = mouseY;
            momentumX = momentumXAnimation.to;
            momentumY = momentumYAnimation.to;
            flicking = true;

            _pressTime = (new Date()).getTime();
            _pressMouseX = mouseX;
            _pressMouseY = mouseY;
        } else {
            animateMomentumToRest(2);

            var click = (new Date().getTime() - _pressTime) < 300
                && Math.abs(mouseX - _pressMouseX) < 10
                && Math.abs(mouseY - _pressMouseY) < 10;

            if (click)
                root.clicked();
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

    function animateMomentumToRest(threshold)
    {
        if (Math.abs(momentumX) > threshold) {
            momentumXAnimation.from = momentumX
            momentumXAnimation.duration = 1000
            momentumXAnimation.restart();
        } else {
            momentumX = momentumRestX;
        }
        if (Math.abs(momentumY) > threshold) {
            momentumYAnimation.from = momentumY
            momentumYAnimation.duration = 1000
            momentumYAnimation.restart();
        } else {
            momentumY = momentumRestY;
        }

        if (!momentumXAnimation.running && !momentumYAnimation.running)
            flicking = false;
    }

    NumberAnimation {
        id: momentumXAnimation
        target: root
        property: "momentumX"
        duration: 1000
        to: 0
        easing.type: Easing.OutQuad
        onStopped: if (!momentumYAnimation.running) flicking = false
        onToChanged: {
            if (running) {
                from = momentumX
                restart();
            } else {
                root.momentumX = to;
            }
        }
    }

    NumberAnimation {
        id: momentumYAnimation
        target: root
        property: "momentumY"
        to: 0
        easing.type: Easing.OutQuad
        onStopped: if (!momentumXAnimation.running) flicking = false
        onToChanged: {
            if (running) {
                from = momentumY
                restart();
            } else {
                root.momentumY = to;
            }
        }
    }
}

