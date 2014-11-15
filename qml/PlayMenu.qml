import QtQuick 2.0
import WebView 1.0

Item {
    id: root

    WebView {
        id: webView
        onImageUrlChanged: {
            myApp.addImage(imageUrl)
            myApp.menuButton.checked = false;
        }
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
        objectName: "top"

        Row {
            width: root.width
            height: parent.height
            layoutDirection: Qt.RightToLeft
        objectName: "second"

            ProxyButton {
                id: firstButton
                onClicked: myApp.model.time = 0
                text: myApp.model.time === 0 ? "Forward" : "Rewind"
            }

            ProxyButton {
                text: "Google"
                onClicked: myApp.searchView.search()
            }

            ProxyButton {
                onClicked: {
                    myApp.model.unselectAllLayers()
                    myApp.timeFlickable.userPlay = !myApp.timeFlickable.userPlay
                }
                text:  myApp.timeFlickable.userPlay ? "Stop" : "Play"
            }

            ProxyButton {
                text: "Record"
                onClicked: myApp.stage.timelinePlay = !myApp.stage.timelinePlay
            }

            ProxyButton {
                text: "Slowmo"
                onClicked: print("undo")
                flickStop: true
            }
        }

        Row {
            width: root.width
            height: parent.height
            layoutDirection: Qt.RightToLeft

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
        }

        Row {
            width: root.width
            height: parent.height
            layoutDirection: Qt.RightToLeft

            ProxyButton {
                text: "Cast"
                onClicked: print("baz")
            }

            ProxyButton {
                text: "Google"
                onClicked: myApp.searchView.search()
            }

            ProxyButton {
                text: "Settings"
                onClicked: print("baz")
            }
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
            duration: Math.abs(buttonRow.x - to)
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
                var dist = root.width - root.mapFromItem(buttonRow, child.x, child.y).x - child.width;
                if ((right && dist > 0 && dist < bestChildDist) || (!right && dist < 0 && dist > bestChildDist)) {
                    bestChild = child;
                    bestChildDist = dist;
                }
            }

            return bestChild;
        }

        function animateToButton(button)
        {
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
                animateToButton(Math.abs(momentumX) > 15 ? closestButton(momentumX > 0) : null);
            }
        }

        onClicked: {
            var p = buttonRow;
            do {
                var pos = mapToItem(p, mouseX, mouseY);
                var child = p.childAt(pos.x, pos.y);
                p = child;
            } while (p && !child.isButton);

            if (child && child.isButton) {
                child.clicked();
            } else {
                child = closestButton(false)
                animateToButton(child ? child : firstButton);
            }
        }
    }

}
