import QtQuick 2.0

MultiTouchButton {
    id: recordButton
    text: ""
    onClicked: myApp.model.recording = !myApp.model.recording

    Rectangle {
        width: 1
        height: parent.height
        anchors.right: parent.right
        color: myApp.style.timelineline
    }

    Rectangle {
        id: bulb
        width: 20
        height: 20
        radius: 20
        anchors.centerIn: parent
        color: myApp.model.recording ? "#ff2020" : "#552020"
        SequentialAnimation {
            running: myApp.model.recording
            loops: Animation.Infinite
            PauseAnimation { duration: 3000 }
            PropertyAnimation {
                target: bulb
                property: "opacity"
                duration: 500
                easing.type: Easing.OutQuad
                to: 0.3
            }
            PropertyAnimation {
                target: bulb
                property: "opacity"
                duration: 500
                easing.type: Easing.InQuad
                to: 1
            }
        }
    }
}
