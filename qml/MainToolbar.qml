import QtQuick 2.1
import QtQuick.Controls 1.0

TitleBar {

    TitleBarRow {
        x: 2; y: 2
        width: childrenRect.width
        height: parent.height - (y * 2)

        ToolButton {
            id: record
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: checked ? "Recording" : "Record"
            checkable: true
            onCheckedChanged: myApp.model.recordMode = checked
        }
        ToolButton {
            text: " + "
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            onClicked: myApp.addImage("dummy.jpeg") 
        }
        ToolButton {
            text: " Keyframe"
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            checkable: true
            onClicked: myApp.keyframeInfo.visible = checked
        }
    }

    TitleBarRow {
        anchors.horizontalCenter: parent.horizontalCenter
        x: 2; y: 2
        width: childrenRect.width
        height: parent.height - (y * 2)

        ToolButton {
            id: rewind
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: "<<"
            onClicked: myApp.model.setTime(0);
        }
        ToolButton {
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: "Save"
            onClicked: myApp.model.saveJSON();
        }
        SpinBox {
            id: msPerFrameBox
            value: 100
            minimumValue: 0
            maximumValue: 99999
            anchors.verticalCenter: parent.verticalCenter
            onValueChanged: myApp.model.msPerFrame = value;
        }
    }

    TitleBarRow {
        height: parent.height
        width: childrenRect.width
        anchors.right: parent.right
        layoutDirection: Qt.RightToLeft
        Item { width: 10; height: 10 }
        Timeline {
            width: 300
            height: parent.height
        }
    }
}
