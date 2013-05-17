import QtQuick 2.1
import QtQuick.Controls 1.0

ComboBox {
    model: ["linear", "bounce", "immediate", "none"]
    property Item target: myApp.timeline.selectedLayer ? myApp.timeline.selectedLayer.sprite : null;
    enabled: target
}
