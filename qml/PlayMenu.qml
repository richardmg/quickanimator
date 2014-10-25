import QtQuick 2.0

Item {
    id: root

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: myApp.model.fullScreenMode || buttonRow.x >= width || buttonRow.x <= -buttonRow.width ? 0 : 0.3
        visible: opacity !== 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    Row {
        id: buttonRow
        width: childrenRect.width
        height: parent.height
        x: parent.width - width

        ProxyButton {
            onClicked: myApp.model.time = 0
            Text { x: 2; y: 2; text: myApp.model.time === 0 ? "Forward" : "Rewind" }
        }

        ProxyButton {
            onClicked: myApp.timeFlickable.userPlay = !myApp.timeFlickable.userPlay
            Text { x: 2; y: 2; text:  myApp.timeFlickable.userPlay ? "Stop" : "Play" }
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Record" }
            onClicked: print("Record")
            flickStop: true
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Undo" }
            onClicked: print("undo")
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Redo" }
            onClicked: print("redo")
            flickStop: true
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Foo" }
            onClicked: print("foo")
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Bar" }
            onClicked: print("bar")
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Baz" }
            onClicked: print("baz")
            flickStop: true
        }
    }

    FlickableMouseArea {
        anchors.fill: parent

        PropertyAnimation {
            id: snapAnimation
            target: buttonRow
            properties: "x"
            duration: 200
            easing.type: Easing.OutExpo
        }

        PropertyAnimation {
            id: bounceAnimation
            target: buttonRow
            properties: "x"
            duration: 200
            easing.type: Easing.OutBounce
        }

        function closestButton(right)
        {
            var children = buttonRow.children;
            var bestChild = null;
            var bestChildDist = right ? Number.MAX_VALUE : -Number.MAX_VALUE

            for (var i in children) {
                var child = children[right ? i : children.length - i - 1];
                if (!child.flickStop)
                    continue;
                var dist = root.width - root.mapFromItem(buttonRow, child.x, child.y).x - child.width;
                if ((right && dist > 0 && dist < bestChildDist) || (!right && dist < 0 && dist > bestChildDist)) {
                    bestChild = child;
                    bestChildDist = dist;
                }
            }

            return bestChild;
        }

        onMomentumXUpdated: {
            buttonRow.x += momentumX;
            var leftStop = parent.width
            var rightStop = parent.width - buttonRow.width - 100;
            buttonRow.x = (buttonRow.x > leftStop) ? leftStop : (buttonRow.x < rightStop) ? rightStop : buttonRow.x;
        }

        onPressedChanged: {
            if (pressed) {
                snapAnimation.stop();
            } else {
                var button = Math.abs(momentumX) > 15 ? closestButton(momentumX > 0) : null;
                if (button) {
                    stopMomentumX();
                    bounceAnimation.stop();
                    snapAnimation.to = root.width - button.x - button.width;
                    snapAnimation.restart();
                } else if (buttonRow.x < parent.width - buttonRow.width) {
                    stopMomentumX();
                    snapAnimation.stop();
                    bounceAnimation.to = parent.width - buttonRow.width;
                    bounceAnimation.restart();
                }
            }
        }

        onClicked: {
            var p = mapToItem(buttonRow, mouseX, mouseY);
            var button = buttonRow.childAt(p.x, p.y);
            if (button)
                button.clicked();
        }
    }
}
