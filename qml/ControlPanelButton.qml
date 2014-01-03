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
    property bool checkable: false
    property bool hovered: false
    property Item menu

    signal clicked

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

        onPressed: {
            root.hovered = true;
            if (menu)
                menu.openMenu(root.mapToItem(null, 0, 0));
        }

        onReleased: {
            root.hovered = false;
            if (menu)
                menu.closeMenu();
        }

        onPositionChanged: {
            if (menu && pressed)
                menu.mouseMoved(mapToItem(null, mouseX, mouseY));
        }
    }
}
