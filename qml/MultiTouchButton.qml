import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Rectangle {
    id: root
    color: "transparent"

    property bool pressed: false
    property bool checked: false
    property bool checkable: false
    property bool touchAreaEnabled: touchArea.enabled

    signal clicked

    height: 50
    width: 100
    radius: 4

    onClicked: {
        if (checkable)
            checked = !checked;
    }

    MultiPointTouchArea {
        id: touchArea
        anchors.fill: parent
        property TouchPoint activeTouchPoint: null
        touchPoints: [ TouchPoint { id: tp1; }, TouchPoint { id: tp2; } ]
        property TouchPoint tp: null
        property var pressTime

        onPressed: {
            if (tp1.pressed && contains(Qt.point(tp1.x, tp1.y)))
                tp = tp1;
            else if (tp2.pressed && contains(Qt.point(tp2.x, tp2.y)))
                tp = tp2;
            else
                return;

            pressTime = (new Date()).getTime();
            root.pressed = true;
        }

        onReleased: {
            // work around double release callback:
            if (root.pressed) {
                root.pressed = tp.pressed;
                if (contains(Qt.point(tp.x, tp.y))) {
                    tp = null;
                    if (new Date().getTime() - pressTime < 300)
                        root.clicked();
                }
            }
        }
    }
}
