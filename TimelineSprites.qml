import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    property alias timelineList: timelineList

    TimelineList {
        id: timelineList
        model: 50
        y: titlebar.height
        width: parent.width
        height: parent.height
        
        Binding {
            target: timelineList.moving ? null : timelineList
            property: "contentY"
            value: timeline.timelineGrid.timelineList.contentY
        }
    }

    TitleBar {
        id: titlebar
        TitleBarRow {
            ToolButton {
                id: rewind
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: "+"
                onClicked: {
                    myApp.addImage("");
                }
            }
        }
    }
}
