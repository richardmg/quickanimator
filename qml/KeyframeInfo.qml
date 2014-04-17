import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import WebView 1.0

Rectangle {
    id: root
    color: myApp.style.dark

    WebView {
        id: webView
        onImageUrlChanged: myApp.addImage(imageUrl);
    }

    Column {
        spacing: 5
        y: 10
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
                    if (myApp.timeline.focusedKeyframe)
                        myApp.timeline.focusedKeyframe.name = text;
                }

                Connections {
                    target: myApp.model
                    onFocusedKeyframeChanged: {
                        if (myApp.model.focusedKeyframe) {
                            stateName.enabled = true;
                            stateName.text = myApp.model.focusedKeyframe.name;
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
                stepSize: 1
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
                text: stateName.enabled ? "Delete keyframe" : "Create keyframe"
                onClicked: {
                    if (stateName.enabled)
                        myApp.model.removeFocusedKeyframe();
                    else
                        myApp.model.syncLayer(myApp.model.layers[myApp.model.focusedLayerIndex]);
                }
            }
            Button {
                Layout.columnSpan: 3
                text: "Google image search"
                onClicked: webView.search();
            }
        }
    }
}
