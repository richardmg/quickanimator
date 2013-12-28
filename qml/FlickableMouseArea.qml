import QtQuick 2.1
import QtQuick.Controls 1.0

MouseArea {
    id: root
    property real momentumX: 0
    property real momentumY: 0
    property alias momentumRestX: momentumXAnimation.to
    property alias momentumRestY: momentumYAnimation.to
    property real dampning: 0.5

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
            momentumXAnimation.duration = Math.max(500, Math.abs(momentumRestX - momentumX) * 50)
            momentumXAnimation.restart();
        }
        if (Math.abs(momentumY) > 2) {
            momentumYAnimation.from = momentumY
            momentumYAnimation.duration = Math.max(500, Math.abs(momentumRestY - momentumY) * 50)
            momentumYAnimation.restart();
        }
    }

    onMouseXChanged: {
        momentumX = (mouseX - _prevMouseX) * dampning;
        _prevMouseX = mouseX;
    }

    onMouseYChanged: {
        momentumY = (mouseY - _prevMouseY) * dampning;
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

