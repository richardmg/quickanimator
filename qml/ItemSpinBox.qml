import QtQuick 2.1
import QtQuick.Controls 1.0

SpinBox {
    id: spinbox
    implicitWidth: 100
    property string property: ""
    property string keyframeProperty: ""
    enabled: false
    decimals: 3
    minimumValue: -9999
    maximumValue: 9999

    property Item _boundTarget
    property string _boundProperty
    property bool _guard: false

    Connections {
        target: myApp.model
        onFocusedKeyframeChanged: _updateState();
    }
    onPropertyChanged: _updateState();

    onValueChanged: {
        if (_guard)
            return;

        var keyframe = myApp.model.focusedKeyframe

        keyframe[keyframeProperty != "" ? keyframeProperty : property] = spinbox.value; 
        keyframe.sprite[property] = spinbox.value;
    }

    function _updateState()
    {
        if (_boundTarget)  {
            spinbox._boundTarget[_boundProperty].disconnect(targetListener)
            _boundTarget = null;
        }

        var keyframe = myApp.model.focusedKeyframe;

        if (property === "" || !keyframe) {
            _guard = true;
            spinbox.value = 0;
            spinbox.enabled = false;
            _guard = false;
            return;
        }

        spinbox.enabled = true;
        _boundTarget = keyframe.sprite;
        _boundProperty = spinbox.property + "Changed";
        spinbox._boundTarget[_boundProperty].connect(targetListener)
        _guard = true;
        spinbox.value = keyframe.sprite[property];
        _guard = false;
    }

    function targetListener() {
        _guard = true;
        spinbox.value = myApp.model.focusedKeyframe.sprite[property];
        _guard = false;
    }
}
