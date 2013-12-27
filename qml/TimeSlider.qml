import QtQuick 2.0

Rectangle {
    id: root
    width: 50
    height: 50
    color: "red"

    MultiPointTouchArea {
        id: mouseArea
        anchors.fill: parent

        touchPoints: [
            TouchPoint { onPressedChanged: myApp.msPerFrameFlickable.enabled = pressed },
            TouchPoint { onPressedChanged: myApp.msPerFrameFlickable.enabled = pressed }
        ]
    }
}
