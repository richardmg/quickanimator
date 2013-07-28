import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    property alias flickable: listView
    property alias model: listModel

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

    ListModel {
        id: listModel
    }

    ListView {
        id: listView
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        model: listModel
        delegate: Rectangle {
            id: delegate
            width: parent.width
            height: myApp.style.cellHeight
            color: "transparent"
            property bool highlight: false
            Rectangle {
                height: 1
                width: parent.width
                color: myApp.style.timelineline
                anchors.bottom: parent.bottom
            }
            Rectangle {
                id: treeLabel
                color: delegate.highlight ? "red" : myApp.style.timelineline
                x: 10
                y: 2
                height: parent.height - 5
                width: label.width + 20
                radius: 3
                Label {
                    id: label
                    x: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: myApp.model.layers[index].name
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    drag.target: treeLabel
                    drag.axis: Drag.XAndYAxis
                    property var currentHighlight

                    onPositionChanged: {
                        var mapped = area.mapToItem(listView, mouseX, mouseY)
                        var treeDelegate = listView.itemAt(mapped.x, mapped.y);
                        if (treeDelegate != currentHighlight) {
                            if (currentHighlight)
                                currentHighlight.highlight = false;
                            currentHighlight = treeDelegate;
                            if (currentHighlight)
                                currentHighlight.highlight = true
                        }
                    }

                    onReleased: {
                        if (currentHighlight) {
                            currentHighlight.highlight = false;
                            currentHighlight = null;
                        }
                    }
                }
            }
        }
    }

}
