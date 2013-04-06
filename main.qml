import QtQuick 2.1
import QtQuick.Controls 1.0

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
            }
        }
        SplitView {
            width: parent.width
            height: parent.height / 3
            Column {
                id: keyframeProps
                width: parent.width / 3
                height: parent.height
                spacing: 5
                onWidthChanged: imageProps.width = width
                TitleBar {
                    title: "Keyframe"
                }
                TextField {
                    x: 3
                    placeholderText: "State name"
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
        layer.image.x = 50
        layer.image.y = 50
        stage.api.addLayer(layer)
        storyBoard.timeline.rows += 1
    }
}
