import QtQuick 2.7

ElectrodeAddingDialogForm {

    addDialog.onAccepted: {
        // add dialog to electrode manager
        addElectrode(columnSpinBox.value, rowSpinBox.value)
        addDialog.close()
        setDefaultValues()
    }

    addDialog.onRejected: {
        addDialog.close()
        setDefaultValues()
    }

    function addElectrode(columnCount, rowCount) {

        //for strips rows = 1
        if (columnCount === 1 && rowCount !== 1) {
            columnCount = rowCount
            rowCount = 1
        }
        if (rowCount === 1) {
            //create strip
            stripModel.append({ columns: columnCount })
            tabBar.currentIndex = 0
        } else {
            //create grid
            gridModel.append({ columns: columnCount, rows: rowCount })
            tabBar.currentIndex = 1
        }
        console.log("New electrode " + rowCount + "x" + columnCount + " was added.")
    }

    function setDefaultValues() {
        columnSpinBox.value = 5
        rowSpinBox.value = 1
    }
}
