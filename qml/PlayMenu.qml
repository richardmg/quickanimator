import QtQuick 2.0

Item {
    id: menuController

    function showRootMenu() { currentMenu = rootMenu }
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
            text: "Settings"
        }

        ProxyButton {
            text: "Load/Save"
        }

        ProxyButton {
            text: "Images"
            menu: imagesMenu
        }

        ProxyButton {
            text: "Playback"
            menu: playbackMenu
        }

        ProxyButton {
            text: "Action"
            menu: actionMenu
        }
    }

    PlayMenuRow {
        id: imagesMenu

        ProxyButton {
            text: "Add"
            menu: addImagesMenu
        }

        ProxyButton {
            text: "Remove"
        }

        ProxyButton {
            text: "Edit"
        }
    }

    PlayMenuRow {
        id: addImagesMenu

        ProxyButton {
            text: "Clone"
        }

        ProxyButton {
            text: "Movie"
        }

        ProxyButton {
            text: "Search"
            onClicked: myApp.searchView.search()
        }

    }

    PlayMenuRow {
        id: playbackMenu

        ProxyButton {
            text: "<<"
            onClicked: myApp.model.setTime(0)
        }

        ProxyButton {
            text: ">>"
            onClicked: myApp.model.setTime(100)
        }

        ProxyButton {
            text: "Play"
            onClicked: {
                myApp.model.unselectAllSprites()
                myApp.timelineFlickable.userPlay = !myApp.timelineFlickable.userPlay
            }
        }

        ProxyButton {
            text: myApp.stage.timelinePlay ? "Stop\nRecording" : "Record"
            onClicked: myApp.stage.timelinePlay = !myApp.stage.timelinePlay
        }

        ProxyButton {
            text: "Speed"
        }
    }

    PlayMenuRow {
        id: actionMenu

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
        }

        ProxyButton {
            text: "Brush"
            menu: brushMenu
        }
    }

    PlayMenuRow {
        id: brushMenu

        ProxyButton {
            text: "Move"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
                myApp.model.recordsPositionY = true;
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
    }

    OpacitySlider {
        id: opacityMenu
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
