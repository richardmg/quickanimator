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

    MenuRow {
        id: rootMenu

        MenuButton {
            text: "Settings"
        }

        MenuButton {
            text: "Load/Save"
        }

        MenuButton {
            text: "Images"
            menu: imagesMenu
        }

        MenuButton {
            text: "Playback"
            menu: playbackMenu
        }

        MenuButton {
            text: "Action"
            menu: actionMenu
        }
    }

    MenuRow {
        id: imagesMenu

        MenuButton {
            text: "Add"
            menu: addImagesMenu
        }

        MenuButton {
            text: "Remove"
        }

        MenuButton {
            text: "Edit"
        }
    }

    MenuRow {
        id: addImagesMenu

        MenuButton {
            text: "Clone"
        }

        MenuButton {
            text: "Movie"
        }

        MenuButton {
            text: "Search"
            onClicked: myApp.searchView.search()
        }

    }

    MenuRow {
        id: playbackMenu

        MenuButton {
            text: "<<"
            onClicked: myApp.model.setTime(0)
        }

        MenuButton {
            text: ">>"
            onClicked: myApp.model.setTime(100)
        }

        MenuButton {
            text: "Play"
            onClicked: {
                myApp.model.unselectAllSprites()
                myApp.timelineFlickable.userPlay = !myApp.timelineFlickable.userPlay
            }
        }

        MenuButton {
            text: myApp.stage.timelinePlay ? "Stop\nRecording" : "Record"
            onClicked: myApp.stage.timelinePlay = !myApp.stage.timelinePlay
        }

        MenuButton {
            text: "Speed"
        }
    }

    MenuRow {
        id: actionMenu

        MenuButton {
            text: "Undo"
            onClicked: print("bar")
        }

        MenuButton {
            text: "Redo"
            onClicked: print("redo")
        }

        MenuButton {
            text: "Cut"
            onClicked: print("foo")
        }

        MenuButton {
            text: "Brush"
            menu: brushMenu
        }
    }

    MenuRow {
        id: brushMenu

        MenuButton {
            text: "Move"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
                myApp.model.recordsPositionY = true;
            }
        }

        MenuButton {
            text: "Rotate"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsRotation = true;
            }
        }

        MenuButton {
            text: "Scale"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
            }
        }

        MenuButton {
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
