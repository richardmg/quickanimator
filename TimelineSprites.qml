import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    property alias timelineCanvas: timelineCanvas

    TimelineCanvas {
        id: timelineCanvas
        model: 50
        width: parent.width
        height: parent.height
        
        Binding {
            property Item t: timelineCanvas.flickable
            target: t.moving ? null : t
            property: "contentY"
            value: myApp.timeline.timelineCanvas.flickable.contentY
        }
    }
}
