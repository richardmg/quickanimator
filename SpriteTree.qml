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
            height: myApp.cellHeight
            color: myApp.accent
            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: Qt.lighter(myApp.accent, 1.2)
            }
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
