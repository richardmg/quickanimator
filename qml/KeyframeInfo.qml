import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import WebView 1.0

Rectangle {
    id: root
    color: myApp.style.dark
    property alias autoPlayButton: autoPlayButton
    property alias googleButton: googleButton

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
            spacing: 2
            Button {
                id: googleButton
                text: "Google image search"
                onClicked: webView.search();
            }

            Rectangle {
                width: parent.width
                height: 40
                RowLayout {
                    anchors.fill:parent
                    anchors.margins: 10
                    Label {
                        text: "Autoplay"
                    }
                    Switch {
                        id: autoPlayButton
                        onCheckedChanged: myApp.stage.autoPlay = checked;
                        Layout.alignment: Qt.AlignRight
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    onReleased: autoPlayButton.checked = !autoPlayButton.checked
                }
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
