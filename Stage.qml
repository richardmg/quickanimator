import QtQuick 2.1
import "Stage.js" as StageJS

Item {
    id: root
    property alias images: layers
    readonly property var api: new StageJS.StageClass()

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
    }

    Component {
        id: layerFocus
        Rectangle {
            property Item target: root
            x: target.x - ((width - target.width) / 2)
            y: target.y - ((height - target.height) / 2)
            width: target.width * target.scale
            height: target.height * target.scale
            rotation: target.rotation
            color: "transparent"
            border.width: 1
            border.color: "red"
            smooth: true
            Rectangle {
                width: 60
                height: 60
                anchors.centerIn: parent
                color: "transparent"
                border.width: 1
                border.color: parent.border.color
            }
        }
    }
}

