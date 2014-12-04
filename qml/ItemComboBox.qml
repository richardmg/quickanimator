import QtQuick 2.1
import QtQuick.Controls 1.0

ComboBox {
    model: ["linear", "bounce", "immediate", "none"]
    property Item target: myApp.timelineFlickable.selectedSprite ? myApp.timelineFlickable.selectedSprite.sprite : null;
    enabled: target
}
