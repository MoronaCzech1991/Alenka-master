import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Universal 2.1
import QtQuick.Window 2.2
import "../+universal"


Item {
    id: colorGradientPopup

    property alias applyButton: applyButton
    property alias cancelButton: cancelButton
    property alias backButton: backButton
    property alias tileRepeater: tileRepeater
    property alias rangeSlider: rangeSlider
    property alias gradient: gradient
    property alias minSpinBox: minSpinBox
    property alias maxSpinBox: maxSpinBox

    Rectangle {
        anchors.fill: parent
        color: "lightgrey"
    }

    Button {
        id: backButton
        x: 10
        y: 10
        text: "<- Back"
        width: 200
        height: 50
        font.pixelSize: 30
    }

    Rectangle {
        color: "white"
        x: (parent.width - column.width) / 2
        y: (parent.height - column.height) / 6
        border.color: "black"
        border.width: 1
        width: column.width
        height: column.height

        Column {
            id: column
            spacing: 10
            padding: 10

            Label {
                text: "<b>Change colors</b>"
            }

            Label {
                text: "Drag number and drop it on a color you want to choose. You can see the change on the color bar below. You can also set a range of spikes."
                width: colorGrid.width
                wrapMode: Text.WordWrap
                font.pixelSize: 16
            }

            Grid {
                id: colorGrid
                spacing: 10
                columns: 7
                Repeater {
                    model: [Universal.color(Universal.Lime), Universal.color(Universal.Green),
                        Universal.color(Universal.Emerald), Universal.color(Universal.Teal),
                        Universal.color(Universal.Cyan), Universal.color(Universal.Cobalt),
                        Universal.color(Universal.Indigo), Universal.color(Universal.Violet),
                        Universal.color(Universal.Pink), Universal.color(Universal.Magenta),
                        Universal.color(Universal.Crimson), Universal.color(Universal.Red),
                        Universal.color(Universal.Orange), Universal.color(Universal.Amber),
                        Universal.color(Universal.Yellow), Universal.color(Universal.Brown),
                        Universal.color(Universal.Olive), Universal.color(Universal.Steel),
                        Universal.color(Universal.Mauve), Universal.color(Universal.Taupe),
                        "white"]
                    DropArea {
                        id: dragTarget
                        property alias dropProxy: dragTarget
                        property alias color: colorRectangle.color
                        width: 60
                        height: 60
                        Rectangle {
                            id: colorRectangle
                            anchors.fill: parent
                            color: modelData
                            border.color: "black"
                            border.width: 1
                            states: [
                                State {
                                    when: dragTarget.containsDrag
                                    PropertyChanges {
                                        target: colorRectangle
                                        opacity: 0.5
                                    }
                                }
                            ]
                        }
                    }
                }
            }

            Item {
                height: 20
                width: 300
                Label {
                    x: 0
                    text: qsTr("min")
                }
                Rectangle {
                    id: gradientRectangle
                    width: 20
                    height: 240
                    x: 150
                    y: -110
                    clip: true
                    rotation: -90
                    Column {
                        spacing: 23
                        topPadding: 3

                        Repeater {
                            model: 5
                            Label {
                                z: gradientRectangle.z + 3
                                text: index + 1
                                rotation: 90
                                verticalAlignment: Text.AlignTop
                                horizontalAlignment: Text.AlignRight
                                rightPadding: 9
                            }
                        }
                    }
                    gradient: Gradient {
                        id: gradient
                        GradientStop { position: 0.1 }
                        GradientStop { position: 0.3 }
                        GradientStop { position: 0.5 }
                        GradientStop { position: 0.7 }
                        GradientStop { position: 0.9 }
                    }
                }

                Label {
                    x: 290
                    text: qsTr("max")
                }
            }

            Row {
                spacing: 20

                Repeater {
                    id: tileRepeater
                    model: 5

                    Item {
                        id: root
                        width: 60
                        height: 60
                        property alias mouseArea: mouseArea

                        MouseArea {
                            id: mouseArea
                            width: 60
                            height: 60
                            drag.target: tile
                            onReleased: {
                                parent = tile.Drag.target !== null ? tile.Drag.target : root
                                if (parent !== root) {
                                    setColor(tile.gradientNum, tile.Drag.target.color)
                                }
                            }

                            Rectangle {
                                id: tile
                                width: 60
                                height: 60
                                property int gradientNum: index
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "transparent"
                                border.color: "black"

                                Drag.active: mouseArea.drag.active
                                Drag.hotSpot.x: width / 2
                                Drag.hotSpot.y: height / 2

                                Text {
                                    text: index + 1
                                    font.pixelSize: 30
                                    anchors.fill: parent
                                    horizontalAlignment:Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                states: State {
                                    when: mouseArea.drag.active
                                    ParentChange { target: tile; parent: root }
                                    AnchorChanges { target: tile; anchors.verticalCenter: undefined; anchors.horizontalCenter: undefined }
                                }
                            }
                        }
                    }
                }

            }

            Row {
                spacing: 10

                Label {
                    text: electrodePlacement.minSpikes
                }

                RangeSlider {
                    id: rangeSlider
                    from: electrodePlacement.minSpikes
                    to: electrodePlacement.maxSpikes
                    first.value: electrodePlacement.minSpikes
                    second.value: electrodePlacement.maxSpikes
                    width: colorGrid.width - 100
                }

                Label {
                    text: electrodePlacement.maxSpikes
                }
            }

            Row {

                spacing: 10

                Label {
                    text: "From"
                }

                SpinBox {
                    id: minSpinBox
                    value: Math.round(rangeSlider.first.value)
                    from: minSpikes
                    to: rangeSlider.second.value
                    onValueChanged: { if (up.pressed || down.pressed) rangeSlider.setValues(value, rangeSlider.second.value) }
                }

                Label {
                    text: "to"
                }

                SpinBox {
                    id: maxSpinBox
                    value: Math.round(rangeSlider.second.value)
                    from: rangeSlider.first.value
                    to: maxSpikes
                    onValueChanged: { if (up.pressed || down.pressed) rangeSlider.setValues(rangeSlider.first.value, value) }
                }
            }

            Row {
                spacing: 20
                Button {
                    id: cancelButton
                    text: qsTr("Cancel")
                    width: 230
                }
                Button {
                    id: applyButton
                    text: qsTr("Apply")
                    width: 230
                }
            }
        }
    }
}
