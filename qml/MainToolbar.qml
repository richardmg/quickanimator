import QtQuick 2.1
import QtQuick.Controls 1.0

TitleBar {

    TitleBarRow {
        ToolButton {
            id: record
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: checked ? "Recording" : "Record"
            checkable: true
            onCheckedChanged: {
                myApp.model.recordsPositionX = checked
                myApp.model.recordsPositionY = checked
            }
            Component.onCompleted: checked = true
        }
        TimeSlider {

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

        ToolButton {
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: "Save"
            onClicked: myApp.model.saveJSON();
        }
        SpinBox {
            id: msPerFrameBox
            value: myApp.model.msPerFrame
            minimumValue: 0
            maximumValue: 99999
            anchors.verticalCenter: parent.verticalCenter
            onValueChanged: myApp.model.msPerFrame = value;
        }
    }

    TitleBarRow {
        anchors.right: parent.right
        layoutDirection: Qt.RightToLeft

        ToolButton {
            id: forward
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: ">>"
            onClicked: myApp.model.setTime(myApp.model.endTime);
        }
        ToolButton {
            id: rewind
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: "<<"
            onClicked: myApp.model.setTime(0);
        }
    }
}
