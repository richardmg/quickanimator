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

    height: 70
    width: 100
    radius: 4

    onClicked: {
        if (checkable)
            checked = !checked;
    }
}
