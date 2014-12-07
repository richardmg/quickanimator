import QtQuick 2.0

Item {
    id: menuController

    function toggle() {
        if (currentMenu === rootMenu) {
            opacity = (opacity > 0) ? 0 : 1
        } else {
            if (opacity < 1)
                opacity = 1
            else
                currentMenu = rootMenu
        }
    }

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
            text: "File"
            menu: filesMenu
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
            text: "Edit"
            menu: editMenu
        }
    }

    MenuRow {
        id: filesMenu

        MenuButton {
            text: "New"
            onClicked: myApp.model.newMovie()
        }

        MenuButton {
            text: "Load"
        }

        MenuButton {
            text: "Save"
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
            closeMenuOnClick: false
            onClicked: myApp.model.setTime(0)
        }

        MenuButton {
            text: ">>"
            closeMenuOnClick: false
            onClicked: myApp.model.setTime(myApp.model.endTime)
        }

        MenuButton {
            text: "Play"
            menu: playSliderMenu
        }
    }

    MenuRow {
        id: editMenu

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
            text: "Single\nframe"
            closeMenuOnClick: false
            onClicked: {
                myApp.timelineFlickable.userPlay = false
                currentMenu = brushMenu
            }
        }

        MenuButton {
            text: "Record\nframes"
            closeMenuOnClick: false
            onClicked: {
                myApp.timelineFlickable.userPlay = true
                currentMenu = brushMenu
            }
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
                if (myApp.timelineFlickable.userPlay)
                    currentMenu = recordSliderMenu
            }
        }

        MenuButton {
            text: "Rotate"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsRotation = true;
                if (myApp.timelineFlickable.userPlay)
                    currentMenu = recordSliderMenu
            }
        }

        MenuButton {
            text: "Scale"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
                if (myApp.timelineFlickable.userPlay)
                    currentMenu = recordSliderMenu
            }
        }

        MenuButton {
            text: "Opacity"
            closeMenuOnClick: false
            onClicked: currentMenu = opacitySliderMenu
        }
    }

    OpacitySlider {
        id: opacitySliderMenu
    }

    PlaySlider {
        id: playSliderMenu

        MenuButton {
            text: myApp.timelineFlickable.userPlay ? "Stop" : "Play"
            closeMenuOnClick: false
            color: "blue"
            textColor: "white"
            onClicked: {
                if (myApp.timelineFlickable.userPlay) {
                    menuController.opacity = 0
                    myApp.timelineFlickable.userPlay = false;
                } else {
                    myApp.timelineFlickable.userPlay = true;
                }
            }
        }

        onIsCurrentChanged: {
            myApp.model.unselectAllSprites()
            if (isCurrent) {
                menuController.opacity = 0
                myApp.timelineFlickable.userPlay = true
            }
        }

        Connections {
            target: playSliderMenu.isCurrent ? myApp.model : null
            onTimeChanged: {
                if (myApp.model.time >= myApp.model.endTime) {
                    menuController.currentMenu = rootMenu
                    myApp.timelineFlickable.userPlay = false;
                    myApp.model.unselectAllSprites()
                }
            }

        }
    }

    PlaySlider {
        id: recordSliderMenu

        MenuButton {
            text: myApp.stage.timelinePlay ? "Stop" : "Record"
            closeMenuOnClick: false
            color: "blue"
            textColor: "white"
            onClicked: {
                if (myApp.stage.timelinePlay) {
                    menuController.opacity = 0
                    myApp.stage.timelinePlay = false
                    myApp.model.unselectAllSprites()
                } else {
                    myApp.stage.timelinePlay = true
                }
            }
        }

        onIsCurrentChanged: {
            if (isCurrent) {
                menuController.opacity = 0
                myApp.stage.timelinePlay = true
            }
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
