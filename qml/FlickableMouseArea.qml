import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    property real momentumX: 0
    property real momentumY: 0
    property alias momentumRestX: momentumXAnimation.to
    property alias momentumRestY: momentumYAnimation.to
    property int splitAngle: -1 // [0, 90]

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

    function stopMomentumX()
    {
        momentumXAnimation.running = false;
        momentumX = 0
        _momentumXStopped = true;
        if (!momentumY) {
            animating = false;
            flicking = false;
        }
    }

    function stopMomentumY()
    {
        momentumYAnimation.running = false;
        momentumY = 0
        _momentumYStopped = true;
        if (momentumX) {
            animating = false;
            flicking = false;
        }
    }

    property var _pressTime
    property real _pressMouseX
    property real _pressMouseY
    property real _prevMouseX: 0
    property real _prevMouseY: 0
    property bool _momentumXStopped: false
    property bool _momentumYStopped: false

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
            _momentumXStopped = false;
            _momentumYStopped = false;
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
            if (touchPoints.indexOf(activeTouchPoint) === -1)
                return
            var px = activeTouchPoint.x
            var py = activeTouchPoint.y
            var a = Math.atan2(px, py)
            print((a / Math.PI * 2) * 360())
            if (!_momentumXStopped)
                root.mouseX = px
            if (!_momentumYStopped)
                root.mouseY = py
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
                _momentumXStopped = false
                _momentumYStopped = false
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
            if (pressedButtons & acceptedFlickButtons) {
                if (!_momentumXStopped)
                    root.mouseX = mouseX;
                if (!_momentumYStopped)
                    root.mouseY = mouseY;
                root.updateMomentum()
            }
        }

        onWheel: {
            if (wheel.pixelDelta.x === 0 && wheel.pixelDelta.y === 0) {
                _momentumXStopped = false;
                _momentumYStopped = false;
                animating = false;
                flicking = false;
                return;
            }

            animating = true;
            flicking = true
            if (!_momentumXStopped)
                momentumX = wheel.pixelDelta.x
            if (!_momentumYStopped)
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
        var distx = mouseX - _prevMouseX
        var disty = mouseY - _prevMouseY
        var a = ((Math.atan2(distx, disty) / (2 * Math.PI)) * 360) - 90;
        var flickH = (a > -splitAngle && a < splitAngle) || (a > -180 - splitAngle && a < -180 + splitAngle);

        _prevMouseX = mouseX;
        _prevMouseY = mouseY;

        if (splitAngle === -1 || flickH) {
            momentumX = distx;
            if (prevMomentumX === momentumX)
                momentumXUpdated();
        }

        if (splitAngle === -1 || !flickH) {
            momentumY = disty;
            if (prevMomentumY === momentumY)
                momentumYUpdated();
        }
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

