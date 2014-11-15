import QtQuick 2.0
import QtQuick.Controls 1.2

Rectangle {
    id: root

    property var images: null
    onVisibleChanged: listView.headerItem.forceActiveFocus()

    function search()
    {
        visible = true;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                listView.model = 0
                images = new Array;
                var imageTags = doc.responseText.match(/<img[^>]*>/g)
                if (imageTags.length == 0)
                    return;
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

        doc.open("GET", "http://www.google.com/search?site=imghp&tbm=isch&q=" + listView.headerItem.text)
        doc.send();
    }

    GridView {
        id: listView
        anchors.fill: parent
        cellWidth: parent.width / 4
        cellHeight: cellWidth
        header: TextField {
            id: searchText
            width: parent.width
            onTextChanged: search();
        }

        delegate: Image {
            source: images[index] ? images[index] : ""
            width: listView.cellWidth
            height: listView.cellHeight
            onSourceSizeChanged: {
                var scale = width / Math.max(sourceSize.width, sourceSize.height)
                width = sourceSize.width * scale
                height = sourceSize.height * scale
            }
            onFocusChanged: {
                if (focus && root.visible) {
                    listView.headerItem.forceActiveFocus()
                }
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
}
