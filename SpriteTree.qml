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
    ListView {
        width: parent.width
        height: 200
        model: 20
        delegate: Rectangle {
            width: parent.width
            height: 20
            color: index % 2 ? "lightgray" : "gray"
        }
    }
//    TableView {
//        model: 100
//        width: parent.width
//
//        TableViewColumn {
//            role: "title"
//            title: "Title"
//            width: 120
//        }
//    }
}
