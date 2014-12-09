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
    property string text: ""
    property alias textColor: text.color
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
        id: text
        anchors.centerIn: parent
        color: "darkblue"
        text: checked ? "<u>" + root.text + "</u>" : root.text
    }
}
