import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    property alias flickable: listView
    property alias model: listModel

    gradient: Gradient {
        GradientStop {
            position: 0.0;
            color: Qt.lighter(myApp.style.accent, 1.5)
        }
        GradientStop {
            position: 200.0 / height;
            color: Qt.lighter(myApp.style.accent, 1.1)
        }
    }

    ListModel {
        id: listModel
    }

    ListView {
        id: listView
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        model: listModel
        delegate: Rectangle {
            width: parent.width
            height: myApp.style.cellHeight
            color: "transparent"
            Rectangle {
                height: 1
                width: parent.width
                color: myApp.style.timelineline
                anchors.bottom: parent.bottom
            }
            Rectangle {
                color: myApp.style.timelineline
                height: parent.height - 4
                width: childrenRect.width + 20
                anchors.verticalCenter: parent.verticalCenter
                radius: 3
                Label {
                    x: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: myApp.model.layers[index].name
                }
            }
        }
    }

}
