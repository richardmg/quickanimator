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

    signal clicked

    property bool closeDownHighlight: false

    onClicked: {
        if (checkable)
            checked = !checked;

        if (!menu) {
            if (!alwaysVisible)
                closeDownHighlight = Qt.binding(function() { return opacity > 0; });
            myApp.controlPanel.closeAllMenus();
        }
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
            closeDownHighlight = false;
            var gridPos = menuGridRoot.mapToItem(null, 0, 0);
            x = gridPos.x + (gridX * width);
            y = gridPos.y + (gridY * height);
            opacityAnimation.duration = 1000 * Math.random()
            opacity = 1;
        } else {
            if (menu && checked)
                checked = false;
            opacityAnimation.duration = closeDownHighlight ? 1500 : (1000 * Math.random())
            opacity = alwaysVisible ? 1 : 0
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
        anchors.margins: 2
        radius: 4
        color: hovered || checked || closeDownHighlight ? myApp.style.labelHighlight : myApp.style.label;
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
        onPressedChanged: root.hovered = pressed || containsMouse
    }
}
