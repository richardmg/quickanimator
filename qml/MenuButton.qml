import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Rectangle {
    id: root

    property bool pressed: false
    property bool checked: false
    property bool checkable: false
    property bool flickStop: false
    property Item menu: null
    property bool closeMenuOnClick: !menu && !checkable
    property alias text: text.text
    readonly property bool isButton: true

    signal clicked

    height: 70
    width: 100
    color: "transparent"

    onClicked: {
        if (checkable)
            checked = !checked;
        else if (menu)
            currentMenu = menu;

        if (closeMenuOnClick)
           menuController.opacity = 0;
    }

    Text {
        anchors.centerIn: parent
        color: "darkblue"
        id: text
    }
}
