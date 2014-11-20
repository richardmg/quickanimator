import QtQuick 2.0
import WebView 1.0

Item {
    id: root

    function showRootMenu() { currentMenu = rootMenu }
    function showSpriteMenu() { currentMenu = spriteMenu }

    function toggleMenuVisible() { opacity = opacity > 0 ? 0 : 1 }

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
                myApp.timelineFlickable.userPlay = !myApp.timelineFlickable.userPlay
            }
            text: "Play"
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
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
                myApp.model.recordsPositionY = true;
                root.opacity = 0
            }
        }

        ProxyButton {
            text: "Rotate"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsRotation = true;
            }
        }

        ProxyButton {
            text: "Scale"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
            }
        }

        ProxyButton {
            text: "Opacity"
            closeMenuOnClick: false
            onClicked: currentMenu = opacityMenu
        }

        ProxyButton {
            text: "|"
        }

        ProxyButton {
            text: myApp.stage.timelinePlay ? "Stop\nRecording" : "Record"
            onClicked: {
                if (myApp.stage.timelinePlay) {
                    myApp.stage.timelinePlay = false
                } else {
                    myApp.stage.timelinePlay = true
                }
            }
        }

        ProxyButton {
            text: "|"
        }

        ProxyButton {
            text: "More actions"
            onClicked: print("More")
            flickStop: true
        }
    }

    OpacitySlider {
        id: opacityMenu
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

        property int flickStopRight: Math.max(0, parent.width - currentMenu.width)
        property int flickStopLeft: Math.min(0, parent.width - currentMenu.width)
        property int overshoot: 100

        PropertyAnimation {
            id: bounceAnimation
            target: currentMenu
            properties: "x"
            duration: 200
            easing.type: Easing.OutBounce
        }

        function bounceMenuBack(onlyIfOutside)
        {
            if (currentMenu.x > flickStopRight || !onlyIfOutside) {
                stopMomentumX();
                bounceAnimation.to = flickStopRight
                bounceAnimation.restart();
            } else if (currentMenu.x < flickStopLeft) {
                stopMomentumX();
                bounceAnimation.to = flickStopLeft
                bounceAnimation.restart();
            }
        }

        onMomentumXUpdated: {
            var overshootDist = (momentumX > 0) ? currentMenu.x - flickStopRight : flickStopLeft - currentMenu.x;
            var factor = Math.max(0, Math.min(1, overshootDist / overshoot))
            var increment = momentumX * Math.pow(1 - factor, 2);
            currentMenu.x += increment
            if (!isPressed)
                bounceMenuBack(true)
        }

        onPressed: {
            bounceAnimation.stop();
        }

        onReleased: {
            bounceMenuBack(true)

            if (!clickCount)
                return

            var p = currentMenu;
            do {
                var pos = mapToItem(p, mouseX, mouseY);
                var child = p.childAt(pos.x, pos.y);
                p = child;
            } while (p && !child.isButton);

            if (child && child.isButton)
                child.clicked();
            else
                bounceMenuBack(false)
        }
    }

}
