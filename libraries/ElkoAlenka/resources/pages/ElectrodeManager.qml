import QtQuick 2.7
import QtQuick.Controls 2.1

ElectrodeManagerForm {

    addButton.onClicked: {
        addDialog.open()
    }

    ListModel { id: chosenElectrodesList } //ListElement { columns: 0; rows: 0 }

    function confirm() {
        getChosenElectrodes()   //fill chosenElectrodesList
        if (chosenElectrodesList.count === 0) {
            infoPopup.open()
            console.log("User did not choose any electrode.")

        } else {
            for (var k = 0; k < signalLinkMain.electrodes.count; k++) {


                var elementIndex = find(signalLinkMain.electrodes.get(k), chosenElectrodesList)

                if ( elementIndex !== -1) {

                    //element is already in signalLinkMain.electrodes
                    chosenElectrodesList.remove(elementIndex)

                } else {

                    //remove unchecked electrodes
                    for (var r = 0; r < signalLinkMain.electrodes.get(k).rows; r++) {
                        for (var c = 0; c < signalLinkMain.electrodes.get(k).columns; c++) {
                            if (signalLinkMain.elecRep.itemAt(k).bElectrode.rowRep.itemAt(r).colRep.itemAt(c).trackId !== -1)
                                signalLinkMain.disconnectSignal(signalLinkMain.elecRep.itemAt(k).bElectrode.rowRep.itemAt(r).colRep.itemAt(c).trackId)
                        }
                    }
                    signalLinkMain.electrodes.remove(k)
                    electrodePlacementMain.electrodes.remove(k)
                    k--
                }
            }

            //append newly chosen electrodes
            for (var l = 0; l < chosenElectrodesList.count; l++) {
                signalLinkMain.electrodes.append(chosenElectrodesList.get(l))
                electrodePlacementMain.electrodes.append({ rows: chosenElectrodesList.get(l).rows, columns: chosenElectrodesList.get(l).columns,
                                                             links: emptyListModel, eParent: "root", eX: 0, eY:0, eZ: 0, eScale: 1, eRotation: 0})
            }

            changePage(2, signalLinkMain)
        }
    }

    // empty list model for links
    ListModel { id: emptyListModel }

    function find( element, model ) {
        for(var i = 0; i < model.count; ++i) {
            if (model.get(i).rows === element.rows && model.get(i).columns === element.columns) {
                return i
            }
        }
        return -1
    }

    function reset() {
        // reset strips choice
        for (var i = 0; i < stripRepeater.count; i++) {
            stripRepeater.itemAt(i).count = 0
        }
        //reset grids choice
        for (var j = 0; j < gridRepeater.count; j++) {
            gridRepeater.itemAt(j).count = 0
        }
        console.log("Choice of electrodes has been reset.")
    }

    function getChosenElectrodes() {
        console.log("User chose following electrodes: ")
        chosenElectrodesList.clear()

        // get strips
        for (var i = 0; i < stripRepeater.count; i++) {
            if (stripRepeater.itemAt(i).count !== 0) {
                for (var k = 0; k < stripRepeater.itemAt(i).count; k++) {
                    chosenElectrodesList.append({ columns: stripRepeater.itemAt(i).stripColumns, rows: 1 })
                }
                console.log(stripRepeater.itemAt(i).count + "x strip 1x" + stripRepeater.itemAt(i).stripColumns)
            }
        }

        // get grids
        for (var j = 0; j < gridRepeater.count; j++) {
            if (gridRepeater.itemAt(j).count !== 0) {
                for (var l = 0; l < gridRepeater.itemAt(j).count; l++) {
                    chosenElectrodesList.append({ columns: gridRepeater.itemAt(j).gridColumns, rows: gridRepeater.itemAt(j).gridRows })
                }
                console.log(gridRepeater.itemAt(j).count + "x grid " + gridRepeater.itemAt(j).gridRows + "x" + gridRepeater.itemAt(j).gridColumns)
            }
        }

        return chosenElectrodesList
    }

    function setLoadedElectrode(rowCount, columnCount) {

        if (rowCount === 1) {
            for (var i = 0; i < stripRepeater.count; i++) {
                if (stripRepeater.itemAt(i).stripColumns === columnCount) {
                    stripRepeater.itemAt(i).count++
                    return
                }
            }
            stripModel.append({rows: rowCount, columns: columnCount})
            stripRepeater.itemAt(stripRepeater.count-1).count++

        } else {
            for (var k = 0; k < gridRepeater.count; k++) {
                if (gridRepeater.itemAt(k).gridColumns === columnCount) {
                    if (gridRepeater.itemAt(k).gridRows === rowCount) {
                        gridRepeater.itemAt(k).count++
                        return
                    }
                }
            }
            gridModel.append({rows: rowCount, columns: columnCount})
            gridRepeater.itemAt(gridRepeater.count-1).count++
        }
    }
}


