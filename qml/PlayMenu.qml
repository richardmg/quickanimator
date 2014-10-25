import QtQuick 2.0

Item {
    id: root

    onVisibleChanged: {
        if (!visible)
            return;
        if (buttonRow.x >= flickable.leftStop)
            buttonRow.x = buttonRow.startX
    }

    Rectangle {
        id: background
        x: -5
        width: parent.width - (x * 2)
        height: parent.height - x
        anchors.fill: parent
        border.color: "darkblue"
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: Qt.rgba(0.3, 0.3, 1.0, 1.0)
            }
            GradientStop {
                position: 1.0;
                color: Qt.rgba(0.1, 0.1, 1.0, 1.0)
            }
        }
        opacity: myApp.model.fullScreenMode || buttonRow.x >= width || buttonRow.x <= -buttonRow.width ? 0 : 0.5
        visible: opacity !== 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    Row {
        id: buttonRow
        width: childrenRect.width
        height: parent.height
        property int startX: root.width - menuStartButton.x - menuStartButton.width
        x: startX

        ProxyButton {
            onClicked: myApp.model.time = 0
            text: myApp.model.time === 0 ? "Forward" : "Rewind"
        }

        ProxyButton {
            onClicked: myApp.timeFlickable.userPlay = !myApp.timeFlickable.userPlay
            text:  myApp.timeFlickable.userPlay ? "Stop" : "Play"
        }

        ProxyButton {
            text: "Record"
            onClicked: print("Record")
        }

        ProxyButton {
            id: menuStartButton
            text: "Slowmo"
            onClicked: print("undo")
            flickStop: true
        }

        ProxyButton { text: "|" }

        ProxyButton {
            text: "Undo"
            onClicked: print("bar")
        }

        ProxyButton {
            text: "Redo"
            onClicked: print("redo")
        }

        ProxyButton {
            text: "Cut"
            onClicked: print("foo")
            flickStop: true
        }

        ProxyButton { text: "|" }

        ProxyButton {
            text: "Cast"
            onClicked: print("baz")
        }

        ProxyButton {
            text: "Google"
            onClicked: print("baz")
        }

        ProxyButton {
            text: "Settings"
            onClicked: print("baz")
            flickStop: true
        }
    }

    FlickableMouseArea {
        id: flickable
        anchors.fill: parent

        property int leftStop: parent.width
        property int rightStop: parent.width - buttonRow.width
        property int overshoot: 100

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
            // Ensure that the menu cannot be dragged passed the stop
            // points, and apply some overshoot resitance.
            var dist = Math.max(0, rightStop - buttonRow.x);
            buttonRow.x += momentumX * Math.pow(1 - (dist / overshoot), 2);
            if (buttonRow.x > leftStop)
                buttonRow.x = leftStop;
            else if (buttonRow.x < rightStop - overshoot)
                buttonRow.x = rightStop - overshoot;
        }

        onPressedChanged: {
            if (pressed) {
                snapAnimation.stop();
                bounceAnimation.stop();
            } else {
                // Check if we should bounce to a button stop or the right edge
                var button = Math.abs(momentumX) > 15 ? closestButton(momentumX > 0) : null;
                if (button) {
                    stopMomentumX();
                    bounceAnimation.stop();
                    snapAnimation.to = root.width - button.x - button.width;
                    snapAnimation.restart();
                } else if (buttonRow.x < rightStop) {
                    stopMomentumX();
                    snapAnimation.stop();
                    bounceAnimation.to = rightStop
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
