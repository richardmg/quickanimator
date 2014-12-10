import QtQuick 2.0

Item {
    id: menuController

    function toggle() {
        if (currentMenu.sticky) {
            opacity = (opacity > 0) ? 0 : 1
        } else {
            if (opacity < 1)
                opacity = 1
            else
                currentMenu = rootMenu
        }
    }

    function showEditMenu() { currentMenu = editMenu }
    function showActionMenu() { currentMenu = actionMenu }

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
        sticky: true

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

        MenuButton {
            text: "Action"
            menu: actionMenu
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
            text: "Search"
            onClicked: myApp.searchView.search()
        }

        MenuButton {
            text: "Clone"
        }

        MenuButton {
            text: "Movie"
        }
    }

    MenuRow {
        id: playbackMenu

        MenuButton {
            text: "Record speed"
            menu: recordSliderMenu
        }

        MenuButton {
            text: "Play speed"
            menu: playSliderMenu
        }

        MenuButton {
            text: "Record"
            checked: myApp.model.recording
            onClicked: {
                myApp.timeController.userPlay = false
                myApp.model.recording = !myApp.model.recording
            }
        }

        MenuButton {
            text: "<<"
            closeMenuOnClick: false
            onClicked: myApp.model.setTime(0)
        }

        MenuButton {
            text: ">>"
            closeMenuOnClick: false
            onClicked: myApp.model.setTime(myApp.model.endTime + 1)
        }

        MenuButton {
            text: "Play"
            checked: myApp.timeController.userPlay
            onClicked: {
                myApp.model.unselectAllSprites()
                myApp.model.recording = false
                myApp.timeController.userPlay = !myApp.timeController.userPlay
            }
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
            menu: cutMenu
            onClicked: {
                myApp.model.recording = false
                myApp.model.clearRecordState()
                myApp.model.recordsCut = true
            }
        }

        MenuButton {
            text: "Inspect"
            onClicked: print("foo")
        }
    }

    MenuRow {
        id: cutMenu

        MenuButton {
            id: cutButton
            text: "Cut"
            closeMenuOnClick: false
            onClicked: removeCurrentKeyframe()

            Connections {
                target: cutMenu.isCurrent ? myApp.model : null
                onTimeChanged: {
                    if (myApp.model.recordsCut)
                        cutButton.removeCurrentKeyframe()
                }
            }

            function removeCurrentKeyframe()
            {
                if (!myApp.model.hasSelection)
                    return;
                var index = 0;
                var time = Math.floor(myApp.model.time);
                var sprite = myApp.model.selectedSprites[index];
                var keyframe = sprite.getKeyframe(time);
                if (keyframe.time === time)
                    sprite.removeKeyframe(keyframe);
            }
        }

        MenuButton {
            text: "Cut all"
            closeMenuOnClick: false
            onClicked: print("redo")
        }
    }


    MenuRow {
        id: actionMenu

        MenuButton {
            text: "Time"
            closeMenuOnClick: false
        }

        MenuButton {
            text: "Offset"
            closeMenuOnClick: false
        }

        MenuButton {
            text: "Parent"
            closeMenuOnClick: false
        }

        MenuButton {
            text: "Anchors"
            closeMenuOnClick: false
        }

        MenuButton {
            text: "Opacity"
            closeMenuOnClick: false
            menu: opacitySliderMenu
        }

        MenuButton {
            text: "Scale"
            checked: myApp.model.recordsScale
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
            }
        }

        MenuButton {
            text: "Rotate"
            checked: myApp.model.recordsRotation
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsRotation = true;
            }
        }

        MenuButton {
            text: "Move"
            checked: myApp.model.recordsPositionX
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
                myApp.model.recordsPositionY = true;
            }
        }
    }

    OpacitySlider {
        id: opacitySliderMenu
    }

    PlaySlider {
        id: playSliderMenu
        sticky: myApp.timeController.userPlay

        MenuButton {
            text: (myApp.model.targetMpf / myApp.model.mpf).toFixed(1)
            closeMenuOnClick: false
            color: "blue"
            textColor: "white"
        }

        onMultiplierChanged: myApp.model.mpf = myApp.model.targetMpf * multiplier
    }

    PlaySlider {
        id: recordSliderMenu

        MenuButton {
            text: (myApp.model.targetMpf / myApp.model.recordingMpf).toFixed(1)
            closeMenuOnClick: false
            color: "blue"
            textColor: "white"
        }

        onMultiplierChanged: myApp.model.recordingMpf = myApp.model.targetMpf * multiplier
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

        function buttonAt(mouseX, mouseY)
        {
            var p = currentMenu;
            do {
                var pos = mapToItem(p, mouseX, mouseY);
                var child = p.childAt(pos.x, pos.y);
                p = child;
            } while (p && !child.isButton);
            return (child && child.isButton) ? child : null;
        }

        onMomentumXUpdated: {
            if (currentMenu.unflickable)
                return;
            var overshootDist = (momentumX > 0) ? currentMenu.x - flickStopRight : flickStopLeft - currentMenu.x;
            var factor = Math.max(0, Math.min(1, overshootDist / overshoot))
            var increment = momentumX * Math.pow(1 - factor, 2);
            currentMenu.x += increment
            if (!isPressed)
                bounceMenuBack(true)
        }

        onPressed: {
            if (currentMenu.unflickable)
                return;
            bounceAnimation.stop();
            var button = buttonAt(mouseX, mouseY)
            if (button)
                button.pressed = true;
        }

        onReleased: {
            if (currentMenu.unflickable)
                return;
            bounceMenuBack(true)

            var button = buttonAt(mouseX, mouseY)
            if (button) {
                button.pressed = false;
                if (clickCount === 1)
                    button.clicked();
            }
        }
    }

}
