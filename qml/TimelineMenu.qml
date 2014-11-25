import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.2

Rectangle {
    id: root
    color: myApp.style.dark
    property alias interactionPlayButton: interactionPlayButton
    property alias googleButton: googleButton

    readonly property int space: 4
    clip: true

    property bool __speedSliderGuard: false

    property Component sliderStyle: SliderStyle {
        groove: Rectangle {
            color:"white"
            implicitHeight: control.height
            Label {
                x: 10
                anchors.verticalCenter: parent.verticalCenter
                text: control.text
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

    Flickable {
        anchors.fill: parent
        contentHeight: layout.height

        Column {
            id: layout
            width: parent.width
            height: childrenRect.height

            spacing: 2

            MenuButton {
                text: "Close"
                onClicked: root.visible = false
            }

            Rectangle {
                width: parent.width
                height: space
                color: "transparent"
            }

            MenuButton {
                id: googleButton
                text: "Google image search"
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
                id: slowDownSlider
                width: parent.width
                height: 40
                minimumValue: 200
                maximumValue: 3000
                value: maximumValue
                onValueChanged: {
//                    if (__speedSliderGuard)
//                        return
//                    __speedSliderGuard = true
//                    speedUpSlider.value = speedUpSlider.minimumValue
//                    myApp.model.msPerFrame = maximumValue - value + minimumValue
//                    __speedSliderGuard = false
                }
                property string text: "Slow down"
                style: sliderStyle
            }

            Slider {
                id: speedUpSlider
                width: parent.width
                height: 40
                minimumValue: 10
                maximumValue: 200
                value: minimumValue
                onValueChanged: {
                    if (__speedSliderGuard)
                        return
                    __speedSliderGuard = true
                    slowDownSlider.value = slowDownSlider.maximumValue
                    myApp.model.msPerFrame = maximumValue - value + minimumValue
                    __speedSliderGuard = false
                }
                property string text: "Speed up"
                style: sliderStyle
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
                height: space
                color: "transparent"
            }

            MenuButton {
                text: "Close"
                onClicked: root.visible = false
            }
        }

    }
}
