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

        ColumnLayout {
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
                text: "Delete keyframe"
            }

            MenuButton {
                text: "Create keyframe"
            }

            Rectangle {
                width: parent.width
                height: space
                color: "transparent"
            }

            MenuButton {
                text: "Visible"
                checkable: true
            }

            MenuButton {
                text: "Opacity"
                checkable: true
            }

            Rectangle {
                width: parent.width
                height: space
                color: "transparent"
            }

            TimelineSprites {
                width: parent.width
                Layout.fillHeight: true
            }
        }
    }
}
