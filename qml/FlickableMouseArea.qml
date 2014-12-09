import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    property real momentumX: 0
    property real momentumY: 0
    property alias momentumRestX: momentumXAnimation.to
    property alias momentumRestY: momentumYAnimation.to
    property alias momentumXAnimationDuration: momentumXAnimation.duration
    property alias momentumYAnimationDuration: momentumYAnimation.duration
    property alias momentumXAnimationEasing: momentumXAnimation.easing
    property alias momentumYAnimationEasing: momentumYAnimation.easing
    property int splitAngle: -1 // [0, 90]

    property real mouseX: 0
    property real mouseY: 0
    property bool animating: false
    property bool flicking: false
    property bool isPressed: false

    property int touchCount: 0
    property alias acceptedButtons: mouseArea.acceptedButtons
    property int acceptedFlickButtons: acceptedButtons

    signal momentumXUpdated
    signal momentumYUpdated
    signal pressed(var mouseX, var mouseY)
    signal released(var mouseX, var mouseY, var clickCount)
    signal positionChanged(var mouseX, var mouseY)

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
    property var _updateTime
    property int _clickCount: 0
    property real _pressMouseX
    property real _pressMouseY
    property real _prevMouseX: 0
    property real _prevMouseY: 0
    property bool _momentumXStopped: false
    property bool _momentumYStopped: false

    MultiPointTouchArea {
        anchors.fill: parent
        enabled: myApp.touchUI
        property bool workAroundPosBug: false

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

            root.flicking = true;
            root.animating = true;

            workAroundPosBug = true;
            // bug in MultiPointTouchArea: x, y is not updated onPressed :(
            // updateMouse(activeTouchPoint.x, activeTouchPoint.y);
        }

        onReleased: {
            if (touchPoints.indexOf(activeTouchPoint) === -1)
                return
            if (!_momentumXStopped)
                root.mouseX = activeTouchPoint.x;
            if (!_momentumYStopped)
                root.mouseY = activeTouchPoint.y;
            if (workAroundPosBug)
                updatePressed(true)
            touchCount = touchPoints.length
            updatePressed(false)
            root.flicking = false;
            activeTouchPoint = null;
        }

        onUpdated: {
            if (touchPoints.indexOf(activeTouchPoint) === -1)
                return

            touchCount = touchPoints.length

            if (workAroundPosBug) {
                root.mouseX = activeTouchPoint.x;
                root.mouseY = activeTouchPoint.y;
                updatePressed(true)
                workAroundPosBug = false;
            }

            updateMouse(activeTouchPoint.x, activeTouchPoint.y);
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        enabled: !myApp.touchUI

        onPressedChanged: {
            if (pressedButtons & acceptedFlickButtons) {
                _momentumXStopped = false
                _momentumYStopped = false
                root.mouseX = mouseX;
                root.mouseY = mouseY;
                root.touchCount = (pressedButtons === Qt.LeftButton) ? 1 : 2;
                updatePressed(true)
            } else if (pressedButtons === Qt.NoButton) {
                if (!_momentumXStopped)
                    root.mouseX = mouseX;
                if (!_momentumYStopped)
                    root.mouseY = mouseY;
                updatePressed(false)
                root.touchCount = 0;
                root.flicking = false;
            }
        }

        onPositionChanged: {
            if (pressedButtons & acceptedFlickButtons)
                root.updateMouse(mouseX, mouseY);
        }

        onWheel: {
            updatePressed(true)
            updateMouse(root.mouseX + wheel.pixelDelta.x, root.mouseY + wheel.pixelDelta.y);
            wheelCleanupTimer.restart();
        }

        Timer {
            id: wheelCleanupTimer
            interval: 50
            onTriggered: {
                root._momentumXStopped = false;
                root._momentumYStopped = false;
                root.animating = false;
                root.flicking = false;
                updatePressed(false)
            }
        }
    }

    /////////////////////////////////////////////////////
    // MultiPointTouchArea / MouseArea agnostic functions
    /////////////////////////////////////////////////////

    function updatePressed(pressed)
    {
        if (pressed) {
            stopMomentumAnimation();
            _prevMouseX = mouseX;
            _prevMouseY = mouseY;
            var timeSinceLastPress = new Date().getTime() - _pressTime;
            if (timeSinceLastPress > 300)
                _clickCount = 0
            _pressTime = (new Date()).getTime();
            _pressMouseX = mouseX;
            _pressMouseY = mouseY;
            animating = true;
            flicking = true
            root.isPressed = true
            root.pressed(mouseX, mouseY)
        } else {
            var timeSinceUpdate = new Date().getTime() - _updateTime;
            var timeSincePress = new Date().getTime() - _pressTime;

            animateMomentumToRest(timeSinceUpdate < 100 ? 1 : Number.MAX_VALUE);

            var click = timeSincePress < 300
                    && Math.abs(mouseX - _pressMouseX) < 10
                    && Math.abs(mouseY - _pressMouseY) < 10;
            _clickCount = click ? _clickCount + 1 : 0;
            root.isPressed = false
            root.released(mouseX, mouseY, _clickCount);
        }
    }

    onMomentumXChanged: momentumXUpdated()
    onMomentumYChanged: momentumYUpdated()

    function updateMouse(mx, my)
    {
        if (!_momentumXStopped)
            mouseX = mx;
        if (!_momentumYStopped)
            mouseY = my;

        positionChanged(mx, my)

        _updateTime = (new Date()).getTime();
        var prevMomentumX = momentumX;
        var prevMomentumY = momentumY;
        var distx = mouseX - _prevMouseX
        var disty = mouseY - _prevMouseY

        _prevMouseX = mouseX;
        _prevMouseY = mouseY;

        var flickH = true;
        if (splitAngle !== -1) {
            var a = ((Math.atan2(distx, disty) / (2 * Math.PI)) * 360) - 90;
            flickH = (a > -splitAngle && a < splitAngle) || (a > -180 - splitAngle && a < -180 + splitAngle);
        }

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

    function stopMomentumAnimation()
    {
        momentumXAnimation.running = false;
        momentumYAnimation.running = false;
        momentumX = momentumXAnimation.to;
        momentumY = momentumYAnimation.to;
    }

    function animateMomentumToRest(threshold)
    {
        if (Math.abs(momentumX) > threshold && momentumXAnimationDuration !== 0) {
            momentumXAnimation.from = momentumX
            momentumXAnimation.duration = 1000
            momentumXAnimation.restart();
        } else {
            momentumX = momentumRestX;
        }

        if (Math.abs(momentumY) > threshold && momentumYAnimationDuration !== 0) {
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

