import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property alias to: flickAnimation.to
    signal flickChanged(real flick)

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        property real prevMouseX: 0
        property real momentum: 0

        onPressed: {
            flickAnimation.running = false;
            prevMouseX = mouseX;
            momentum = 0;
        }

        onReleased: {
            if (Math.abs(momentum) > 2)
                flick(momentum);
        }

        onMouseXChanged: {
            momentum = mouseX - prevMouseX;
            prevMouseX = mouseX;
            root.flickChanged(momentum);
        }
    }

    function flick(momentum)
    {
        flickAnimation.from = momentum
        flickAnimation.duration = 1000;
        flickAnimation.restart();
    }

    NumberAnimation {
        id: flickAnimation
        target: flickAnimation
        property: "flick"
        to: 0
        easing.type: Easing.OutExpo
        property real flick: 0
        onFlickChanged: root.flickChanged(flick);
    }
}

