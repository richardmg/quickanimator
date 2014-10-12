import QtQuick 2.0

QtObject {
    property var items: new Array

    function updateChecked(item)
    {
        if (!item.checked)
            return

        for (var i in items) {
            var listItem = items[i];
            if (listItem === item)
                continue
            listItem.checked = false
        }
    }

    function addItem(item)
    {
        items.push(item)
        item.checkedChanged.connect(function(){ updateChecked(item) })
    }
}
