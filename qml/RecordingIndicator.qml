import QtQuick 2.0

Rectangle {
    id: recordingIndicator
    opacity: myApp.timeline.opacity

    SequentialAnimation {
        running: model.hasSelection && stage.flickable && model.recording
        onRunningChanged: if (!running) recordingIndicator.opacity = Qt.binding(function() { return timeline.opacity })
        loops: Animation.Infinite
        PauseAnimation { duration: 1000 }
        PropertyAnimation {
            target: recordingIndicator
            property: "opacity"
            duration: 200
            easing.type: Easing.OutQuad
            to: 0.0
        }
        PauseAnimation { duration: 1000 }
        PropertyAnimation {
            target: recordingIndicator
            property: "opacity"
            duration: 200
            easing.type: Easing.InQuad
            to: 1
        }
    }
}
