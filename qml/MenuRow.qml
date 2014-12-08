import QtQuick 2.0

Row {
    id: root
    x: parent.width - width
    width: childrenRect.width
    height: parent.height
    opacity: parent.currentMenu === root ? 1 : 0
    visible: opacity != 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    readonly property bool isCurrent: root === currentMenu
    property bool sticky: false
    property bool unflickable: false
}
