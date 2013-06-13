import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    ListView {
        y: titleBar.height
        width: parent.width
        height: parent.height - y
        model: 50
        delegate: Rectangle {
            width: parent.width
            height: 30
            color: index % 2 ? "white" : "lightblue"
        }
    }
    TitleBar {
        id: titleBar
        title: "Storyboards"
        TitleBarRow {
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
