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
        function syncWithModel()
        {
            clear();
            var layers = myApp.model.layers;
            for (var i=0; i<layers.length; ++i)
                append({})
        }
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
            property int index2: index
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
                    property var modelLayer: myApp.model.layers[index]
                    text: modelLayer ? modelLayer.name : ""
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    drag.target: treeLabel
                    drag.axis: Drag.XAndYAxis
                    property var currentHighlight

                    onPositionChanged: {
                        if (!drag.active)
                            return;
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
                            if (currentHighlight != delegate) {
                                // reparent
                                var mapped = area.mapToItem(listView, mouseX, mouseY)
                                var newIndex = listView.indexAt(mapped.x, mapped.y);
                                var layers = myApp.model.layers;
                                var removed = layers.splice(index2, 1)[0];
                                if (newIndex < index2)
                                    layers.splice(newIndex, 0, removed)
                                else
                                    layers.splice(newIndex - 1, 0, removed)
                            }
                            currentHighlight = null;
                            listModel.syncWithModel();
                        }
                    }
                }
            }
        }
    }

}
