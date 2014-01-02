import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    property alias flickable: listView
    property alias model: listModel

    property var _delegates: new Array()

    color: myApp.style.dark

    Connections {
        target: myApp.model
        onSelectedLayersUpdated: {
            var selected = _delegates[selectedLayer];
            if (selected)
                selected.treeLabel.highlight = true;

            var unselected = _delegates[unselectedLayer];
            if (unselected)
                unselected.treeLabel.highlight = false;
        }

        onParentHierarchyChanged: {
            if (layer.sprite.parent !== null)
                listModel.syncWithModel();
        }
    }

    ListModel {
        id: listModel
        function syncWithModel()
        {
            listView.model = null;
            _delegates = new Array()
            clear();
            var layers = myApp.model.layers;
            for (var i=0; i<layers.length; ++i)
                append({})
            listView.model = listModel;
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        model: listModel
        Component.onCompleted: myApp.layerTreeFlickable = listView

        delegate: Item {
            id: delegate
            width: parent.width
            height: myApp.style.cellHeight
            Component.onCompleted: {
                _delegates.push(delegate);
                if (myApp.model.selectedLayers.indexOf(modelLayer) != -1)
                    treeLabel.highlight = true;
            }

            property int margin: 2
            property alias treeLabel: treeLabel
            property bool highlight: false
            property int index2: index
            property var modelLayer: myApp.model.layers[index]

            Rectangle {
                height: highlight ? 3 : 1
                width: parent.width
                color: highlight ? myApp.style.labelHighlight : myApp.style.timelineline
                anchors.bottom: parent.bottom
                anchors.bottomMargin: margin
            }

            Rectangle {
                id: treeLabel
                property bool highlight: false
                color: highlight ? myApp.style.labelHighlight : myApp.style.label
                x: margin + (myApp.model.getLayerIndentLevel(modelLayer) * 15)
                height: parent.height - 5
                width: label.width + 20
                radius: 3
                Label {
                    id: label
                    x: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelLayer ? modelLayer.sprite.objectName : ""
                }
            }

            MouseArea {
                id: area
                anchors.fill: delegate
                drag.target: treeLabel
                drag.axis: Drag.XAndYAxis
                property var currentDelegate
                property var index3: 0

                function insideLabel(mouseX, mouseY)
                {
                    var l = currentDelegate.treeLabel; 
                    var mapped = area.mapToItem(l, mouseX, mouseY)
                    return (mapped.x >= 0 && mapped.x <= l.width
                            && mapped.y >= -margin && mapped.y <= l.height + margin);
                }

                onPressed: {
                    myApp.model.unselectAllLayers();
                    myApp.model.selectLayer(myApp.model.layers[index], true);
                    index3 = index + myApp.model.descendantCount(index2);
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

                    if (currentDelegate
                            && currentDelegate != delegate
                            && (currentDelegate.index2 < index2 || currentDelegate.index2 > index3 )) {
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

                        if (currentDelegate != delegate && (currentDelegate.index2 < index2 || currentDelegate.index2 > index3 )) {
                            var mapped = area.mapToItem(listView, mouseX, mouseY)
                            var targetIndex = listView.indexAt(mapped.x, mapped.y);
                            var targetIsSibling = !insideLabel(mouseX, mouseY);
                            myApp.model.changeLayerParent(index2, targetIndex, targetIsSibling);
                        }

                        currentDelegate = null;
                    }
                }
            }
        }
    }

}
