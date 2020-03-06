import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls 2.1
import "../+universal"

Controls.SplitView {
    id: electrodeSignalLink

    property string name: qsTr("Link Signal with Electrode")
    property ListModel electrodes: ListModel {} //only rows and columns
    property int maxSpikes: 0
    property int minSpikes: 0
    property bool refreshNeeded: false
    property bool refreshLoadedNeeded: false
    readonly property bool isActive: window.listView.currentIndex == 2

    property alias elecRep: elecRep
    property alias dragRep: dragRep

    Flickable {
        contentHeight:source.height + 150
        contentWidth: 1.5 * source.width
        Layout.minimumWidth: 1.5 * source.width
        Layout.maximumWidth: 1.5 * source.width
        boundsBehavior: Flickable.StopAtBounds
        z: 2

        Rectangle {
            color: "white"
            anchors.fill: parent

            Column {
                id: source
                width: 130
                spacing: 30
                padding: 30
                leftPadding: 60
                Repeater {
                    id: dragRep
                    model: window.xmlModels.trackModel
                    DragTrack {
                        trackName: label.replace(/\s+/g, '') //without whitespaces
                        trackId: index
                    }
                }
            }
        }
        ScrollIndicator.vertical: ScrollIndicator { }
    }

    Flickable {
        contentHeight: destination.height + 300
        contentWidth: destination.width + 150
        width: 4/5 * parent.width
        Layout.minimumWidth: 2/3 * parent.width
        boundsBehavior: Flickable.OvershootBounds

        Column {
            id: destination
            spacing: 30
            padding: 30

            Repeater {
                id: elecRep
                model: electrodes
                delegate: Row {
                    property alias bElectrode: bElectrode
                    spacing: 20
                    Label {
                        text: rows + "x" + columns
                        font.pixelSize: 40
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    BasicElectrode {
                        id: bElectrode
                        size: 80
                        columnCount: columns
                        rowCount: rows
                        droppingEnabled: true
                    }
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator { }
        ScrollIndicator.horizontal: ScrollIndicator { }
    }

}

