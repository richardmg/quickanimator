import QtQuick 2.1

Rectangle {
    id: root
    property int cellWidth: myApp.style.cellWidth
    property var model: myApp.model.layers
    property real time: myApp.model.time

    onTimeChanged: canvas.requestPaint()
    Connections {
        target: myApp.model
        onStatesUpdated: canvas.requestPaint()
        onFocusedLayerIndexChanged: canvas.requestPaint()
    }

    color: myApp.style.dark

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        property real lineWidth: 1.0
//        antialiasing: false

        onPaint: {
            var ctx = getContext('2d');
            ctx.strokeStyle = myApp.style.timelineline;
            ctx.lineWidth = 1
            ctx.beginPath();
            ctx.clearRect(0, 0, width, height);

            var timeShift = (width / (2 * cellWidth));

            var focusIndex = myApp.model.focusedLayerIndex;
            var focusIndexData = root.model[focusIndex];
            if (focusIndexData) {
                var sprite = focusIndexData.sprite;

                var grd = ctx.createLinearGradient(0, 0, width, 200);
                grd.addColorStop(0.00, '#516B89');
                grd.addColorStop(0.25, '#9FBAE0');
                grd.addColorStop(0.45, '#C1CDDD');
                grd.addColorStop(0.55, '#C1CDDD');
                grd.addColorStop(0.77, '#9FBAE0');
                grd.addColorStop(1.00, '#516B89');
                ctx.fillStyle = grd;

                var startIndex = sprite.getKeyframe(time - timeShift).volatileIndex;
                var endIndex = sprite.getKeyframe(time + timeShift).volatileIndex;

                for (var t = startIndex; t <= endIndex; ++t) {
                    var keyframe = sprite.keyframes[t];
                    ctx.fillRect(Math.round(((keyframe.time - time) * cellWidth) + (width / 2)), 0, cellWidth, parent.height);
                }
            }

            ctx.font = "15px Arial";
            ctx.fillStyle = myApp.style.timelineline;
            ctx.fillRect(width / 2, 0, 2, parent.height);

            var timeBetweenTickmarks = 25;
            var halfTickCount = Math.ceil(width / (2 * cellWidth * timeBetweenTickmarks));
            for (var tickmark = -halfTickCount; tickmark < halfTickCount; ++tickmark) {
                var relativeTime = (tickmark * timeBetweenTickmarks) - (time % timeBetweenTickmarks);
                var absoluteTime = Math.round(time + relativeTime);
                if (absoluteTime < 0)
                    continue;

                var posX = (relativeTime + timeShift) * cellWidth;
                ctx.fillRect(posX, parent.height / 2, 2, parent.height / 2);

                var clockTimeSec = (myApp.model.msPerFrame * absoluteTime) / 1000;
                var hours = Math.floor(clockTimeSec / 3600) % 24;
                var minutes = Math.floor(clockTimeSec / 60) % 60;
                var seconds = Math.floor(clockTimeSec % 60);
                var label = hours + ":" + minutes + ":" + seconds;
                ctx.fillText(label, posX + 5, parent.height - 2);
            }

            ctx.stroke();
        }
    }
}

