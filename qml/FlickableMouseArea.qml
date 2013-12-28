import QtQuick 2.1
import QtQuick.Controls 1.0

MouseArea {
    id: root
    property real momentumX: 0
    property real momentumY: 0
    property alias momentumRestX: momentumXAnimation.to
    property alias momentumRestY: momentumYAnimation.to
    property real friction: 0.3

    function flicking()
    {
        // Function instead of property since overridden onReleased
        // might be called before flicking property is updated:
        return pressed || momentumXAnimation.running || momentumYAnimation.running;
    }

    property real _prevMouseX: 0
    property real _prevMouseY: 0

    onPressed: {
        momentumXAnimation.running = false;
        momentumYAnimation.running = false;
        _prevMouseX = mouseX;
        _prevMouseY = mouseY;
        momentumX = momentumXAnimation.to;
        momentumY = momentumYAnimation.to;
    }

    onReleased: {
        if (Math.abs(momentumX) > 2) {
            momentumXAnimation.from = momentumX
            momentumXAnimation.duration = 1000
            momentumXAnimation.restart();
        }
        if (Math.abs(momentumY) > 2) {
            momentumYAnimation.from = momentumY
            momentumYAnimation.duration = 1000
            momentumYAnimation.restart();
        }
    }

    onMouseXChanged: {
        momentumX = (mouseX - _prevMouseX) * friction
        _prevMouseX = mouseX;
    }

    onMouseYChanged: {
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
    }

    NumberAnimation {
        id: momentumYAnimation
        target: root
        property: "momentumY"
        to: 0
        easing.type: Easing.OutQuad
        onToChanged: if (!running) root.momentumY = to
    }
}

