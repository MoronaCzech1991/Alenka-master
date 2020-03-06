import QtQuick 2.7
import QtQuick.Controls 2.1


ElectrodeSignalLinkForm {

    ListModel { id: linkedElectrodesList } //ListElement { rows: rowCount, columns: columnCount, links: links}

    function confirm() {

        //        readXml()

        // set linked tracks
        for (var i = 0; i < electrodePlacementMain.electrodeRep.count; i++) {
            for (var k = 0; k < electrodePlacementMain.electrodeRep.itemAt(i).elec.children.length; k++) {
                electrodePlacementMain.electrodes.get(i).links = elecRep.itemAt(i).bElectrode.linkedTracks
                electrodePlacementMain.electrodeRep.itemAt(i).elec.children[k].linkList = elecRep.itemAt(i).bElectrode.linkedTracks
                electrodePlacementMain.electrodeRep.itemAt(i).elec.children[k].basicE.setLinkedTracks()
            }
        }

        //        electrodePlacementMain.minSpikes = minSpikes
        //        electrodePlacementMain.maxSpikes = maxSpikes
        changePage(3, window.electrodePlacementMain)
    }

    function reset() {

        //reset link between electrodes and drag items
        for (var i = 0; i < dragRep.count; i++) {

            if(dragRep.itemAt(i).mouseArea.parent !== dragRep.itemAt(i).root) {

                dragRep.itemAt(i).mouseArea.parent.alreadyContainsDrag = false
                dragRep.itemAt(i).mouseArea.parent.name = dragRep.itemAt(i).mouseArea.parent.defaultName
                dragRep.itemAt(i).mouseArea.parent.trackName = ""
                dragRep.itemAt(i).mouseArea.parent.trackId = -1
                dragRep.itemAt(i).mouseArea.parent.spikes = 0
                dragRep.itemAt(i).tile.color = "white"
                dragRep.itemAt(i).mouseArea.parent = dragRep.itemAt(i).root
            }
            dragRep.itemAt(i).mouseArea.x = 0
            dragRep.itemAt(i).mouseArea.y = 0
        }
    }

    function disconnectSignal(signalId) {
        dragRep.itemAt(signalId).resetPosition()
    }

    function connectSignals() {
        for (var m = 0; m < elecRep.count; m++) {
            var currElec = elecRep.itemAt(m).bElectrode

            for (var l = 0; l < currElec.linkedTracks.count; l++) {
                var trackIndex = getTrackIndex(currElec.linkedTracks.get(l).wave)

                if (trackIndex >=0 ) {
                    dragRep.itemAt(trackIndex).mouseArea.parent
                            = currElec.rowRep.itemAt(currElec.getPositionIndexes(currElec.linkedTracks.get(l).electrodeNumber)[0])
                    .colRep.itemAt(currElec.getPositionIndexes(currElec.linkedTracks.get(l).electrodeNumber)[1])

                } else {
                    currElec.rowRep.itemAt(currElec.getPositionIndexes(currElec.linkedTracks.get(l).electrodeNumber)[0])
                    .colRep.itemAt(currElec.getPositionIndexes(currElec.linkedTracks.get(l).electrodeNumber)[1]).setDefault()
                    l--
                }
            }
        }
    }

    function refreshLoadedTrack() {
        // link signals in signalLinkMain
        for (var l = 0; l < electrodePlacementMain.electrodeRep.count; l++) {
            var currElecInRep = electrodePlacementMain.electrodeRep.itemAt(l).elec.children[0].basicE
            for (var b = 0; b < currElecInRep.rowCount; b++) {

                for (var c = 0; c < currElecInRep.columnCount; c++) {

                    if (currElecInRep.rowRep.itemAt(b).colRep.itemAt(c).trackName !== "") {
                        for (var d = 0; d < dragRep.count; d++) {
                            if (dragRep.itemAt(d).trackName === currElecInRep.rowRep.itemAt(b).colRep.itemAt(c).trackName) {
                                dragRep.itemAt(d).connectSignal(l, b, c)
                            }
                        }
                    }
                }
            }
        }
    }

    function getTrackIndex(waveName) {
        for (var i = 0; i < dragRep.count; i++) {
            if (dragRep.itemAt(i).trackName === waveName) {
                return i
            }
        }
        return -1
    }

    onIsActiveChanged: {
        if (refreshNeeded && isActive) {
            // refresh linked tracks
            refreshNeeded = false
            waitTimer.start()
        }
        if (refreshLoadedNeeded && isActive) {
            // refresh loaded linked tracks
            refreshLoadedNeeded = false
            waitLoadingTimer.start()
        }
    }

    onRefreshNeededChanged: {
        if (refreshNeeded && isActive) {
            // refresh linked tracks
            refreshNeeded = false
            waitTimer.start()
        }
    }

    onRefreshLoadedNeededChanged: {
        if (refreshLoadedNeeded && isActive) {
            // refresh loaded linked tracks
            refreshLoadedNeeded = false
            waitLoadingTimer.start()
        }
    }

    Timer {
        id: waitTimer
        interval: 50
        onTriggered: {
            xmlModels.countSpikes()
            connectSignals()
        }
    }

    Timer {
        id: waitLoadingTimer
        interval: 50
        onTriggered: {
            xmlModels.countSpikes()
            refreshLoadedTrack()
        }
    }
}
