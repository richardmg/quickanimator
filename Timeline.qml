import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    property int cellHeight: 20
    property int cellWidth: 10
    property int rows: 10
    property int selectedX: 0
    property int selectedY: 0
    
    signal clicked
    signal doubleClicked

    clip: true

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: Math.max(20 * cellWidth, width)
        contentHeight: rows * cellHeight

        Canvas {
            width: flickable.contentWidth
            height: flickable.contentHeight
            renderTarget: Canvas.FramebufferObject
            property color fgcolor: "black"
            property real lineWidth: 0.2
            onPaint: {
                var ctx = getContext('2d');        
                ctx.strokeStyle = fgcolor
                ctx.lineWidth = lineWidth
                ctx.beginPath();
                for(var i = 0; i < rows; ++i)
                {
                    ctx.moveTo(0, i * cellHeight);
                    ctx.lineTo(width, i * cellHeight)
                }
                ctx.stroke();
                ctx.closePath();
            }

            MouseArea {
                anchors.fill: parent
                property int supressFlickable:0
                onPressed: supressFlickable = 2
                onReleased: flickable.interactive = true
                onMouseXChanged: {
                    var newSelectedX = Math.max(0, Math.floor(mouseX / cellWidth))
                    if (newSelectedX != selectedX) {
                        selectedX = newSelectedX
                        if (--supressFlickable === 0)
                            flickable.interactive = false
                    }
                    var newSelectedY = Math.max(0, Math.floor(mouseY / cellHeight))
                    if (newSelectedY != selectedY) {
                        selectedY = newSelectedY
                        if (--supressFlickable === 0)
                            flickable.interactive = false
                    }
                }
                onClicked: root.clicked();
                onDoubleClicked: root.doubleClicked();
            }
        }
    }

    Rectangle {
        id: selectorLine
        color: "red"
        x: (selectedX * cellWidth) + (cellWidth / 2) - 1
        y: 1
        width: 1
        height: parent.height - y
    }

    Rectangle {
        id: selectorHandle
        x: (selectedX * cellWidth)
        y: -flickable.contentY + (selectedY * cellHeight)
        z: 10
        width: cellWidth - 1
        height: cellHeight - 1
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: Qt.rgba(1.0, 0.0, 0.0, 1.0)
            }
            GradientStop {
                position: 1.0;
                color: Qt.rgba(0.8, 0.0, 0.0, 1.0)
            }
        }
    }

    function addCell(cellComponent, posX, posY)
    {
        var delegate = getDelegateInstanceAt(posY);
        if (!delegate) {
            console.warn("Error: could not add cell at:", posX, posY);
            return;
        }
        var cell = cellComponent.createObject(delegate);
        cell.x = posX * cellWidth;
        cell.width = cellWidth;
        cell.height = cellHeight;
    }

    function getDelegateInstanceAt(index) {
        for(var i = 0; i < contentItem.children.length; ++i) {
            var item = contentItem.children[i];
            // We have to check for the specific objectName we gave our
            // delegates above, since we also get some items that are not
            // our delegates here.
            if (item.objectName == "timelineDelegate" && item.index2 == index)
                return item;
        }
        return undefined;
    }
  
}

