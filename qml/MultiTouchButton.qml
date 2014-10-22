import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Rectangle {
    id: root
    color: "transparent"

    property bool pressed: false
    property bool checked: false
    property bool checkable: false

    signal clicked

    height: 50
    width: 100
    radius: 4

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
            if (tp1.pressed && contains(Qt.point(tp1.x, tp1.y)))
                tp = tp1;
            else if (tp2.pressed && contains(Qt.point(tp2.x, tp2.y)))
                tp = tp2;
            else
                return;

            root.pressed = true;
        }

        onReleased: {
            // work around double release callback:
            if (root.pressed) {
                root.pressed = tp.pressed;
                if (contains(Qt.point(tp.x, tp.y))) {
                    root.clicked();
                    tp = null;
                }
            }
        }
    }
}
