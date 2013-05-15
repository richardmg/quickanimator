import QtQuick 2.1
import QtQuick.Controls 1.0

SpinBox {
    id: spinbox
    property Item target: myApp.storyBoard.selectedLayer ? myApp.storyBoard.selectedLayer.sprite : null;
    property string property: ""
    enabled: target
    decimals: 3
    minimumValue: -9999
    maximumValue: 9999
    value: proxy

    property real proxy: target ? target[property].toFixed(decimals) : 0
    onValueChanged: if (value !== proxy) {
        target[property] = value;
        myApp.storyBoard.selectedState[property] = value
    }
}
