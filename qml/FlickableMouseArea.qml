import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    property real momentumX: 0
    property real momentumY: 0
    property alias momentumRestX: momentumXAnimation.to
    property alias momentumRestY: momentumYAnimation.to

    property real mouseX: 0
    property real mouseY: 0
    property bool pressed: false
    property bool animating: false
    property bool flicking: false

    property alias acceptedButtons: mouseArea.acceptedButtons
    property int acceptedFlickButtons: acceptedButtons

    signal momentumXUpdated
    signal momentumYUpdated
    signal clicked
    signal rightClicked

    function stop()
    {
        momentumXAnimation.running = false;
        momentumYAnimation.running = false;
        momentumX = 0
        momentumY = 0
        animating = true;
        flicking = true
        _stopped = true;
    }

    property var _pressTime
    property real _pressMouseX
    property real _pressMouseY
    property real _prevMouseX: 0
    property real _prevMouseY: 0
    property bool _stopped: false

    MultiPointTouchArea {
        anchors.fill: parent
        enabled: myApp.model.touchUI

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
            _stopped = false;
            root.pressed = false;
            root.flicking = true;
            root.animating = true;

            // bug in MultiPointTouchArea: x, y is not updated onPressed :(
            //        root.mouseX = activeTouchPoint.x
            //        root.mouseY = activeTouchPoint.y
            //        root.pressed = true
        }

        onReleased: {
            if (touchPoints.indexOf(activeTouchPoint) === -1)
                return
            activeTouchPoint = null;
            root.pressed = false;
            root.flicking = false;
        }

        onUpdated: {
            if (touchPoints.indexOf(activeTouchPoint) === -1 || _stopped)
                return
            root.mouseX = activeTouchPoint.x
            root.mouseY = activeTouchPoint.y
            root.pressed = true
            root.updateMomentum()
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        enabled: !myApp.model.touchUI

        onPressedChanged: {
            if (pressedButtons & acceptedFlickButtons) {
                _stopped = false
                root.mouseX = mouseX;
                root.mouseY = mouseY;
                root.pressed = true;
            } else if (pressedButtons === Qt.NoButton) {
                root.pressed = false;
                root.flicking = false;
                root.updateMomentum()
            }
        }

        onPositionChanged: {
            if (_stopped)
                return
            if (pressedButtons & acceptedFlickButtons) {
                root.mouseX = mouseX;
                root.mouseY = mouseY;
                root.updateMomentum()
            }
        }

        onWheel: {
            if (_stopped) {
                if (wheel.pixelDelta.x === 0 && wheel.pixelDelta.y === 0)
                    _stopped = false
                return
            }

            animating = true;
            flicking = true
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


    /////////////////////////////////////////////////////
    // MultiPointTouchArea / MouseArea agnostic functions
    /////////////////////////////////////////////////////

    onPressedChanged: {
        if (pressed) {
            restartanimating();
        } else {
            animateMomentumToRest(1);

            var click = (new Date().getTime() - _pressTime) < 300
                    && Math.abs(mouseX - _pressMouseX) < 10
                    && Math.abs(mouseY - _pressMouseY) < 10;

            if (click)
                root.clicked();
        }
    }

    onMomentumXChanged: momentumXUpdated()
    onMomentumYChanged: momentumYUpdated()

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

    function restartanimating()
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
        animating = true;
        flicking = true
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

        if (!momentumXAnimation.running && !momentumYAnimation.running) {
            animating = false;
            flicking = false;
        }
    }

    NumberAnimation {
        id: momentumXAnimation
        target: root
        property: "momentumX"
        duration: 1000
        to: 0
        easing.type: Easing.OutQuad
        onStopped: if (!momentumYAnimation.running) {
                       animating = false;
                       flicking = false;
                   }
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
        onStopped: if (!momentumXAnimation.running) {
                       animating = false;
                       flicking = false;
                   }
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

