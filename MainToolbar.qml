import QtQuick 2.1
import QtQuick.Controls 1.0

TitleBar {

    property alias ticksPerFrame: ticksPerFrameBox.value

    TitleBarRow {
        anchors.horizontalCenter: parent.horizontalCenter
        width: childrenRect.width
        height: parent.height

        ToolButton {
            id: rewind
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: "<<"
            onClicked: {
                var layers = myApp.timeline.layers;
                for (var i = 0; i < layers.length; ++i)
                    layers[i].sprite.setTime(0);
                myApp.timeline.selectedX = 0;
            }
        }
        ToolButton {
            id: play
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: checked ? "Stop" : "Play"
            checkable: true
            onCheckedChanged: myApp.timeline.togglePlay(checked);
        }
        ToolButton {
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: "Tween"
            checkable: true
            checked: true
            onCheckedChanged: tweenMode = checked
        }
        ToolButton {
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            text: "Save"
            onClicked: saveJSON();
        }
        SpinBox {
            id: ticksPerFrameBox
            value: 1
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    TitleBarRow {
        height: parent.height
        width: childrenRect.width
        anchors.right: parent.right
        layoutDirection: Qt.RightToLeft
        Item { width: 10; height: 10 }
        Label {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: "Time: " + myApp.timeline.selectedX
            color: myApp.text
        }
    }
}
