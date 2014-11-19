import QtQuick 2.0
import WebView 1.0

Item {
    id: root

    function showRootMenu() { currentMenu = rootMenu }
    function showSpriteMenu() { currentMenu = spriteMenu }

    property Row currentMenu: rootMenu

    Rectangle {
        id: background
        x: -5
        width: parent.width - (x * 2)
        height: parent.height - x
        anchors.fill: parent
        border.color: "darkblue"
        opacity: 0.5
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
    }

    PlayMenuRow {
        id: rootMenu

        ProxyButton {
            onClicked: myApp.model.setTime(0)
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
            text: myApp.stage.timelinePlay ? "Stop\nRecording" : "Record"
            onClicked: {
                if (myApp.stage.timelinePlay) {
                    myApp.model.unselectAllLayers()
                    myApp.stage.timelinePlay = false
                } else {
                    myApp.stage.timelinePlay = true
                }
            }
        }

        ProxyButton {
            text: "Slowmo"
            onClicked: print("undo")
            flickStop: true
        }
    }

    PlayMenuRow {

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

    PlayMenuRow {
        id: spriteMenu

        ProxyButton {
            text: "Move"
            onClicked: print("Move")
        }

        ProxyButton {
            text: "Rotate"
            onClicked: print("Rotate")
        }

        ProxyButton {
            text: "Scale"
            onClicked: print("Scale")
        }

        ProxyButton {
            text: "More actions"
            onClicked: print("More")
            flickStop: true
        }
    }

    PlayMenuRow {

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

    FlickableMouseArea {
        id: flickable
        anchors.fill: parent

        property int leftStop: parent.width
        property int rightStop: parent.width - currentMenu.width
        property int overshoot: 100

        PropertyAnimation {
            id: snapAnimation
            target: currentMenu
            properties: "x"
            to: 0
            duration: Math.abs(currentMenu.x - to)
            easing.type: Easing.OutExpo
        }

        PropertyAnimation {
            id: bounceAnimation
            target: currentMenu
            properties: "x"
            duration: 200
            easing.type: Easing.OutBounce
        }

        function closestButton(right)
        {
            var children = currentMenu.children;
            var bestChild = null;
            var bestChildDist = right ? Number.MAX_VALUE : -Number.MAX_VALUE

            for (var i in children) {
                var child = children[right ? i : children.length - i - 1];
                var dist = root.width - root.mapFromItem(currentMenu, child.x, child.y).x - child.width;
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
            } else if (currentMenu.x < rightStop) {
                stopMomentumX();
                snapAnimation.stop();
                bounceAnimation.to = rightStop
                bounceAnimation.restart();
            }
        }

        onMomentumXUpdated: {
            // Ensure that the menu cannot be dragged passed the stop
            // points, and apply some overshoot resitance.
            var dist = Math.max(0, rightStop - currentMenu.x);
            currentMenu.x += momentumX * Math.pow(1 - (dist / overshoot), 2);
            if (currentMenu.x > leftStop)
                currentMenu.x = leftStop;
            else if (currentMenu.x < rightStop - overshoot)
                currentMenu.x = rightStop - overshoot;
        }

        onPressed: {
            snapAnimation.stop();
            bounceAnimation.stop();
        }

        onReleased: {
            if (!clickCount) {
                animateToButton(Math.abs(momentumX) > 15 ? closestButton(momentumX > 0) : null);
                return;
            }

            var p = currentMenu;
            do {
                var pos = mapToItem(p, mouseX, mouseY);
                var child = p.childAt(pos.x, pos.y);
                p = child;
            } while (p && !child.isButton);

            if (child && child.isButton) {
                child.clicked();
            } else {
                child = closestButton(false)
                animateToButton(child ? child : rootMenu);
            }
        }
    }

}
