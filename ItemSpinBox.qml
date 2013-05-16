import QtQuick 2.1
import QtQuick.Controls 1.0

SpinBox {
    id: spinbox
    implicitWidth: 100
    property Item target: myApp.timeline.selectedLayer ? myApp.timeline.selectedLayer.sprite : null;
    property string property: ""
    enabled: target
    decimals: 3
    minimumValue: -9999
    maximumValue: 9999
    property real proxy: 0
    value: proxy

    Component.onCompleted: proxy = Qt.binding(function() {
        return target ? target[property].toFixed(decimals) : 0
    })

    onValueChanged: if (value !== proxy) {
        target[property] = value;
        myApp.timeline.selectedState[property] = value
    }
}
