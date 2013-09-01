import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Rectangle {
    id: root

    gradient: Gradient {
        GradientStop {
            position: 0.0;
            color: Qt.lighter(myApp.style.accent, 1.3)
        }
        GradientStop {
            position: 200.0 / height;
            color: Qt.lighter(myApp.style.accent, 1.5)
        }
    }
    Column {
        spacing: 5
        TitleBar {
            title: "Keyframe"
            width: root.width
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
                    if (timeline.selectedKeyframe)
                        timeline.selectedKeyframe.name = text;
                }

                Connections {
                    target: myApp.model
                    onFocusStateChanged: {
                        if (myApp.model.focusState) {
                            stateName.enabled = true;
                            stateName.text = myApp.model.focusState.name;
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
                property: "transRotation"
                keyframeProperty: "rotation"
                stepSize: 1
            }
            ItemComboBox { }
            Label {
                text: "scale:"
                Layout.alignment: Qt.AlignRight
            }
            ItemSpinBox {
                property: "transScaleX"
                keyframeProperty: "scale"
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
                onClicked: myApp.model.removeFocusState();
            }
        }
    }
}
