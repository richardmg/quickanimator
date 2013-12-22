import QtQuick 2.1

Row {
    spacing: 2
    anchors.leftMargin: spacing
    anchors.rightMargin: spacing
    anchors.topMargin: spacing
    anchors.bottomMargin: spacing

    x: spacing;
    y: spacing
    width: childrenRect.width
    height: parent.height - spacing - spacing
}
