import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import WebView 1.0

Rectangle {
    id: root
    color: myApp.style.dark

    WebView {
        id: webView
        onImageUrlChanged: {
            myApp.addImage(imageUrl)
            myApp.menuButton.checked = false;
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: 1000

        Column {
            width: childrenRect.width
            height: childrenRect.height
            Button {
                text: "Google image search"
                onClicked: webView.search();
            }

            RowLayout {
                width: parent.width
                Label {
                    text: "Autoplay"
                }
                Switch {
                    onCheckedChanged: myApp.stage.autoPlay = checked;
                }
            }

            Button {
                text: "Play on press"
                onClicked: webView.search();
            }
            Button {
                text: "Visible"
            }
            Button {
                text: "Opacity"
            }
            Button {
                text: "Delete keyframe"
            }
            Button {
                text: "Create keyframe"
            }
            TimelineSprites {
                width: root.width
                height: 300
            }
        }
    }
}
