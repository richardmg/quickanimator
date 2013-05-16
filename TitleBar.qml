import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    property alias title: label.text
    width: parent.width
    height: 40

    gradient: Gradient {
        GradientStop {
            position: 0.0;
            color: Qt.rgba(0.9, 0.9, 0.9, 1.0)
        }
        GradientStop {
            position: 0.1;
            color: Qt.rgba(1.0, 1.0, 1.0, 1.0)
        }
        GradientStop {
            position: 0.2;
            color: Qt.rgba(0.97, 0.97, 0.97, 1.0)
        }
        GradientStop {
            position: 1.0;
            color: Qt.rgba(0.91, 0.91, 0.91, 1.0)
        }
    }
    Rectangle {
        width: parent.width
        height: 1
        anchors.bottom: parent.bottom
        color: Qt.rgba(0.6, 0.6, 0.6, 1.0)
    }
    Label {
        id: label
        x: 5
        anchors.verticalCenter: parent.verticalCenter
    }
}
