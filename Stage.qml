import QtQuick 2.1
import "Stage.js" as StageJS

Item {
    id: root
    property alias images: layers
    readonly property var api: new StageJS.StageClass(root)

    Rectangle {
        id: layers
        color: "white"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
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
            anchors.fill:parent
            color: "transparent"
            border.width: 2
            border.color: "red"
            smooth: true
        }
    }
}

