import QtQuick 2.1
import QtQuick.Controls 1.0

SpinBox {
    id: spinbox
    implicitWidth: 100
    property string property: ""
    enabled: false
    decimals: 3
    minimumValue: -9999
    maximumValue: 9999

    property Item _boundTarget
    property string _boundProperty
    property bool _guard: false

    Connections {
        target: myApp.timeline
        onSelectedStateChanged: _updateState();
    }

    onPropertyChanged: _updateState();

    onValueChanged: {
        if (_guard)
            return;

        var state = myApp.timeline.selectedState;
        var time = myApp.timeline.timelineGrid.selectedX;

        if (state.time !== time) {
            state = state.sprite.createState(time);
            myApp.timeline.timelineGrid.repaint();
        }

        state[property] = spinbox.value; 
        state.sprite[property] = spinbox.value;
    }

    function _updateState()
    {
        if (!myApp.timeline)
            return;
        if (_boundTarget)  {
            spinbox._boundTarget[_boundProperty].disconnect(targetListener)
            _boundTarget = null;
        }

        var state = myApp.timeline.selectedState;

        if (property === "" || !state) {
            _guard = true;
            spinbox.value = 0;
            spinbox.enabled = false;
            _guard = false;
            return;
        }

        spinbox.enabled = true;
        _boundTarget = state.sprite;
        _boundProperty = spinbox.property + "Changed";
        spinbox._boundTarget[_boundProperty].connect(targetListener)
        _guard = true;
        spinbox.value = state.sprite[property];
        _guard = false;
    }

    function targetListener() {
        _guard = true;
        spinbox.value = myApp.timeline.selectedState.sprite[property];
        _guard = false;
    }
}
