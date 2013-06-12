import QtQuick 2.1
import QtQuick.Controls 1.0

Column {
    spacing: 5

    TitleBar {
        title: "Image"
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
    TextField {
        x: 3
        placeholderText: "name"
    }
}
