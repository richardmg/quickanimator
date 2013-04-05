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
        onPressed: api.pressStart(mouseX, mouseY)
        onReleased: api.pressEnd(mouseX, mouseY)
        onPositionChanged: api.pressDrag(mouseX, mouseY)
    }

    TitleBar {
        id: title
        title: "Stage"
    }
}

