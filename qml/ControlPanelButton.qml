import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

Item {
    id: root
    width: 80
    height: 62
    property alias text: button.text
    property alias checked: button.checked
    property alias checkable: button.checkable

    signal clicked

    Button {
        id: button
        anchors.fill: parent
        onClicked: root.clicked()
        style: ButtonStyle {
            background: Rectangle {
                anchors.fill: parent
                radius: 4
                color: button.pressed || button.checked ? myApp.style.labelHighlight : myApp.style.label;
            }
        }
    }
}
