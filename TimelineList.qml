import QtQuick 2.1

Rectangle {
    id: root
    property int cellHeight: myApp.cellHeight
    property int cellWidth: 10
    property int selectedX: 0
    property int selectedY: 0
    property var model: null

    property alias flickable: flickable

    signal clicked
    signal doubleClicked

    gradient: Gradient {
        GradientStop {
            position: 0.0;
            color: Qt.lighter(myApp.accent, 1.3)
        }
        GradientStop {
            position: 1.0;
            color: Qt.lighter(myApp.accent, 1.1)
        }
    }

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
            property real lineWidth: 1.0
            antialiasing: false

            onPaint: {
                var ctx = getContext('2d');        
                ctx.strokeStyle = Qt.darker(myApp.accent, 1.3);
                ctx.lineWidth = 1
                ctx.beginPath();
                for (var row=0; row<20; ++row) {
                    ctx.moveTo(0, (row * cellHeight) - 1);
                    ctx.lineTo(width, (row * cellHeight) - 1)

                    var rowData = root.model[row];
                    if (rowData) {
                        var sprite = rowData.sprite;
                        var currentState = sprite.getCurrentState();
                        ctx.fillStyle = Qt.rgba(0.9, 0.5, 0.3, 1);
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
}

