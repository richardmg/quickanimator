import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1

Rectangle {
    id: root
    width: parent.width
    implicitHeight: 40

    property string text: ""
    property bool checkable: false
    property bool checked: false
    property real contentOpacity: 1
    signal clicked

    onCheckedChanged: buttonSwitch.checked = checked;

    RowLayout {
        x: 10
        width: parent.width - (x * 2)
        height: root.implicitHeight

        Label {
            text: root.text
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
