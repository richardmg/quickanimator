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
                    columns: 2

                    Label {
                        text: "state name:"
                        anchors.right: nameField.left
                        anchors.rightMargin: 5
                    }
                    TextField {
                        id: nameField
                    }
                    Label {
                        text: "x:"
                        anchors.right: xField.left
                        anchors.rightMargin: 5
                    }
                    SpinBox {
                        id: xField 
                        decimals: 3
                        onValueChanged: {
                            if (storyBoard.selectedLayer.image)
                                storyBoard.selectedLayer.image.x = value;
                        }
                        Connections {
                            target: storyBoard.selectedLayer ? storyBoard.selectedLayer.image : null;
                            onXChanged: xField.value = storyBoard.selectedLayer.image.x
                        }
                    }
                    Label {
                        text: "y:"
                        anchors.right: yField.left
                        anchors.rightMargin: 5
                    }
                    SpinBox {
                        id: yField 
                        value: item ? item.y : 0 
                        decimals: 3
                        onValueChanged: if (item && item.y != value) item.y = value;
                    }
                    Label {
                        text: "rotation:"
                        anchors.right: rotationField.left
                        anchors.rightMargin: 5
                    }
                    SpinBox {
                        id: rotationField 
                        value: item ? item.rotation.toFixed(3) : 0 
                        decimals: 3
                        onValueChanged: if (item && item.rotation != value) item.rotation = value;
                    }
                    Label {
                        text: "scale:"
                        anchors.right: scaleField.left
                        anchors.rightMargin: 5
                    }
                    SpinBox {
                        id: scaleField 
                        value: item ? item.scale.toFixed(3) : 0 
                        decimals: 3
                        onValueChanged: if (item && item.scale != value) item.scale = value;
                    }
                    Rectangle {
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
        storyBoard.addLayer(layer);
        storyBoard.selectLayer(layer.z, true);
    }
}
