import QtQuick 2.0

Rectangle {
    id: root

    property var images: null

    function search()
    {
        visible = true;
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                images = new Array;
                var imageTags = doc.responseText.match(/<img[^>]*>/g)
                for (var i = 0; i < imageTags.length; ++i) {
                    var tag = imageTags[i];
                    var index = tag.indexOf("src");
                    var url = tag.substr(index).match(/"[^"]*/)[0].substr(1);
                    if (url.indexOf("http") === 0)
                        images.push(url)
                }
                listView.model = images.length
                print(images)
            }
        }

        doc.open("GET", "https://www.google.com/search?site=imghp&tbm=isch&q=teddy")
        doc.send();
    }

    ListView {
        id: listView
        anchors.fill: parent
        orientation: Qt.Horizontal
        delegate: Image {
            source: images[index]
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.visible = false
                    myApp.addImage(source)
                }
            }
        }
    }
}
