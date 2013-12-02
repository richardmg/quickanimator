import QtQuick 2.1

QtObject {
    property color accent: Qt.rgba(0.4, 0.4, 0.4, 1.0)
    property color text: Qt.darker(myApp.style.accent, 1.5)
    property color timelineline: Qt.darker(myApp.style.accent, 1.0)
    property int cellWidth: 15
    property int cellHeight: 35

    property Gradient stageGradient: Gradient {
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
