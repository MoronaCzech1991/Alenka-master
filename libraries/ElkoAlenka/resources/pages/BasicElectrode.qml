import QtQuick 2.7
import QtQuick.Controls 2.1

Item {
    id: root
    property int columnCount
    property int rowCount
    property int size: 40
    property bool droppingEnabled: false
    property string color: "white"
    property ListModel linkedTracks: ListModel { }  //ListElement {electrodeNumber: defaultName, wave: name, spikes: 0})

    property alias rowRep: rowRep

    width: columnCount*size; height: rowCount*size;

    function deleteLinkedTracks() {

        // clear linked tracks from electrode
        if (linkedTracks != null) linkedTracks.clear()

        for (var i = 0; i < rowCount; i++) {
            for (var j = 0; j < columnCount; j++) {
                if (rowRep.itemAt(i).colRep.itemAt(j).trackName !== "") {
                    var currContact = rowRep.itemAt(i).colRep.itemAt(j)
                    currContact.name = currContact.defaultName
                    currContact.nameFont.bold = false
                    currContact.trackName = ""
                    currContact.alreadyContainsDrag = false
                    currContact.trackId = -1
                    currContact.spikes = 0
                }
            }
        }
    }

    // return column and row index of electrode with electrodeNumber
    function getPositionIndexes(electrodeNumber) {
        var rowNum = rowCount - Math.floor(electrodeNumber / columnCount)
        var columnNum = electrodeNumber % columnCount
        if (columnNum === 0) {
            columnNum = columnCount
        } else if (rowNum !== 0){
            rowNum = rowNum - 1
        }

        return [rowNum, columnNum - 1]
    }

    function setLinkedTracks() {
        for (var i = 0; i < rowCount; i++) {
            for (var j = 0; j < columnCount; j++) {
                rowRep.itemAt(i).colRep.itemAt(j).setLinkedTrack()
            }
        }
    }

    Rectangle {
        id: electrode
        width: columnCount*size; height: rowCount*size; radius: size/2
        opacity: 0.8
        border.color: "grey"

        Column {
            id: column

            Repeater {
                id: rowRep
                model: rowCount

                Row {
                    id: row
                    property alias colRep: columnRep

                    Repeater {
                        id: columnRep
                        model: columnCount

                        DropArea {
                            id: dropArea
                            readonly property int defaultName: columnCount * ( rowCount - row.getIndex() ) + ( modelData + 1 )
                            property int columnCount: root.columnCount  //for console logs (signal link)
                            property int rowCount: root.rowCount        //for console logs (signal link)
                            property int columnIndex: index
                            property int rowIndex: row.getIndex() - 1
                            property string trackName: ""
                            property bool alreadyContainsDrag: false
                            property int trackId: -1
                            property bool nameToChange: true
                            property int spikes: 0

                            property alias name: electrodeText.text
                            property alias nameFont: electrodeText.font
                            property alias colorFill: dropRectangle.color


                            width: size; height: size
                            enabled: droppingEnabled

                            Rectangle {
                                id: dropRectangle
                                opacity: 0.8
                                width: size; height: size; radius: size/2
                                border.color: "grey"
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter

                                states: [
                                    State {
                                        when: dropArea.containsDrag && dropArea.alreadyContainsDrag === false
                                        PropertyChanges {
                                            target: dropRectangle
                                            color: "green"
                                        }
                                    },
                                    State {
                                        when: dropArea.containsDrag && dropArea.alreadyContainsDrag === true
                                        PropertyChanges {
                                            target: dropRectangle
                                            color: "red"
                                        }
                                    }
                                ]
                                Text {
                                    id: electrodeText
                                    text: dropArea.defaultName
                                    font.pixelSize: root.size / 2
                                    minimumPixelSize: 10
                                    anchors.fill: parent
                                    horizontalAlignment:Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    fontSizeMode: Text.Fit
                                }
                            }

                            onTrackNameChanged: {
                                if (nameToChange) {
                                    if (trackName === "") {
                                        for (var i = 0; i < linkedTracks.count; i++) {
                                            if (linkedTracks.get(i).electrodeNumber === defaultName) {
                                                linkedTracks.remove(i)
                                                break
                                            }
                                        }
                                    } else {
                                        linkedTracks.append( { electrodeNumber: defaultName, wave: name, spikes: spikes} )
                                    }
                                }
                            }

                            onSpikesChanged: {
                                for (var i = 0; i < linkedTracks.count; i++) {
                                    if (linkedTracks.get(i).electrodeNumber === defaultName) {
                                        linkedTracks.get(i).spikes = spikes
                                    }
                                }
                            }

                            Component.onCompleted: setLinkedTrack()

                            function setLinkedTrack() {
                                //set to default state
                                nameToChange = false
                                name = defaultName
                                trackName = ""
//                                spikes = 0
                                electrodeText.font.bold = false
                                colorFill = "white"

                                //link tracks
                                if (linkedTracks != null) {
                                    for (var i = 0; i < linkedTracks.count; i++) {
                                        if (linkedTracks.get(i).electrodeNumber === defaultName) {
                                            name = linkedTracks.get(i).wave
                                            trackName = linkedTracks.get(i).wave
                                            spikes = linkedTracks.get(i).spikes
                                            electrodeText.font.bold = true
                                        }
                                    }
                                }
                                nameToChange = true
                            }

                            function setDefault() {
                                name = defaultName
                                trackName = ""
                                alreadyContainsDrag = false
                                spikes = 0
                                electrodeText.font.bold = false
                                colorFill = "white"
                            }
                        }
                    }
                    Rectangle {
                        id: tail
                        opacity: 0.8
                        width: size + 5; height: size / 3; radius: size / 6
                        y: size / 2 - height / 2
                        border.color: "grey"
                        color: root.color
                    }

                    function getIndex() {   //for default electrode name
                        return index + 1
                    }
                }
            }
        }
    }
}

