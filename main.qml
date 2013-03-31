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
                id: spriteProps
                width: parent.width / 3
                onWidthChanged: keyframeProps.width = width
                height: parent.height
                spacing: 5
                TitleBar {
                    title: "Sprite"
                }
                TextField {
                    x: 3
                    placeholderText: "name"
                }
            }
            Rectangle {
                id: stage
                width: 2 * parent.width / 3
                height: parent.height
                color: "white"
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
                onWidthChanged: spriteProps.width = width
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

    function addSprite(url)
    {
        print("Add:", url)
        storyBoard.rows += 1
    }
}
