import QtQuick 2.0

MenuRow {
    id: playSlider

    property bool _guard: true

    onXChanged: {
        if (_guard)
            return
        _guard = true
        var slowdown = (parent.width - width) / Math.max(1, x)
        myApp.model.playbackMpf = myApp.model.targetMpf * slowdown
        _guard = false
    }

    onIsCurrentChanged: {
        _guard = true
        var slowdown = myApp.model.playbackMpf / myApp.model.targetMpf
        x = (parent.width - width) / slowdown
        _guard = false
    }
}
