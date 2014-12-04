import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    property alias flickable: listView
    property alias model: listModel
    implicitHeight: (listModel.count * 42) - (listModel.count !== 0 ? 2 : 0)

    property var _delegates: new Array()

    color: myApp.style.dark

    Connections {
        target: myApp.model
        onSelectedSpritesUpdated: {
            var selected = _delegates[selectedSprite];
            if (selected)
                selected.treeLabel.highlight = true;

            var unselected = _delegates[unselectedSprite];
            if (unselected)
                unselected.treeLabel.highlight = false;
        }

        onParentHierarchyChanged: {
            if (sprite.parent !== null)
                listModel.syncWithModel();
        }

        onSpritesUpdated: listModel.syncWithModel();
    }

    ListModel {
        id: listModel

//        ListElement {}
//        ListElement {}
//        ListElement {}

        function syncWithModel()
        {
            listView.model = null;
            _delegates = new Array()
            clear();
            var sprites = myApp.model.sprites;
            for (var i=0; i<sprites.length; ++i)
                append({})
            listView.model = listModel;
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalFlick
        model: listModel
        Component.onCompleted: myApp.spriteTreeFlickable = listView

        delegate: Item {
            id: delegate
            width: parent.width
            height: 42

            Component.onCompleted: {
                _delegates.push(delegate);
                if (myApp.model.selectedSprites.indexOf(sprite) != -1)
                    treeLabel.highlight = true;
            }

            property int margin: 10
            property alias treeLabel: treeLabel
            property bool highlight: false
            property int index2: index
            property var sprite: myApp.model.sprites[index]

            Rectangle {
                id: treeLabel
                property bool highlight: false
                color: highlight ? "orange" : "white"
                height: 40
                width: parent.width
                Label {
                    id: label
                    x: margin + (myApp.model.getSpriteIndentLevel(sprite) * 15)
                    anchors.verticalCenter: parent.verticalCenter
                    text: sprite ? sprite.objectName : "<unknown>"
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
                    myApp.model.unselectAllSprites();
                    myApp.model.selectSprite(myApp.model.sprites[index], true);
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

                        if (currentDelegate !== delegate && (currentDelegate.index2 < index2 || currentDelegate.index2 > index3 )) {
                            var mapped = area.mapToItem(listView, mouseX, mouseY)
                            var targetIndex = listView.indexAt(mapped.x, mapped.y);
                            var targetIsSibling = !insideLabel(mouseX, mouseY);
                            myApp.model.changeSpriteParent(index2, targetIndex, targetIsSibling);
                        }

                        currentDelegate = null;
                    } else {
                        // Move dragged item back in place
                        listModel.syncWithModel();
                    }
                }
            }
        }
    }

}
