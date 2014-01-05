import QtQuick 2.0

Item {
    id: root
    visible: false

    property int _spacing: 5
    property Item _highlightedButton

    readonly property bool typeSubMenu: true
    property list<Item> originalChildren

    Component.onCompleted: {
        originalChildren = children;
        var p = parent;
        while (p && p.parent)
            p = p.parent;
        for (var i = 0; i < originalChildren.length; ++i) {
            var child = originalChildren[i];
            child.originalParent = root;
            child.parent = p;
        }
    }

    Connections {
        target: myApp.controlPanel
        onCloseAllMenus: openMenu(false)
    }

    function openMenu(open)
    {
        for (var i = 0; i < originalChildren.length; ++i) {
            var child = originalChildren[i];
            if (child.showButton)
                child.showButton(open, i);
        }
    }

//    function mouseMoved(globalPos)
//    {
//        var button = getButton(globalPos);
//        if (_highlightedButton && button !== _highlightedButton)
//            _highlightedButton.hovered = false;
//        _highlightedButton = button;
//        if (_highlightedButton)
//            _highlightedButton.hovered = true;
//    }

//    function getButton(globalPos)
//    {
//        var gridPos = grid.mapFromItem(null, globalPos.x, globalPos.y)
//        return grid.childAt(gridPos.x, gridPos.y);
//    }
}
