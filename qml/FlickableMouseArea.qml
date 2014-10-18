import QtQuick 2.1
import QtQuick.Controls 1.0

MultiPointTouchArea {
    id: root
    property real momentumX: 0
    property real momentumY: 0
    property alias momentumRestX: momentumXAnimation.to
    property alias momentumRestY: momentumYAnimation.to

    property real mouseX: 0
    property real mouseY: 0
    property bool pressed: false
    property bool flicking: false

    signal momentumXUpdated
    signal momentumYUpdated
    signal clicked
    signal rightClicked

    property var _pressTime
    property real _pressMouseX
    property real _pressMouseY

    property real _prevMouseX: 0
    property real _prevMouseY: 0

    property TouchPoint activeTouchPoint: null
    touchPoints: [ TouchPoint { id: tp1; }, TouchPoint { id: tp2; } ]

    onPressed: {
        var rightmostTouchpoint =
              tp1.pressed && !tp2.pressed ? tp1
            : tp2.pressed && !tp1.pressed ? tp2
            : (tp1.x > tp2.x) ? tp1 : tp2;
        if (activeTouchPoint === rightmostTouchpoint)
            return;

        activeTouchPoint = rightmostTouchpoint;
        pressed = false;

// bug in MultiPointTouchArea: x, y is not updated onPressed :(
//        root.mouseX = activeTouchPoint.x
//        root.mouseY = activeTouchPoint.y
//        root.pressed = true
    }

    onReleased: {
        if (touchPoints.indexOf(activeTouchPoint) === -1)
            return
        activeTouchPoint = null;
        pressed = false;
    }

    onUpdated: {
        if (touchPoints.indexOf(activeTouchPoint) === -1)
            return
        root.mouseX = activeTouchPoint.x
        root.mouseY = activeTouchPoint.y
        root.pressed = true
        updateMomentum()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        enabled: Qt.platform.os === "osx"

        onPressedChanged: {
            if (pressedButtons === Qt.LeftButton || pressedButtons === Qt.NoButton) {
                root.mouseX = mouseX;
                root.mouseY = mouseY;
                root.pressed = pressed;
            }
        }

        onPositionChanged: {
            if (pressedButtons === Qt.LeftButton) {
                root.mouseX = mouseX;
                root.mouseY = mouseY;
            }
        }

        onWheel: {
            flicking = true;
            momentumX = wheel.pixelDelta.x
            momentumY = wheel.pixelDelta.y
            animateMomentumToRest(0);
        }

        onClicked: {
            if (mouse.button === Qt.RightButton)
                root.rightClicked();
        }

        onDoubleClicked: {
            if (mouse.button === Qt.RightButton)
                root.rightClicked();
        }
    }

    onPressedChanged: {
        if (pressed) {
            restartFlicking();
        } else {
            animateMomentumToRest(1);

            var click = (new Date().getTime() - _pressTime) < 300
                && Math.abs(mouseX - _pressMouseX) < 10
                && Math.abs(mouseY - _pressMouseY) < 10;

            if (click)
                root.clicked();
        }
    }

    function updateMomentum()
    {
        var prevMomentumX = momentumX;
        var prevMomentumY = momentumY;
        momentumX = mouseX - _prevMouseX
        momentumY = mouseY - _prevMouseY
        _prevMouseX = mouseX;
        _prevMouseY = mouseY;
        if (prevMomentumX === momentumX)
            momentumXUpdated()
        if (prevMomentumY === momentumY)
            momentumYUpdated()
    }

    onMomentumXChanged: momentumXUpdated()
    onMomentumYChanged: momentumYUpdated()

    function restartFlicking()
    {
        momentumXAnimation.running = false;
        momentumYAnimation.running = false;
        momentumX = momentumXAnimation.to;
        momentumY = momentumYAnimation.to;
        _prevMouseX = mouseX;
        _prevMouseY = mouseY;
        _pressTime = (new Date()).getTime();
        _pressMouseX = mouseX;
        _pressMouseY = mouseY;
        flicking = true;
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
        duration: 1000
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

