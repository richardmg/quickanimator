import QtQuick 2.1

Rectangle {
    id: root
    property int cellWidth: myApp.style.cellWidth
    property int mouseX: 0
    property int mouseY: 0
    property var model: null

    property alias flickable: flickable

    signal clicked
    signal doubleClicked

    gradient: Gradient {
        GradientStop {
            position: 0.0;
            color: Qt.lighter(myApp.style.accent, 1.5)
        }
        GradientStop {
            position: 200.0 / height;
            color: Qt.lighter(myApp.style.accent, 1.1)
        }
    }

    function repaint()
    {
        canvas.requestPaint();
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width * 2
        contentHeight: 20 * myApp.style.cellHeight
        pixelAligned: true

        Canvas {
            id: canvas
            x: -1
            y: -1
            width: flickable.contentWidth
            height: flickable.contentHeight
            renderTarget: Canvas.Image
            property real lineWidth: 1.0
            antialiasing: false

            onPaint: {
                var ctx = getContext('2d');        
                ctx.strokeStyle = Qt.darker(myApp.style.accent, 1.3);
                ctx.lineWidth = 1
                ctx.beginPath();
                ctx.clearRect(0, 0, width, height);

                // Close table on left side:
                ctx.moveTo(0, 0);
                ctx.lineTo(0, 20 * myApp.style.cellHeight)

                for (var row=0; row<20; ++row) {
                    ctx.moveTo(0, row * myApp.style.cellHeight);
                    ctx.lineTo(width, row * myApp.style.cellHeight)

                    var rowData = root.model[row];
                    if (rowData) {
                        var sprite = rowData.sprite;
                        var currentState = sprite.getCurrentState();
                        ctx.fillStyle = Qt.rgba(0.9, 0.5, 0.3, 1);
                        var grd = ctx.createLinearGradient(0, 0, 0, myApp.style.cellHeight * 4);
                        grd.addColorStop(0, '#8ED6FF');   
                        grd.addColorStop(1, '#206CD3');
                        ctx.fillStyle = grd;
                        for (var c in sprite.keyframes) {
                            var state = sprite.keyframes[c];
                            ctx.fillRect((state.time * cellWidth) + 1, (row * myApp.style.cellHeight), cellWidth, myApp.style.cellHeight - 1);
                        }
                    }
                }
                ctx.stroke();
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var newX = Math.max(0, Math.floor(mouseX / myApp.style.cellWidth))
                    if (newX != root.mouseX)
                        root.mouseX = newX
                    var newY = Math.max(0, Math.floor(mouseY / myApp.style.cellHeight))
                    if (newY != root.mouseY)
                        root.mouseY = newY
                    root.clicked();
                }
                onDoubleClicked: root.doubleClicked();
            }
        }
    }
}

