import QtQuick 2.1

Flickable {
    property color fgcolor: "black"
    property real lineWidth: 1
    contentWidth: Math.max(rows * cellWidth, width)
    contentHeight: columns * cellHeight
    clip: true

    Canvas {
        width: contentWidth
        height: contentHeight
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
    }
}
