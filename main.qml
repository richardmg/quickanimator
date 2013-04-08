import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: window
    width: 640
    height: 480

    SplitView {
        orientation: Qt.Vertical
        anchors.fill: parent

        SplitView {
            width: parent.width
            height: 2 * parent.height / 3

            Column {
                id: imageProps
                width: parent.width / 3
                onWidthChanged: keyframeProps.width = width
                height: parent.height
                spacing: 5
                TitleBar {
                    title: "Image"
                }
                TextField {
                    x: 3
                    placeholderText: "name"
                }
            }
            Stage {
                id: stage
                width: 2 * parent.width / 3
                height: parent.height
                clip: true
                storyBoard: storyBoard
            }
        }
        SplitView {
            width: parent.width
            height: parent.height / 3
            Column {
                id: keyframeProps
                width: parent.width / 3
                height: parent.height
                onWidthChanged: imageProps.width = width
                spacing: 5
                TitleBar {
                    title: "Keyframe"
                }
                GridLayout {
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    rowSpacing: 2
                    Label {
                        text: "state name:"
                        Layout.row: 1
                        Layout.column:0
                        anchors.right: nameField.left
                        anchors.rightMargin: 5
                    }
                    TextField {
                        id: nameField
                        Layout.row: 1
                        Layout.column:1
                    }
                    Label {
                        text: "x:"
                        Layout.row: 2
                        Layout.column:0
                        anchors.right: xField.left
                        anchors.rightMargin: 5
                    }
                    TextField {
                        id: xField 
                        Layout.row: 2
                        Layout.column:1
                    }
                    Label {
                        text: "y:"
                        Layout.row: 3
                        Layout.column:0
                        anchors.right: yField.left
                        anchors.rightMargin: 5
                    }
                    TextField {
                        id: yField 
                        Layout.row: 3
                        Layout.column:1
                    }
                    Label {
                        text: "rotation:"
                        Layout.row: 4
                        Layout.column:0
                        anchors.right: rotationField.left
                        anchors.rightMargin: 5
                    }
                    TextField {
                        id: rotationField 
                        Layout.row: 4
                        Layout.column:1
                    }
                    Label {
                        text: "scale:"
                        Layout.row: 5
                        Layout.column:0
                        anchors.right: scaleField.left
                        anchors.rightMargin: 5
                    }
                    TextField {
                        id: scaleField 
                        Layout.row: 5
                        Layout.column:1
                    }
                    Rectangle {
                        Layout.row: 6
                        Layout.column: 1
                        Layout.columnSpan: 2
                        Layout.fillHeight: true
                    }
                }
            }
            StoryBoard {
                id: storyBoard
                width: 2 * parent.width / 3
                height: parent.height
            }
        }
    }

    Component {
        id: imageComponent
        Image { }
    }

    function addImage(url)
    {
        var layer = {}
        layer.image = imageComponent.createObject(stage.images)
        layer.image.source = "dummy.jpeg"
        storyBoard.addLayer(layer)
    }
}
