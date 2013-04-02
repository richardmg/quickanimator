import QtQuick 2.1

Item {
    id: root
    property alias images: images

    Rectangle {
        id: images
        color: "white"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
    }

    MouseArea {
        anchors.fill: images
        onPressed: {
            var index = getImageAt(mouseX, mouseY)
            if (index != -1) {
                print("Clicked on image:", index)
            }
        }
    }

    TitleBar {
        id: title
        title: "Stage"
    }

    function getImageAt(x, y)
    {
        for (var i=images.children.length - 1; i>=0; --i) {
            var img = images.children[i]
            if (x >= img.x && x <= img.x + img.width
                && y >= img.y && y <= img.y + img.height)
                return i
        }
        return -1
    }
}

