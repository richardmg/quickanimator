import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.2
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

    Flickable {
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.rightMargin: 2
        anchors.bottomMargin: 2
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

            Rectangle {
                width: parent.width
                height: space
                color: "transparent"
            }

            MenuButton {
                id: interactionPlayButton
                text: "Auto-record on move"
                checkable: true
                onCheckedChanged: myApp.stage.timelinePlay = checked;
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
                text: "Cut"
            }

            Rectangle {
                width: parent.width
                height: space
                color: "transparent"
            }

            Slider {
                id: speedSlider
                width: parent.width
                height: 40
                minimumValue: 0
                maximumValue: 2000
                value: 1850
                onValueChanged: myApp.model.msPerFrame = maximumValue - value + 10

                style: SliderStyle {
                    groove: Rectangle {
                        color:"white"
                        implicitHeight: control.height
                        Label {
                            x: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Speed"
                        }
                    }
                    handle: Rectangle {
                        anchors.centerIn: parent
                        color: myApp.style.dark
                        implicitWidth: 15
                        implicitHeight: control.height - 2
                        border.width: 2
                        border.color: "white"
                    }

                }
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
