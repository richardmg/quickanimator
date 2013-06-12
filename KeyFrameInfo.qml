import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Column {
    spacing: 5
    TitleBar {
        title: "Keyframe"
    }
    GridLayout {
        x: 5
        rowSpacing: 2
        columns: 3

        Label {
            text: "name:"
            Layout.alignment: Qt.AlignRight
        }
        TextField {
            id: stateName
            Layout.columnSpan: 2
            enabled: false

            onTextChanged: {
                if (timeline.selectedState)
                    timeline.selectedState.name = text;
            }

            Connections {
                target: timeline
                onSelectedStateChanged: {
                    if (timeline.selectedState) {
                        stateName.enabled = true;
                        stateName.text = timeline.selectedState.name;
                    } else {
                        stateName.enabled = false;
                        stateName.text = "";
                    }
                }
            }
        }
        Label {
            text: "x:"
            Layout.alignment: Qt.AlignRight
        }
        ItemSpinBox {
            property: "x"
        }
        ItemComboBox { }
        Label {
            text: "y:"
            Layout.alignment: Qt.AlignRight
        }
        ItemSpinBox {
            property: "y"
        }
        ItemComboBox { }
        Label {
            text: "z:"
            Layout.alignment: Qt.AlignRight
        }
        ItemSpinBox {
            property: "z"
            minimumValue: 0
        }
        ItemComboBox { }
        Label {
            text: "rotation:"
            Layout.alignment: Qt.AlignRight
        }
        ItemSpinBox {
            property: "rotation"
            stepSize: 45
        }
        ItemComboBox { }
        Label {
            text: "scale:"
            Layout.alignment: Qt.AlignRight
        }
        ItemSpinBox {
            property: "scale"
            stepSize: 0.1
            minimumValue: 0
        }
        ItemComboBox { }
        Label {
            text: "opacity:"
            Layout.alignment: Qt.AlignRight
        }
        ItemSpinBox {
            property: "opacity"
            stepSize: 0.1
            minimumValue: 0
            maximumValue: 1
        }
        ItemComboBox { }
        Button {
            Layout.columnSpan: 3
            text: "Remove state"
            onClicked: timeline.removeCurrentState();
        }
    }
}
