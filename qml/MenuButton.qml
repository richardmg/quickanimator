import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1

Rectangle {
    id: root

    property string text: ""
    property bool checkable: false
    property bool checked: false
    property real contentOpacity: 1
    property Item parentMenuButton: null
    property QtObject radioButtonGroup: null

    signal clicked

    color: parentMenuButton ? "#e8e8e8" : "white"
    width: parent.width
    height: !parentMenuButton || parentMenuButton.checked ? 40 : 0
    visible: height !== 0
    Behavior on height { NumberAnimation { duration: 100 } }

    onCheckedChanged: buttonSwitch.checked = checked;

    Component.onCompleted: {
        if (radioButtonGroup)
            radioButtonGroup.addItem(root)
    }

    RowLayout {
        x: 10
        width: parent.width - (x * 2)
        height: root.height

        Label {
            text: (parentMenuButton ? "   " : "") + root.text
            opacity: contentOpacity
        }

        Switch {
            id: buttonSwitch
            Layout.alignment: Qt.AlignRight
            visible: root.checkable
            opacity: contentOpacity
        }

    }

    MouseArea{
        anchors.fill: parent
        onReleased: {
            if (root.checkable)
                checked = !checked
            root.clicked();
        }
    }
}
