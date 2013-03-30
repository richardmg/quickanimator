import QtQuick 2.1

Rectangle {
    property real cellWidth: 10
    property real cellHeight: 20
    property color fgcolor: "black"
    property real lineWidth: 2

    border.width: lineWidth
    border.color: fgcolor

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext('2d');        
            ctx.strokeStyle = fgcolor
            ctx.lineWidth = lineWidth

            var rows = height / cellHeight
            var cols = width / cellWidth

            // Draw grid rows:
            ctx.beginPath();
            for(var i = 0; i < rows; ++i)
            {
                ctx.moveTo(0, i * cellHeight);
                ctx.lineTo(width, i * cellHeight)
            }
            for(var i = 0; i < cols; ++i)
            {
                ctx.moveTo(i * cellWidth, 0);
                ctx.lineTo(i * cellWidth, height)
            }
            ctx.stroke();
            ctx.closePath();
        }
    }
}

