import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Item {
    id: root
    width: 80
    height: 62
    property string text: "button"
    property alias pressed: mouseArea.pressed
    property bool checked: false
    property bool checkable: false || menu
    property bool hovered: false
    property Item menu

    signal clicked

    onCheckedChanged: {
        if (menu) {
            if (checked)
                menu.openMenu(root.mapToItem(null, width + 5, 0));
            else
                menu.closeMenu()
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
