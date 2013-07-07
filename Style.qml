import QtQuick 2.1

QtObject {
    property color accent: Qt.rgba(0.4, 0.4, 0.4, 1.0)
    property color text: Qt.darker(myApp.style.accent, 1.5)
    property int cellWidth: 10
    property int cellHeight: 30
}
