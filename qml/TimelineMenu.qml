import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import WebView 1.0

Rectangle {
    id: root
    color: myApp.style.dark
    property alias interactionPlayButton: interactionPlayButton
    property alias googleButton: googleButton

    readonly property int space: 6
    clip: true

    WebView {
        id: webView
        onImageUrlChanged: {
            myApp.addImage(imageUrl)
            myApp.menuButton.checked = false;
        }
    }

    RadioButtonGroup {
        id: timelineGroup
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 2
        contentHeight: 1000

        Column {
            id: layout
            anchors.fill: parent
            spacing: 2
            MenuButton {
                id: googleButton
                text: "Google image search"
                onClicked: webView.search();
            }

            MenuButton {
                id: timelineModeButton
                text: "Timeline"
                checkable: true
            }

            MenuButton {
                id: continuousPlayButton
                text: "Continuous play"
                checkable: true
                checked: true
                parentMenuButton: timelineModeButton
                radioButtonGroup: timelineGroup
            }

            MenuButton {
                id: interactionPlayButton
                text: "Interaction play"
                checkable: true
                onCheckedChanged: myApp.stage.timelinePlay = checked;
                parentMenuButton: timelineModeButton
                radioButtonGroup: timelineGroup
            }

            MenuButton {
                id: drawMode
                text: "Draw mode"
                checkable: true
            }

            MenuButton {
                text: "Align"
                checkable: true
                parentMenuButton: drawMode
            }

            MenuButton {
                id: keyframeButton
                text: "Keyframe"
                checkable: true
            }

            MenuButton {
                text: "Delete keyframe"
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "Create keyframe"
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "x"
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "y"
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "width"
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "height"
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "scale"
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "rotation"
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "Visible"
                checkable: true
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "Opacity"
                checkable: true
                parentMenuButton: keyframeButton
            }

            MenuButton {
                text: "Interpolate"
                checkable: true
                checked: true
                parentMenuButton: keyframeButton
            }

            Rectangle {
                width: parent.width
                height: space
                color: "transparent"
            }

            MenuButton {
                id: undoButton
                text: "Undo"
            }

            MenuButton {
                id: redoButton
                text: "Redo"
            }

            MenuButton {
                id: trashcanButton
                text: "Trashcan"
            }

            Rectangle {
                width: parent.width
                height: space
                color: "transparent"
            }

            TimelineSprites {
                width: parent.width
            }

            Rectangle {
                width: parent.width
                height: root.height
                color: "white"
            }
        }
    }
}
