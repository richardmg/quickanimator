import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1

Rectangle {
    id: root
    width: parent.width
    height: 40

    property string text: ""
    property bool checkable: false
    property bool checked: false
    signal clicked

    onCheckedChanged: buttonSwitch.checked = checked;

    RowLayout {
        anchors.fill:parent
        anchors.margins: 10

        Label {
            text: root.text
        }

        Switch {
            id: buttonSwitch
            Layout.alignment: Qt.AlignRight
            visible: root.checkable
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
