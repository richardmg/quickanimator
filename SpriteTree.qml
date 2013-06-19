import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    Rectangle {
        anchors.fill: listView
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: Qt.rgba(0.9, 0.9, 0.9, 1.0)
            }
            GradientStop {
                position: 1.0;
                color: Qt.rgba(0.8, 0.8, 0.8, 1.0)
            }
        }
    }

    ListView {
        id: listView
        y: titleBar.height
        width: parent.width
        height: parent.height - y
        model: 50
        delegate: Rectangle {
            width: parent.width
            height: myApp.style.cellHeight
            //color: myApp.style.accent
            color: "transparent"
            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: Qt.lighter(myApp.style.accent, 1.2)
            }
        }
    }
    TitleBar {
        id: titleBar
        title: "Storyboards"
        TitleBarRow {
            anchors.fill: parent
            layoutDirection: Qt.RightToLeft
            ToolButton {
                text: "+"
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                onClicked: myApp.addImage("dummy.jpeg") 
            }
        }
    }
}
