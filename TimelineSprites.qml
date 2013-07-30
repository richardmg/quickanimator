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
            color: highlight ? "red" : "transparent"

            property int margin: 2
            property alias treeLabel: treeLabel
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
                property bool highlight: false
                color: highlight ? "red" : myApp.style.timelineline
                x: 10
                y: margin
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
            }

            MouseArea {
                id: area
                anchors.fill: delegate
                drag.target: treeLabel
                drag.axis: Drag.XAndYAxis
                property var currentDelegate

                function insideLabel(mouseX, mouseY)
                {
                    var l = currentDelegate.treeLabel; 
                    var mapped = area.mapToItem(l, mouseX, mouseY)
                    return (mapped.x >= 0 && mapped.x <= l.width
                            && mapped.y >= -margin && mapped.y <= l.height + margin);
                }

                onPositionChanged: {
                    if (!drag.active)
                        return;
                    delegate.z = 10;
                    if (currentDelegate) {
                        currentDelegate.highlight = false;
                        currentDelegate.treeLabel.highlight = false;
                    }

                    var mapped = area.mapToItem(listView, mouseX, mouseY)
                    currentDelegate = listView.itemAt(mapped.x, mapped.y);

                    if (currentDelegate && currentDelegate != delegate) {
                        if (insideLabel(mouseX, mouseY))
                            currentDelegate.treeLabel.highlight = true;
                        else
                            currentDelegate.highlight = true;
                    }
                }

                onReleased: {
                    delegate.z = 0;
                    if (currentDelegate) {
                        currentDelegate.highlight = false;
                        currentDelegate.treeLabel.highlight = false;
                        var layers = myApp.model.layers;

                        if (currentDelegate != delegate) {
                            if (insideLabel(mouseX, mouseY)) {
                                // reparent
                                var mapped = area.mapToItem(listView, mouseX, mouseY)
                                var parentIndex = listView.indexAt(mapped.x, mapped.y);
                                myApp.model.changeLayerParent(index2, parentIndex);
                            } else {
                                // make sibling
                                print("sibling")
                                mapped = area.mapToItem(listView, mouseX, mouseY)
                                newIndex = listView.indexAt(mapped.x, mapped.y);
                                draggedLayer = layers.splice(index2, 1)[0];
                                if (newIndex < index2)
                                    layers.splice(newIndex, 0, draggedLayer)
                                else
                                    layers.splice(newIndex - 1, 0, draggedLayer)
//                                draggedLayer.parentLayer = layers[index2];
//                                draggedLayer.sprite.parent = draggedLayer.parentLayer.sprite;
                            }
                        }

                        currentDelegate = null;
                    }
                    listModel.syncWithModel();
                }
            }
        }
    }

}
