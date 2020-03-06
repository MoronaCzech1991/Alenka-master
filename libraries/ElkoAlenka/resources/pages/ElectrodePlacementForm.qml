import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls 2.1
import QtQuick.Controls.Universal 2.1
import "../+universal"

Controls.SplitView {
    id: electrodePlacement

    property alias zoomSwitch: zoomSwitch
    property alias fixButton: fixButton
    property alias statisticsTableButton: statisticsTableButton
    property alias comboBox: comboBox
    property alias electrodeRep: electrodeRep
    property alias electrodePlacement: electrodePlacement
    property alias statisticsButton: statisticsButton
    property alias scrollIndicator: scrollIndicator
    property alias column: column
    property alias imageArea: imageArea
    property alias gradientMouse: gradientMouse
    property alias gradient: gradient
    property alias gradientParent: gradientParent
    property alias colorDialog: colorDialog
    property alias statisticsTable: statisticsTable

    property string name: qsTr("Electrode Placement")
    property int zHighest: 0
    property bool zoomEnabled: false
    property var images: []
    property int minSpikes: 0
    property int maxSpikes: 0
    property int customMinSpikes: 0
    property int customMaxSpikes: 0
    property ListModel electrodes: ListModel {}
    property ListModel electrodeSpikesModel: ListModel {} //ListElement {name: "C3", spikes: "5"}, for statisticsTable

    orientation: Qt.Horizontal
    onMinSpikesChanged: customMinSpikes = minSpikes
    onMaxSpikesChanged: customMaxSpikes = maxSpikes
//    onImagesChanged: reset()

    DropArea {
        id: imageArea
        Layout.minimumWidth: 3/4 * window.width

        Rectangle {
            anchors.fill: parent
            color: "white"
            height: window.height

            Grid {
                id: imagesGrid
                columns: images == null ? 0 : (images.length == 2 ? 2 : Math.round(images.length/2))
                rows: images == null ? 0 : ((images.length == 1 || images.length == 2)  ? 1 : 2)
                spacing: 5
                padding: 10
                Repeater {
                    model: images
                    Image {
                        id: brainImage
                        source: modelData
                        fillMode: Image.PreserveAspectFit
                        width: (imageArea.width-imagesGrid.spacing*(imagesGrid.columns+1))/imagesGrid.columns
                        height: (imageArea.height-imagesGrid.spacing*(imagesGrid.rows+1))/imagesGrid.rows
                        verticalAlignment: (index % 2 == 1) ? Image.AlignBottom : Image.AlignTop
                    }
                }
            }
            PinchArea {
                enabled: zoomEnabled
                anchors.fill: parent
                pinch.target: imageArea
                pinch.minimumScale: 1
                pinch.maximumScale: 10
                pinch.dragAxis: Pinch.XAndYAxis
                onSmartZoom: {
                    imageArea.scale = pinch.scale
                }
                MouseArea {
                    enabled: zoomEnabled
                    hoverEnabled: true
                    anchors.fill: parent
                    anchors.centerIn: parent
                    scrollGestureEnabled: false  // 2-finger-flick gesture should pass through to the Flickable
                    onWheel: imageArea.scale += imageArea.scale * wheel.angleDelta.y / 120 / 10;
                    onDoubleClicked: { //reset zoom
                        imageArea.scale = 1;
                        imageArea.x = 0;
                        imageArea.y = 0;
                    }
                }
            }
        }



        Dialog {
            id: statisticsTable
            modal: true
            focus: true
            x: (window.width - width) / 2
            y: 10
            width: window.width / 3
            //            height: parent.height - 20
            contentHeight: window.height - window.footer.height - window.header.height
            title: "<b>Statistics table</b>"
            standardButtons: Dialog.Ok

            Flickable {
                id: flickable
                boundsBehavior: Flickable.OvershootBounds
                anchors.fill: parent
                contentHeight: dialogColumn.height
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: "white"
                }

                Column {
                    id: dialogColumn
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: electrodeSpikesModel

                        Row {
                            spacing: 20
                            leftPadding: 50

                            Label {
                                text: model.name
                                width: statisticsTable.width / 3
                            }

                            Label {
                                text: model.spikes
                                width: statisticsTable.width / 3
                            }
                        }
                    }
                }
                ScrollIndicator.vertical: ScrollIndicator {
                    parent: statisticsTable.contentItem
                    anchors.top: flickable.top
                    anchors.bottom: flickable.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: -statisticsTable.rightPadding + 1
                }
            }
        }
    }

    Flickable {
        id: flickPart
        Layout.minimumWidth: 1/4 * window.width
        Layout.maximumWidth: 1/4 * window.width
        contentHeight: column.height
        contentWidth: 1/4 * window.width
        boundsBehavior: Flickable.OvershootBounds

        Rectangle {
            width: 1/4 * window.width
            height: Math.max(column.height, electrodePlacement.height)
            color: "white"

            Column {
                id: column
                spacing: 15
                padding: 20

                Button {
                    id: statisticsButton
                    text: qsTr("Show spikes statistics")
                }

                Item {
                    id: gradientItem
                    height: 20
                    width: 250
                    Rectangle {
                        id: gradientParent
                        width: 20
                        height: 250
                        x: 115
                        y: -110
                        clip: true
                        rotation: -90
                        signal colorGradientChanged()
                        onColorGradientChanged: showStatistics(true)

                        gradient: Gradient {
                            id: gradient
                            GradientStop { position: 0.1 }
                            GradientStop { position: 0.3 }
                            GradientStop { position: 0.5 }
                            GradientStop { position: 0.7 }
                            GradientStop { position: 0.9 }
                        }

                        MouseArea  {
                            id: gradientMouse
                            anchors.fill: parent

                            ColorGradientSettingDialog {
                                id: colorDialog
                                visible: false
                            }
                        }
                    }
                }

                Row{
                    id: gradientLabels
                    width: 260
                    spacing: 10

                    Repeater {
                        model: [customMinSpikes,
                            0.25*(customMaxSpikes - customMinSpikes) + customMinSpikes,
                            0.5 * (customMaxSpikes - customMinSpikes) + customMinSpikes,
                            0.75 * (customMaxSpikes - customMinSpikes) + customMinSpikes,
                            customMaxSpikes]
                        Label {
                            text: Math.round(modelData)
                            width: 44
                            fontSizeMode: Text.Fit
                            horizontalAlignment:index === 0 ? Text.AlignLeft: index === 4 ? Text.AlignRight : Text.AlignHCenter
                            minimumPixelSize: 10
                            font.pixelSize: 20
                        }
                    }


                }

                Switch {
                    id: zoomSwitch
                    text: qsTr("Enable zoom")
                    checked: false
                }

                Switch {
                    id: fixButton
                    text: qsTr("Fix electrodes")
                    checked: false
                }

                Button {
                    id: statisticsTableButton
                    text: qsTr("Show statistics table")
                }

                ComboBox {
                    id: comboBox
                    model: [qsTr("indexes"), qsTr("track names"), qsTr("indexes + tracks")]
                    currentIndex: 2
                    displayText: qsTr("Display: ") + currentText
                }

                Repeater {
                    id: electrodeRep

                    model: electrodes
                    delegate: Row {
                        id: elRow
                        property alias elec: elecItem
                        padding: 5
                        spacing: 5

                        function addNewElectrode() {
                            var component = Qt.createComponent("qrc:/pages/Electrode.qml")
                            var sameElec = component.createObject(elecItem, {"columnCount": columns, "rowCount": rows, "linkList": links,
                                                                      "color": elecItem.children[elecItem.children.length-1].basicE.color,
                                                                      "yPosition": elecItem.getYCoordinate(index)});
                            console.log("Copy of electrode " + rows + "x" + columns + " added.")

                        }

                        Label {
                            text: rows + "x" + columns
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        RoundButton {
                            id: plusButton
                            text: "+"
                            height: 40
                            font.pixelSize: 40
                            highlighted: true
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: addNewElectrode()
                        }

                        Item {
                            id:elecItem
                            height: electrode.height
                            width: electrode.width
                            property string color: "white"
                            onColorChanged: {
                                for (var i = 0; i < children.length; i++) {
                                    children[i].color = color
                                }
                            }

                            function getYCoordinate(index) {
                                var temp = comboBox.y + comboBox.height + column.spacing + column.padding
                                if (index === 0) {
                                    return temp
                                }
                                for(var i = 1; i <= index; i++) {
                                    temp = temp + electrodeRep.itemAt(i-1).height + column.spacing
                                }
                                return temp
                            }

                            Electrode {
                                id: electrode
                                columnCount: columns
                                rowCount: rows
                                linkList: links
                                repeaterIndex: index
                                yPosition: elecItem.getYCoordinate(index)
                                basicE.parent: eParent === "imageArea" ? imageArea : root
                                basicE.x: eX
                                basicE.y: eY
                                basicE.z: eZ
                                basicE.rotation: eRotation
                                basicE.scale: eScale

                                basicE.onParentChanged: electrodes.setProperty(index, "eParent", basicE.parent === imageArea ? "imageArea" : "root")
                                basicE.onXChanged: electrodes.setProperty(index, "eX", basicE.x)
                                basicE.onYChanged: electrodes.setProperty(index, "eY", basicE.y)
                                basicE.onZChanged: electrodes.setProperty(index, "eZ", basicE.z)
                                basicE.onRotationChanged: electrodes.setProperty(index, "eRotation", basicE.rotation)
                                basicE.onScaleChanged:  electrodes.setProperty(index, "eScale", basicE.scale)
                            }
                        }
                    }
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator { id: scrollIndicator }
    }
}
