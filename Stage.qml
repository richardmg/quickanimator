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
            property int radius: 30
            x: target.x + (target.width / 2) - radius
            y: target.y + (target.height / 2) - radius
            width: radius * 2
            height: radius * 2
            rotation: target.rotation
            color: "transparent"
            border.width: 5
            border.color: Qt.rgba(255, 0, 0, 0.3)
            smooth: true
        }
    }
}

