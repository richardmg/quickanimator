import QtQuick 2.1

Rectangle {
    id: root
    property int cellWidth: myApp.style.cellWidth

    Connections {
        target: myApp.model
        onTimeChanged: canvas.requestPaint()
        onSelectedSpritesUpdated: canvas.requestPaint()
        onKeyframesUpdated: canvas.requestPaint()
        onMpfChanged: canvas.requestPaint()
        onRecordingChanged: canvas.requestPaint()
    }

    color: "white"

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        property real lineWidth: 1.0
        property Item lastSprite: null
//        antialiasing: false

        onPaint: {
            var time = myApp.model.time

            var ctx = getContext('2d');
            ctx.strokeStyle = myApp.style.timelineline;
            ctx.lineWidth = 1
            ctx.beginPath();
            ctx.clearRect(0, 0, width, height);

            var timeShift = (width / (2 * cellWidth));

            // If there is no selected sprite, show the last sprite instead
            var sprites = myApp.model.selectedSprites;
            if (sprites.length > 0) {
                var sprite = sprites[0];
                lastSprite = sprite;
            } else {
                var useLast = myApp.model.sprites.indexOf(lastSprite) != -1;
                if (useLast)
                    sprite = lastSprite;
            }

            if (sprite) {
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
            var timeBetweenTickmarks = 30; // sec = (30 / myApp.model.mpf)
            var halfTickCount = Math.ceil(width / (2 * cellWidth * timeBetweenTickmarks));
            for (var tickmark = -halfTickCount; tickmark <= halfTickCount; ++tickmark) {
                var relativeTime = (tickmark * timeBetweenTickmarks) - (time % timeBetweenTickmarks);
                var absoluteTime = Math.round(time + relativeTime);
                if (absoluteTime < 0)
                    continue;

                var posX = (relativeTime + timeShift) * cellWidth;
                ctx.fillRect(posX, 0, 2, parent.height);

                var clockTimeSec = (myApp.model.mpf * absoluteTime) / 1000;
                var hours = Math.floor(clockTimeSec / 3600) % 24;
                var minutes = Math.floor(clockTimeSec / 60) % 60;
                var seconds = Math.floor(clockTimeSec % 60);
                hours = hours < 10 ? "0" + hours : hours
                minutes = minutes < 10 ? "0" + minutes : minutes
                seconds = seconds < 10 ? "0" + seconds : seconds
                var label = hours + ":" + minutes + ":" + seconds;
                ctx.fillText(label, posX + 5, parent.height - 2);
            }

            if (myApp.model.recording)
                ctx.fillStyle = "red"
            else
                ctx.fillStyle = myApp.style.timelineline;
            ctx.fillRect(width / 2, 0, 2, parent.height);

            ctx.stroke();
        }
    }
}

