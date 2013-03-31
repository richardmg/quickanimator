import QtQuick 2.1
import QtQuick.Controls 1.0

ApplicationWindow {
    id: root
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
                TitleBar {
                    title: "Sprite"
                }
                TextField {
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
                onWidthChanged: spriteProps.width = width
                TitleBar {
                    title: "Keyframe"
                }
                TextField {
                    placeholderText: "State name"
                }
            }
            StoryBoard {
                width: 2 * parent.width / 3
                height: parent.height
            }
        }
    }
}
