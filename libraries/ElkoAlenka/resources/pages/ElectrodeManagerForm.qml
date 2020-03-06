import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import "../+universal"

Page {
    id: item
    property string name: qsTr("Electrode Manager")
    property alias addButton: addButton
    property alias stripRepeater: stripRep
    property alias gridRepeater: gridRep
    property alias stripModel: stripModel
    property alias gridModel: gridModel
    property alias tabBar: bar
    property alias infoPopup: infoPopup
    property alias addDialog: addDialog

    header: TabBar {
        id: bar
        width: parent.width
        TabButton { text: qsTr("Strips") }
        TabButton { text: qsTr("Grids") }
    }

    StackLayout {
        id: stack
        width: parent.width
        height: parent.height
        y: header.height
        currentIndex: bar.currentIndex
        Flickable {
            contentHeight: stripColumn.height + 150
            contentWidth: stripColumn.width + 150
            boundsBehavior: Flickable.OvershootBounds

            Column {
                id: stripColumn
                spacing: 30
                padding: 20

                ListModel {
                    id: stripModel
                    ListElement { columns: 4 }
                    ListElement { columns: 5 }
                    ListElement { columns: 6 }
                    ListElement { columns: 7 }
                    ListElement { columns: 8 }
                    ListElement { columns: 9 }
                    ListElement { columns: 10 }
                }

                Repeater {
                    id: stripRep
                    model: stripModel
                    delegate: Row {
                        spacing: 20
                        property alias count: stripSpin.value
                        property alias stripColumns: strip.columnCount
                        SpinBox {
                            id: stripSpin
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Label {
                            text: strip.rowCount + "x" + strip.columnCount
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        BasicElectrode {
                            id: strip
                            columnCount: model.columns
                            rowCount: 1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
            ScrollIndicator.horizontal: ScrollIndicator { bottomPadding: 49}
        }

        Flickable {
            contentHeight: gridColumn.height + 150
            contentWidth: gridColumn.width + 150
            boundsBehavior: Flickable.OvershootBounds

            Column {
                id: gridColumn
                spacing: 30
                padding: 20

                ListModel {
                    id: gridModel
                    ListElement { columns: 4; rows: 4 }
                    ListElement { columns: 5; rows: 5 }
                    ListElement { columns: 6; rows: 5 }
                    ListElement { columns: 7; rows: 3 }
                    ListElement { columns: 8; rows: 5 }
                    ListElement { columns: 9; rows: 2 }
                    ListElement { columns: 10; rows: 3 }
                }

                Repeater {
                    id: gridRep
                    model: gridModel
                    delegate: Row {
                        spacing: 20
                        property alias count: gridSpin.value
                        property alias gridRows: grid.rowCount
                        property alias gridColumns: grid.columnCount
                        SpinBox {
                            id: gridSpin
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Label {
                            text: grid.rowCount + "x" + grid.columnCount
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        BasicElectrode {
                            id: grid
                            columnCount: model.columns
                            rowCount: model.rows
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
            ScrollIndicator.horizontal: ScrollIndicator { bottomPadding: 49 }
        }
    }

    Button {
        id: addButton
        text: qsTr("Add new electrode")
        anchors {top: parent.top; right: parent.right; margins: 50 }
        highlighted: true
        height: 60
    }

    Dialog {
        id: infoPopup
        modal: true
        focus: true
        x: (window.width - width) / 2
        y: (window.height - height) / 6
        title: qsTr("<b>Information</b>")
        standardButtons: Dialog.Ok

        Label {
            text: qsTr("You didn't choose any electrode.")
        }
    }

    ElectrodeAddingDialog {
        id: addDialog
    }
}
