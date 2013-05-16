import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: myApp
    width: 800
    height: 600
    property alias timeline: timeline

    SplitView {
        orientation: Qt.Vertical
        anchors.fill: parent

        SplitView {
            width: parent.width
            height: 2 * parent.height / 3

            Column {
                id: imageProps
                width: parent.width / 3
                onWidthChanged: keyframeProps.width = width
                height: parent.height
                spacing: 5
                TitleBar {
                    title: "Image"
                    TitleBarRow {
                        layoutDirection: Qt.RightToLeft
                        ToolButton {
                            text: "+"
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: myApp.addImage("dummy.jpeg") 
                        }
                    }
                }
                TextField {
                    x: 3
                    placeholderText: "name"
                }
            }
            Stage {
                id: stage
                width: 2 * parent.width / 3
                height: parent.height
                clip: true
                timeline: timeline
            }
        }
        SplitView {
            width: parent.width
            height: parent.height / 3
            Column {
                id: keyframeProps
                width: parent.width / 3
                height: parent.height
                onWidthChanged: imageProps.width = width
                spacing: 5
                TitleBar {
                    title: "Keyframe"
                }
                GridLayout {
                    x: 5
                    rowSpacing: 2
                    columns: 2

                    Label {
                        text: "name:"
                        Layout.alignment: Qt.AlignRight
                    }
                    TextField {
                        id: stateName
                        enabled: timeline.selectedState;
                        onTextChanged: timeline.selectedState.name = text;
                        Connections {
                            target: timeline
                            onSelectedStateChanged: {
                                if (timeline.selectedState)
                                    stateName.text = timeline.selectedState.name;
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
                    Label {
                        text: "y:"
                        Layout.alignment: Qt.AlignRight
                    }
                    ItemSpinBox {
                        property: "y"
                    }
                    Label {
                        text: "rotation:"
                        Layout.alignment: Qt.AlignRight
                    }
                    ItemSpinBox {
                        property: "rotation"
                        stepSize: 45
                    }
                    Label {
                        text: "scale:"
                        Layout.alignment: Qt.AlignRight
                    }
                    ItemSpinBox {
                        property: "scale"
                        stepSize: 0.1
                        minimumValue: 0
                    }
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
                }
            }
            Timeline {
                id: timeline
                width: 2 * parent.width / 3
                height: parent.height
            }
        }
    }

    Component {
        id: stageSpriteComponent
        StageSprite {
            Image {
                source: "dummy.jpeg"
            }
        }
    }

    function addImage(url)
    {
        var layer = {}
        layer.sprite = stageSpriteComponent.createObject(stage.sprites)
        timeline.addLayer(layer);
    }
}
