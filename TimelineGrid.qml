import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root
    property int cellHeight: 20
    property int cellWidth: 10
    property int selectedX: 0
    property int selectedY: 0
    property var model: null
    
    signal clicked
    signal doubleClicked

    clip: true

    function repaint()
    {
        canvas.requestPaint();
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: 20 * cellHeight
        pixelAligned: true

        Canvas {
            id: canvas
            width: flickable.contentWidth
            height: flickable.contentHeight
            renderTarget: Canvas.Image
            property color fgcolor: Qt.rgba(0.7, 0.7, 0.7, 1)
            property real lineWidth: 1.0
            antialiasing: false

            onPaint: {
                var ctx = getContext('2d');        
                ctx.strokeStyle = fgcolor
                ctx.lineWidth = 1
                ctx.beginPath();
                for (var row=0; row<20; ++row) {
                    ctx.moveTo(0, (row * cellHeight) - 1);
                    ctx.lineTo(width, (row * cellHeight) - 1)
                    ctx.fillStyle = row % 2 ? Qt.rgba(0.9, 0.9, 0.9, 1) : Qt.rgba(0.85, 0.85, 0.85, 1);
                    ctx.fillRect(0, (row * cellHeight) - 1, width, cellHeight);

                    var rowData = root.model[row];
                    if (rowData) {
                        var sprite = rowData.sprite;
                        var currentState = sprite.getCurrentState();
                        ctx.fillStyle = Qt.rgba(0.3, 0.3, 0.9, 1);
                        for (var c in sprite.timeline) {
                            var state = sprite.timeline[c];
                            ctx.fillRect((state.time * cellWidth), (row * cellHeight), cellWidth, cellHeight - 1);
                        }
                    }
                }
                ctx.stroke();
            }

            MouseArea {
                anchors.fill: parent
                property int supressFlickable:0
                property int startY:0
                onPressed: { 
                    supressFlickable = 2
                    startY = Math.max(0, Math.floor(mouseY / cellHeight))
                }
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
                        if (supressFlickable > 0 && Math.abs(newSelectedY - startY) === 1)
                            supressFlickable = 100;
                        selectedY = newSelectedY
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
        width: 1
        height: parent.height - y
    }

    Rectangle {
        id: selectorHandle
        x: 1 + (selectedX * cellWidth)
        y: -flickable.contentY + (selectedY * cellHeight)
        z: 10
        width: cellWidth - 2
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

}

