import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    width: view.width
    height: cellHeight
    color: "black"

    property int i: index
    Rectangle {
        y: i == 0 ? 1 : 0
        width: parent.width
        height: parent.height - y - 1
        color: "white"
        ToolButton {
            text: "+"
            x: 2
            height: parent.height - 4
            anchors.verticalCenter: parent.verticalCenter
            onClicked: window.addImage("dummy.jpeg") 
        }
    }
    MouseArea {
        anchors.fill: parent
        onMouseXChanged: {
            selectedX = Math.floor(mouseX / cellWidth)
            selectedY = index
        }
    }

    Rectangle {
        id: handle
        visible: index === selectedY
        x: (selectedX * cellWidth)
        y: 0
        width: cellWidth - 1
        height: cellHeight - 1
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: Qt.rgba(1.0, 0.0, 0.0, 1.0)
            }
            GradientStop {
                position: 1.0;
                color: Qt.rgba(0.8, 0.0, 0.0, 1.0)
            }
        }
    }
}

