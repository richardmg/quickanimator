import QtQuick 2.0

MenuRow {
    id: playSlider

    property bool _guard: true

    onXChanged: {
        if (_guard)
            return
        _guard = true
        var slowdown = (parent.width - width) / Math.max(1, x)
        myApp.model.msPerFrame = myApp.model.targetMsPerFrame * slowdown
        _guard = false
    }

    onIsCurrentChanged: {
        _guard = true
        var slowdown = myApp.model.msPerFrame / myApp.model.targetMsPerFrame
        x = (parent.width - width) / slowdown
        _guard = false
    }
}
