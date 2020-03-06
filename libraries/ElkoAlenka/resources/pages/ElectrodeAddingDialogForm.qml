import QtQuick 2.7
import QtQuick.Controls 2.1
import "../+universal"

Dialog {
    property alias addDialog: addDialog
    property alias rowSpinBox: rowSpinBox
    property alias columnSpinBox: columnSpinBox

    id: addDialog
    modal: true
    focus: true
    x: (window.width - width) / 2
    y: (window.height - height)/6
    title: qsTr("<b>Add new strip/grid</b>")
    standardButtons: Dialog.Ok | Dialog.Cancel

    Grid {
        id: dialogGrid
        columns: 2
        spacing: 20
        verticalItemAlignment: Grid.AlignVCenter

        Label {
            text: qsTr("Rows")
            font.pixelSize: 30
        }

        SpinBox {
            id: rowSpinBox
            from: 1
            value: 1
            width: 240
            height: 60
            up.indicator.width: 90
            down.indicator.width: 90
        }

        Label {
            text: qsTr("Columns")
            font.pixelSize: 30
        }

        SpinBox {
            id: columnSpinBox
            from: 1
            value: 5
            width: 240
            height: 60
            up.indicator.width: 90
            down.indicator.width: 90
        }
    }
}
