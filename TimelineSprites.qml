import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    property alias timelineList: timelineList

    TimelineList {
        id: timelineList
        model: 50
        width: parent.width
        height: parent.height
        
        Binding {
            property Item t: timelineList.flickable
            target: t.moving ? null : t
            property: "contentY"
            value: myApp.timeline.timelineList.flickable.contentY
        }
    }
}
