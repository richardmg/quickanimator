import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    property alias title: label.text
    width: parent.width
    height: 40
    gradient: myApp.style.toolBarGradient

    Rectangle {
        width: parent.width
        height: 1
        anchors.bottom: parent.bottom
        color: Qt.darker(myApp.style.accent, 1.9);
    }
    Label {
        id: label
        x: 5
        anchors.verticalCenter: parent.verticalCenter
        color: myApp.style.text
    }
}
