import QtQuick 2.0

Row {
    id: root
    height: parent.height
    width: childrenRect.width
    x: parent.width - width
    opacity: menuIndex === menuRows.indexOf(root) && !myApp.model.fullScreenMode ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
}
