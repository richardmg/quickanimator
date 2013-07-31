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

                        if (currentDelegate != delegate) {
                            var mapped = area.mapToItem(listView, mouseX, mouseY)
                            var targetIndex = listView.indexAt(mapped.x, mapped.y);
                            if (insideLabel(mouseX, mouseY)) {
                                // make child:
                                myApp.model.changeLayerParent(index2, targetIndex);
                            } else {
                                // make sibling:
                                var siblingParentLayer = myApp.model.layers[targetIndex].parentLayer;
                                myApp.model.changeLayerParent(index2, myApp.model.layers.indexOf(siblingParentLayer));
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
