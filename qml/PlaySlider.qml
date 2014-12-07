import QtQuick 2.0

MenuRow {
    property real multiplier: 1
    onXChanged: multiplier = (parent.width - width) / Math.max(1, x)
}
