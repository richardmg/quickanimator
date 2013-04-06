import QtQuick 2.1
import QtQuick.Controls 1.0
import "Stage.js" as StageJS

Item {
    id: root
    readonly property var api: new StageJS.StageClass()
    property alias images: layers
    property int focusSize: 20
    property alias rotateFocusItems: rotateBox.checked
    property alias scaleFocusItems: scaleBox.checked

    Rectangle {
        id: layers
        color: "white"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
    }

    Item {
        id: focusFrames
        anchors.fill: layers
    }

    MouseArea {
        anchors.fill: images
        onPressed: api.pressStart({x:mouseX, y:mouseY})
        onReleased: api.pressEnd({x:mouseX, y:mouseY})
        onPositionChanged: api.pressDrag({x:mouseX, y:mouseY})
    }

    TitleBar {
        id: title
        title: "Stage"
        Row {
            anchors.right: parent.right
            CheckBox {
                id: rotateBox
                text: "Rotate"
                checked: true
            }
            CheckBox {
                id: scaleBox
                text: "Scale"
                checked: false
            }
        }
    }

    Component {
        id: layerFocus
        Rectangle {
            property Item target: root
            x: target.x + (target.width / 2) - focusSize
            y: target.y + (target.height / 2) - focusSize
            width: focusSize * 2
            height: focusSize * 2
            color: "transparent"
            radius: focusSize
            border.width: 3
            border.color: Qt.rgba(255, 0, 0, 0.7)
            smooth: true
        }
    }
}

