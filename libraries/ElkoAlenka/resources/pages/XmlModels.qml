import QtQuick 2.7
import QtQuick.XmlListModel 2.0

Item {
    id: xmlModels

    property alias trackModel: trackModel
    property alias eventModel: eventModel
    property string sourcePath

    XmlListModel {
        id: trackModel
        source: sourcePath
        query: "/document/montageTable/montage/trackTable/track"

        XmlRole { name: "label"; query: "@label/string()" }
    }

    XmlListModel {
        id: eventModel
        source: sourcePath
        query: "/document/montageTable/montage/eventTable/event"

        XmlRole { name: "channel"; query: "@channel/string()" }
    }

    function countSpikes() {
        // set min, max to electrode placement
        // set spikes to linked tracks
        var spikes = 0
        var min = 0
        var max = 0

        for (var i = 0; i < trackModel.count; i++) {
            spikes = 0
            signalLinkMain.dragRep.itemAt(i).spikes = 0

            // count spikes
            for (var j = 0; j < eventModel.count; j++) {
                if (i == eventModel.get(j).channel) {
                    spikes++
                }
            }

            // minimum and maximum
            if (spikes > max){
                max = spikes
            } else if (spikes <= min) {
                min = spikes
            }

            signalLinkMain.dragRep.itemAt(i).spikes = spikes
//            console.log(xmlModels.trackModel.get(i).label.replace(/\s+/g, '') + " (" + i + ") has " + spikes + " spike(s).")
        }
        electrodePlacementMain.minSpikes = min
        electrodePlacementMain.maxSpikes = max
    }
}
