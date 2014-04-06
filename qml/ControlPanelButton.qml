import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Rectangle {
    id: root
    width: 90
    height: 67
    opacity: 0
    visible: opacity != 0
    color: myApp.style.dark
    radius: 4

    property int gridX: 0
    property int gridY: 0

    property string text: "button"
    property alias pressed: mouseArea.pressed
    property bool checked: false
    property bool checkable: false || menu
    property bool hovered: false
    property bool alwaysVisible: false
    property Item originalParent
    property Item menu

    property bool _enableAnim: true
    property bool _menuItem: null

    signal clicked

    property bool closeDownHighlight: false

    onClicked: {
        if (!alwaysVisible && !menu)
            closeDownHighlight = Qt.binding(function() { return opacity > 0; });

        myApp.controlPanel.closeAllMenus();

        if (checkable)
            checked = !checked;
    }

    onCheckedChanged: {
        if (menu)
            menu.openMenu(checked, root)
    }

    function showButton(show, menuItem, childIndex)
    {
        _menuItem = menuItem;
        if (show) {
            var gx = menuItem ? menuItem.gridX : 0;
            var gy = menuItem ? menuItem.gridY : 0;
            closeDownHighlight = false;
            var gridPos = menuGridRoot.mapToItem(null, 0, 0);
            _enableAnim = false;
            x = gridPos.x + ((gx + gridX) * width) + (50 * Math.random());
            y = gridPos.y + ((gy + gridY) * height) + (50 * Math.random());
            opacity = 0;
            opacityAnimation.duration = 500;
            xAnimation.duration = 500;
            yAnimation.duration = 500;
            _enableAnim = true;

            x = gridPos.x + ((gx + gridX) * width);
            y = gridPos.y + ((gy + gridY) * height);
            opacity = 1;
        } else {
            if (menu && checked)
                checked = false;
            opacityAnimation.duration = closeDownHighlight ? 1000 : 500;
            xAnimation.duration = closeDownHighlight ? 7000 : 5000;
            yAnimation.duration = closeDownHighlight ? 7000 : 5000;
            if (!alwaysVisible) {
                opacity = 0;
                if (closeDownHighlight) {
                    x += Math.random() * 50
                    y += Math.random() * 50
                } else {
                    x = 1000 * Math.random();
                    y = 1000 * Math.random();
                }
            }
        }
    }

    Behavior on opacity {
        enabled: _enableAnim;
        NumberAnimation {
            id: opacityAnimation
            easing.type: Easing.OutQuad
        }
    }
    Behavior on x {
        enabled: _enableAnim;
        NumberAnimation {
            id: xAnimation
            easing.type: Easing.OutQuad
        }
    }
    Behavior on y {
        enabled: _enableAnim;
        NumberAnimation {
            id: yAnimation
            easing.type: Easing.OutQuad
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 4
        color: hovered || checked || closeDownHighlight ? myApp.style.labelHighlight : myApp.style.label;
        Text {
            text: root.text
            anchors.centerIn: parent
        }
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

            mouseArea.enabled = false;
            root.hovered = true
        }

        onReleased: {
            mouseArea.enabled = true;
            root.hovered = false
            if (contains(Qt.point(tp.x, tp.y)))
                root.clicked()
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: root.clicked()
            hoverEnabled: true
            onContainsMouseChanged: root.hovered = pressed// || containsMouse
            onPressedChanged: root.hovered = pressed || containsMouse
        }
    }
}
