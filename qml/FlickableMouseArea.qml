import QtQuick 2.1
import QtQuick.Controls 1.0

MouseArea {
    id: root
    property real momentum: 0
    property alias to: momentumAnimation.to

    property real _prevMouseX: 0

    onPressed: {
        momentumAnimation.running = false;
        _prevMouseX = mouseX;
        momentum = 0;
    }

    onReleased: {
        if (Math.abs(momentum) > 2) {
            momentumAnimation.from = momentum
            momentumAnimation.duration = 1000;
            momentumAnimation.restart();
        }
    }

    onMouseXChanged: {
        momentum = mouseX - _prevMouseX;
        _prevMouseX = mouseX;
    }

    NumberAnimation {
        id: momentumAnimation
        target: root
        property: "momentum"
        to: 0
        easing.type: Easing.OutExpo
    }
}

