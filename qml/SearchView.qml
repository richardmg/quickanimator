import QtQuick 2.0
import QtQuick.Controls 1.2

Rectangle {
    id: root

    property var images: null
    Component.onCompleted: if (visible) searchText.forceActiveFocus()

    onVisibleChanged: {
        if (visible) {
            if (searchText) {
                searchText.forceActiveFocus()
                searchText.selectAll()
            }
        } else {
            Qt.inputMethod.hide()
            searchText.focus = false
        }
    }

    function search()
    {
        visible = true;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                listView.model = 0
                images = new Array;
                var imageTags = doc.responseText.match(/<img[^>]*>/g)
                if (!imageTags || imageTags.length == 0) {
                    print("Problems loading images:", doc.statusText, doc.responseText)
                    return;
                }

                for (var i = 0; i < imageTags.length; ++i) {
                    var tag = imageTags[i];
                    var index = tag.indexOf("src");
                    var url = tag.substr(index).match(/"[^"]*/)[0].substr(1);
                    if (url.indexOf("http") === 0)
                        images.push(url)
                }
                listView.model = images.length
            }
        }

        doc.open("GET", "http://www.google.com/search?site=imghp&tbm=isch&q=" + searchText.text)
        doc.send();
    }

    Flickable {
        // Need extra flickable to work around gridview images stealing focus on load
        anchors.fill: parent
        contentWidth: width
        contentHeight: (listView.model * listView.cellHeight) / 4

        TextField {
            id: searchText
            y: 2
            z: 1
            anchors.left: parent.left
            anchors.right: closeButton.left
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            onAccepted: search();
            inputMethodHints: Qt.ImhNoPredictiveText
        }

        GridView {
            id: listView
            anchors.top: searchText.bottom
            anchors.topMargin: 1
            width: parent.width
            height: (cellHeight * model) / 4
            interactive: false
            cellWidth: parent.width / 4
            cellHeight: cellWidth

            delegate: Image {
                source: images[index] ? images[index] : ""
                width: listView.cellWidth
                height: listView.cellHeight
                onSourceSizeChanged: {
                    var scale = width / Math.max(sourceSize.width, sourceSize.height)
                    width = sourceSize.width * scale
                    height = sourceSize.height * scale
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.visible = false
                        myApp.addImage(images[index])
                    }
                }
            }
        }

        Rectangle {
            id: closeButton
            y: 2
            anchors.right: parent.right
            anchors.verticalCenter: searchText.verticalCenter
            anchors.rightMargin: 2
            width: 30
            height: width
            radius: width
            color: "red"
            Text {
                text: "X"
                color: "white"
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: root.visible = false
            }
        }
    }
}
