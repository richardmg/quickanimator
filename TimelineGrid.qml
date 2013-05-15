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

    function updateModel()
    {
        canvas.requestPaint();
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: 20 * cellHeight

        Canvas {
            id: canvas
            width: flickable.contentWidth
            height: flickable.contentHeight
            renderTarget: Canvas.FramebufferObject
            property color fgcolor: "black"
            property real lineWidth: 1.0
            onPaint: {
                var ctx = getContext('2d');        
                ctx.strokeStyle = fgcolor
                ctx.lineWidth = lineWidth
                ctx.beginPath();
                for (var row=0; row<20; ++row) {
                    ctx.moveTo(0, row * cellHeight);
                    ctx.lineTo(width, row * cellHeight)

                }
                for (var row=0; row<20; ++row) {
                    var rowData = root.model[row];
                    if (rowData) {
                        for (var c in rowData.states) {
                            var state = rowData.states[c];
                            ctx.fillStyle = (state === selectedState)
                                ? Qt.rgba(1.0, 0.0, 0.0, 1) : Qt.rgba(0.4, 0.4, 0.6, 1);
                            ctx.fillRect(1 + (state.time * cellWidth),
                                1 + (row * cellHeight), cellWidth - 2, cellHeight - 2);
                        }
                    }
                }
                ctx.stroke();
                ctx.closePath();
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
        y: 1
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

    function setHighlight(x, y)
    {
        updateModel();
    }
  
}

