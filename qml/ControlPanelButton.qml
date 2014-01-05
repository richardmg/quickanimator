import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Item {
    id: root
    width: 80
    height: 62
    opacity: 0
    visible: opacity != 0

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

    signal clicked

    onClicked: {
        if (!checkable)
            myApp.controlPanel.closeAllMenus();
    }

    onCheckedChanged: {
        if (menu) {
            menu.openMenu(checked, 0)
            for (var i = 0; i< originalParent.originalChildren.length; ++i) {
                var sibling = originalParent.originalChildren[i];
                if (sibling !== root)
                    sibling.opacity = !checked
            }
        }
    }

    function showButton(show, buttonIndex)
    {
        if (show) {
            var gridPos = menuGridRoot.mapToItem(null, 0, 0);
            x = gridPos.x + (gridX * (width + 5));
            y = gridPos.y + (gridY * (height + 5));
            opacityAnimation.duration = 1000 * Math.random()
            opacity = 1;
        } else {
            opacityAnimation.duration = 1000 * Math.random()
            opacity = alwaysVisible ? 1 : 0
            if (menu && checked)
                checked = false;
        }
    }

    Behavior on opacity {
        NumberAnimation {
            id: opacityAnimation
            easing.type: Easing.OutQuad
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: hovered || checked ? myApp.style.labelHighlight : myApp.style.label;
        Text {
            text: root.text
            anchors.centerIn: parent
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
        hoverEnabled: true
        onContainsMouseChanged: root.hovered = pressed || containsMouse
        property Item subMenuButton

        onReleased: {
            if (checkable && contains(Qt.point(mouseX, mouseY)))
                checked = !checked
        }

//        onPositionChanged: {
//            if (menu && menu.visible)
//                menu.mouseMoved(mapToItem(null, mouseX, mouseY));
//        }
    }
}
