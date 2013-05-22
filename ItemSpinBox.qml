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

    property Item _boundTarget
    property string _boundProperty
    property bool _guard: false

    onTargetChanged: _setupConnection(true);
    onPropertyChanged: _setupConnection(true);

    onValueChanged: {
        if (_guard)
            return;
        if (!target)
            return;
        var state = target.getCurrentState();
        var time = myApp.timeline.timelineGrid.time;
        if (myApp.timeline.tweenMode && state.time !== time) {
            state = target.createState(time);
            myApp.timeline.timelineGrid.repaint();
        }
        if (!state)
            return;
        target[property] = spinbox.value;
        state[property] = spinbox.value; 
    }

    function _setupConnection(set)
    {
        if (property === "" || !target || !set) {
            if (_boundTarget)  {
                spinbox._boundTarget[_boundProperty].disconnect(targetListener)
                _boundTarget = null;
            }
            return;
        }

        var state = target.getCurrentState().name;
        if (!state)
            return;

        _boundTarget = target;
        _boundProperty = spinbox.property + "Changed";
        spinbox._boundTarget[_boundProperty].connect(targetListener)
    }

    function targetListener() {
        _guard = true;
        spinbox.value = spinbox.target[property];
        _guard = false;
    }
}
