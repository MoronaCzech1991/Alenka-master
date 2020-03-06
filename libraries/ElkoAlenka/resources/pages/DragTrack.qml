import QtQuick 2.7
import QtQuick.Controls.Universal 2.1

DragTrackForm {

    mouseArea.onReleased: {
        // check if dropped at target, if not reset to root
        mouseArea.parent = (tile.Drag.target === null || tile.Drag.target.alreadyContainsDrag) ?  root : tile.Drag.target

        if (mouseArea.parent !== root && mouseArea.parent != null) {
            // set parents properties when contains drag
            mouseArea.parent.alreadyContainsDrag = true
            mouseArea.parent.name = trackName
            mouseArea.parent.trackName = trackName
            mouseArea.parent.trackId = trackId
            mouseArea.parent.spikes = spikes
            tile.color = Universal.color(Universal.Cyan)
        }
    }

    mouseArea.onPressed: {
        if (mouseArea.parent !== root) {
            // when drag, set to default state
            mouseArea.parent.alreadyContainsDrag = false
            mouseArea.parent.name = mouseArea.parent.defaultName
            mouseArea.parent.trackName = ""
            mouseArea.parent.trackId = -1
            mouseArea.parent.spikes = 0
            tile.color = "white"
        }
    }

    mouseArea.onParentChanged: {
        if (mouseArea.parent !== root && mouseArea.parent != null) {
            // set parents properties when contains drag
            mouseArea.parent.alreadyContainsDrag = true
            mouseArea.parent.name = trackName
            mouseArea.parent.trackName = trackName
            mouseArea.parent.trackId = trackId
            mouseArea.parent.spikes = spikes
            tile.color = Universal.color(Universal.Cyan)
        }
    }

    function resetPosition() {
        mouseArea.parent = root
        tile.color = "white"
    }

    function connectSignal(electrodeNum, rowNum, columnNum) {
        mouseArea.parent = electrodeSignalLinkMain.elecRep.itemAt(electrodeNum).bElectrode.rowRep.itemAt(rowNum).colRep.itemAt(columnNum)
    }

    tile.states: State {
        when: mouseArea.drag.active
        ParentChange {
            target: tile
            parent: root
        }
        AnchorChanges {
            //for moving with mouse
            target: tile
            anchors.verticalCenter: undefined
            anchors.horizontalCenter: undefined
        }
    }

    onSpikesChanged: {
        if (mouseArea.parent !== root) {
            mouseArea.parent.spikes = spikes
        }
    }
}
