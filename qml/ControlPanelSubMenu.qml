import QtQuick 2.0

Rectangle {
    id: root
    color: myApp.style.dark
    visible: transScaleY !== 0
    radius: 4

    property real transScaleY: 0
    transform: [ Scale { id: tScale; xScale: 1; yScale: transScaleY; origin.x: 0; origin.y: height } ]

    property alias data: grid.data

    property int _spacing: 5
    property Item _highlightedButton
    Behavior on transScaleY {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    function openMenu(globalPos)
    {
        var p = parent;
        while (p.parent)
           p = p.parent
        parent = p;

        width = childrenRect.width
        height = childrenRect.height

        x = globalPos.x - _spacing;
        y = globalPos.y - height;

        transScaleY = 1;
    }

    function closeMenu()
    {
        transScaleY = 0;
        if (_highlightedButton) {
            _highlightedButton.clicked();
            _highlightedButton.hovered = false;
            _highlightedButton = null;
        }
    }

    function mouseMoved(globalPos)
    {
        var button = getButton(globalPos);
        if (_highlightedButton && button !== _highlightedButton)
            _highlightedButton.hovered = false;
        _highlightedButton = button;
        if (_highlightedButton)
            _highlightedButton.hovered = true;
    }

    function getButton(globalPos)
    {
        var gridPos = grid.mapFromItem(null, globalPos.x, globalPos.y)
        return grid.childAt(gridPos.x, gridPos.y);
    }

    Grid {
        id: grid
        spacing: root._spacing
        x: spacing
        y: spacing
        width: childrenRect.width + (x * 2)
        height: childrenRect.height + (y * 2)
        columns: 3
    }
}
