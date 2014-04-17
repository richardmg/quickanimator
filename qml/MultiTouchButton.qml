import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Rectangle {
    id: root
    width: 90
    height: 67
    color: myApp.style.dark

    property string text: "button"
    property bool pressed: false
    property bool checked: false
    property bool checkable: false

    property bool _mouseDetected: false

    signal clicked

    onClicked: {
        if (checkable)
            checked = !checked;
    }

    MultiPointTouchArea {
        anchors.fill: parent
        property TouchPoint activeTouchPoint: null
        touchPoints: [ TouchPoint { id: tp1; }, TouchPoint { id: tp2; } ]
        property TouchPoint tp: null

        onPressed: {
            if (_mouseDetected)
                return;
            if (tp1.pressed && contains(Qt.point(tp1.x, tp1.y)))
                tp = tp1;
            else if (tp2.pressed && contains(Qt.point(tp2.x, tp2.y)))
                tp = tp2;
            else
                return;

            root.pressed = true;
        }

        onReleased: {
            if (_mouseDetected)
                return;
            root.pressed = false;
            if (contains(Qt.point(tp.x, tp.y)))
                root.clicked();
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: root.clicked()
            onPressedChanged: root.pressed = pressed
        }

    }
}