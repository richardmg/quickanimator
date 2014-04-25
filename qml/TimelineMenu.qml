import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import WebView 1.0

Rectangle {
    id: root
    color: myApp.style.dark
    property alias autoPlayButton: autoPlayButton
    property alias googleButton: googleButton

    readonly property int space: 6

    WebView {
        id: webView
        onImageUrlChanged: {
            myApp.addImage(imageUrl)
            myApp.menuButton.checked = false;
        }
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
                id: autoPlayButton
                text: "Auto play"
                checkable: true
                onCheckedChanged: myApp.stage.autoPlay = checked;
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
