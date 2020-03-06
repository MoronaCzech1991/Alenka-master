import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.2 as Dialogs
import QtQuick.Controls.Universal 2.1
import "./pages" as Pages
import "./+universal"

Page {
    id: window
    width: 1600
    height: 800

    visible: true
    title: "Elko"

    Universal.theme: Universal.Light
    Universal.accent: Universal.Cyan

    signal switchToAlenka()
    signal exit()
    signal saveSession(string session)
    signal exportDialog()

    property bool sessionLoaded: false
    property string file: filePath
    property string previousFile: ""
    property ListModel sameElecData: ListModel{}    //electrodeId, parent, x, y, z, scale, rotation

    property alias confirmButton: confirmButton
    property alias resetButton: resetButton
    property alias xmlModels: xmlModels
    property alias listView: listView
    property alias imageManagerMain: imageManagerMain
    property alias electrodeManagerMain: electrodeManagerMain
    property alias signalLinkMain: electrodeSignalLinkMain
    property alias electrodePlacementMain: electrodePlacementMain

    onFileChanged: {

        if (previousFile === "" && sessionLoaded === false) signalLinkMain.refreshNeeded = true

        if (file.substring(0, file.length - 1) === previousFile) { // file is same (just different index at the end)

            xmlModels.sourcePath = file
            electrodeSignalLinkMain.dragRep.model = xmlModels.trackModel
            signalLinkMain.refreshNeeded = true

        } else { //totally different file

            xmlModels.sourcePath = file
            electrodeSignalLinkMain.dragRep.model = xmlModels.trackModel

            if (!sessionLoaded) {
                //  delete linked tracks in Signal Link
                for (var i = 0; i < signalLinkMain.elecRep.count; i++) {
                    signalLinkMain.elecRep.itemAt(i).bElectrode.deleteLinkedTracks()
                }

                //  delete linked tracks in Electrode Placement
                for (var j = 0; j < electrodePlacementMain.electrodeRep.count; j++) {
                    for (var k = 0; k < electrodePlacementMain.electrodeRep.itemAt(j).elec.children.length; k++) { //for all electrodes (even same)
                        electrodePlacementMain.electrodeRep.itemAt(j).elec.children[k].basicE.deleteLinkedTracks()
                    }
                }
            } else {
                electrodeSignalLinkMain.refreshLoadedNeeded = true
            }
        }
        if (!sessionLoaded && previousFile!== "") changePage(1, electrodeManagerMain)

        previousFile = file.substring(0, file.length - 1)
        sessionLoaded = false
    }

    function changePage(pageIndex, page) {
        listView.currentIndex = pageIndex
        titleLabel.text = page.name
        stackView.replace(page)
        page.enabled = true
        page.visible = true
        listView.currentIndex = pageIndex
    }

    function loadSession(session) {

        sessionLoaded = true

        imageManagerMain.reset()
        electrodeManagerMain.reset()
        electrodeSignalLinkMain.electrodes.clear()
        electrodePlacementMain.electrodes.clear()

        var JsonObjectArray = JSON.parse(session)

        // load images
        var images = JsonObjectArray.images
        electrodePlacementMain.images = images

        // check images in image manager
        for (var a = 0; a < images.length; a++) {
            imageManagerMain.checkImage(images[a])
        }

        // mins a max in electrode placement
        var minMax = JsonObjectArray.minMax
        electrodePlacementMain.minSpikes = minMax[0]
        electrodePlacementMain.maxSpikes = minMax[1]
        electrodePlacementMain.customMinSpikes = minMax[2]
        electrodePlacementMain.customMaxSpikes = minMax[3]

        var electrodeData = JsonObjectArray.electrodeData

        for (var i = 0; i < electrodeData.length; i++) {
            loadedLinks.clear()
            var currElec = electrodeData[i]

            // set electrodes in Electrode Manager
            electrodeManagerMain.setLoadedElectrode(currElec.rows, currElec.columns);

            // set electrodes in Electrode Signal Link
            electrodeSignalLinkMain.electrodes.append({rows: currElec.rows, columns: currElec.columns})

            for (var n = 0; n < currElec.links.length; n++) {
                loadedLinks.append(currElec.links[n])
            }

            // set electrodes in Electrode Placement
            electrodePlacementMain.electrodes.append({rows: currElec.rows,
                                                         columns: currElec.columns,
                                                         links: loadedLinks,
                                                         eParent: currElec.eParent,
                                                         eX: currElec.eX, eY:currElec.eY, eZ: currElec.eZ,
                                                         eScale: currElec.eScale, eRotation: currElec.eRotation})
        }

        var sameElectrodeData = JsonObjectArray.sameElectrodeData
        for (var l = 0; l < electrodePlacementMain.electrodeRep.count; l++) {

            // add same electrodes (copies) in electrode placement
            for (var m = 0; m < sameElectrodeData.length; m++) {
                var childNum = 1

                if (sameElectrodeData[m].electrodeId === l) {
                    electrodePlacementMain.electrodeRep.itemAt(l).addNewElectrode()
                    var newElec = electrodePlacementMain.electrodeRep.itemAt(l).elec.children[childNum].basicE
                    newElec.parent =
                            sameElectrodeData[m].eParent === "imageArea"
                            ? electrodePlacementMain.imageArea
                            : electrodePlacementMain.electrodeRep.itemAt(l).elec.children[childNum].root
                    newElec.x =  sameElectrodeData[m].eX
                    newElec.y =  sameElectrodeData[m].eY
                    newElec.z =  sameElectrodeData[m].eZ
                    newElec.rotation = sameElectrodeData[m].eRotation
                    newElec.scale = sameElectrodeData[m].eScale

                    childNum++
                }
            }
        }
    }

    ListModel { id: loadedLinks }

    function setImagesForSave() {
        var images = []
        for (var i = 0; i < electrodePlacementMain.images.length; i++) {
            images[i] = electrodePlacementMain.images[i].toString()
        }
        return images
    }

    function setElectrodeDataForSave() {
        var electrodesData = []
        for (var i = 0; i < electrodePlacementMain.electrodes.count; i++) {
            var currElec = electrodePlacementMain.electrodes.get(i)

            // get links of electrode to array
            var linkList = []
            for (var m = 0; m < currElec.links.count; m++) {
                linkList[m] = ({electrodeNumber: currElec.links.get(m).electrodeNumber,
                                   wave: currElec.links.get(m).wave,
                                   spikes: currElec.links.get(m).spikes
                               })
            }

            electrodesData[i] = ({rows: currElec.rows,
                                     columns: currElec.columns,
                                     links: linkList,
                                     eParent: currElec.eParent,
                                     eX: currElec.eX, eY:currElec.eY, eZ: currElec.eZ,
                                     eScale: currElec.eScale, eRotation: currElec.eRotation})
        }
        return electrodesData
    }

    function setSameElectrodeDataForSave() {
        // same electrodes added later in electrodePlacementMain (copies)
        var identicElectrodesData = []
        sameElecData.clear()

        for (var j = 0; j < electrodePlacementMain.electrodeRep.count; j++) {
            for (var k = 1; k < electrodePlacementMain.electrodeRep.itemAt(j).elec.children.length; k++) { //without the first one (already in electrodesData)
                var currElec = electrodePlacementMain.electrodeRep.itemAt(j).elec.children[k]
                sameElecData.append({"electrodeId": j,
                                        "eParent": (currElec.basicE.parent === electrodePlacementMain.imageArea ? "imageArea" : "root"),
                                        "eX": currElec.basicE.x,
                                        "eY": currElec.basicE.y,
                                        "eZ": currElec.basicE.z,
                                        "eRotation": currElec.basicE.rotation,
                                        "eScale": currElec.basicE.scale})
            }
        }

        for (var l = 0; l < sameElecData.count; l++) {
            identicElectrodesData[l] = sameElecData.get(l)
        }
        return identicElectrodesData
    }

    function takeScreenshot(filePath) {
        electrodePlacementMain.grabToImage(function(result) {
            if (result.saveToFile(filePath)){
                console.log("Screenshot has been saved to " + filePath);
                exportInfo.msg = filePath
                exportInfo.open()
                dialog.open();
            } else {
                console.error('Unknown error saving to ', filePath);
            }
        });
    }

    Dialog {
        id: exportInfo
        modal: true
        focus: true
        x: (window.width - width) / 2
        y: (window.height - height)/6
        property string msg: ""
        title: qsTr("<b>Information</b>")
        standardButtons: Dialog.Ok

        Column {
            spacing: 20
            Label {
                text: "Screenshot has been saved to "
            }
            Label {
                text: exportInfo.msg
            }
        }
    }

    header: ToolBar {
        height: 100

        background: Rectangle {
            color: Universal.accent
            opacity: 1
        }

        RowLayout {
            anchors.fill: parent

            ToolButton {
                implicitHeight: parent.height
                implicitWidth: 100

                contentItem: Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    Image {
                        anchors.fill: parent
                        anchors.margins: 25
                        fillMode: Image.PreserveAspectFit
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                        source: "qrc:/images/drawer@4x.png"
                    }
                }
                onClicked: drawer.open()
            }

            Label {
                id: titleLabel
                text: "Elko"
                font.pixelSize: 30
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                implicitHeight: parent.height
                implicitWidth: 100

                contentItem: Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    Image {
                        anchors.fill: parent
                        anchors.margins: 25
                        fillMode: Image.PreserveAspectFit
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                        source: "qrc:/images/menu@4x.png"
                    }
                }
                onClicked: optionsMenu.open()

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    width: window.width / 4
                    font.pixelSize: 30
                    transformOrigin: Menu.TopRight

                    onOpened: menuTimer.start()
                    onClosed: menuTimer.stop()


                    MenuItem {
                        visible: listView.currentIndex === 2
                        text: qsTr("Refresh")
                        font.pixelSize: 20
                        width: parent.width
                        height: 50
                        onTriggered: electrodeSignalLinkMain.connectSignals()
                    }

                    MenuItem {
                        text: qsTr("Reset")
                        font.pixelSize: 30
                        width: parent.width
                        height: 100
                        onTriggered: resetDialog.open()
                    }

                    MenuItem {
                        text: qsTr("Save session")
                        font.pixelSize: 30
                        width: parent.width
                        height: 100
                        onTriggered: {
                            var session = {
                                "images": setImagesForSave(),
                                "minMax": [electrodePlacementMain.minSpikes, electrodePlacementMain.maxSpikes,
                                    electrodePlacementMain.customMinSpikes, electrodePlacementMain.customMaxSpikes],
                                "electrodeData": setElectrodeDataForSave(),
                                "sameElectrodeData": setSameElectrodeDataForSave(),
                            }
                            saveSession(JSON.stringify(session, null, 4))
                        }
                    }
                    MenuItem {
                        text: qsTr("About")
                        font.pixelSize: 30
                        width: parent.width
                        height: 100
                        onTriggered: aboutDialog.open()
                    }

                    MenuItem {
                        text: qsTr("Exit")
                        font.pixelSize: 30
                        width: parent.width
                        height: 100
                        onTriggered: {
                            var session = {
                                "images": setImagesForSave(),
                                "minMax": [electrodePlacementMain.minSpikes, electrodePlacementMain.maxSpikes,
                                    electrodePlacementMain.customMinSpikes, electrodePlacementMain.customMaxSpikes],
                                "electrodeData": setElectrodeDataForSave(),
                                "sameElectrodeData": setSameElectrodeDataForSave(),
                            }
                            saveSession(JSON.stringify(session, null, 4))
                            window.exit()
                        }
                    }
                }
                Timer {
                    id: menuTimer
                    interval: 3000
                    onTriggered: optionsMenu.close()
                }
            }
        }
    }

    footer: ToolBar {
        height: 80
        background: Rectangle {
            implicitHeight: 100
            color: "white"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 100
            ToolButton {
                id: resetButton
                text: qsTr("Reset")
                font.pixelSize: 40
                implicitWidth: 200
                implicitHeight: parent.height
                anchors.left: parent.left
                onClicked: {
                    reallyDialog.open()
                }
            }

            PageIndicator {
                id: pageIndicator
                count: listView.count - 1
                currentIndex: listView.currentIndex
                anchors {horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter}
                spacing: 15
                delegate: Rectangle {
                    implicitWidth: 30
                    implicitHeight: 10

                    radius: width / 2
                    color: index === pageIndicator.currentIndex ? Universal.color(Universal.Cyan)  : pageIndicator.Universal.baseLowColor
                }
            }

            ToolButton {
                id: confirmButton
                text: qsTr("Next >")
                font.pixelSize: 40
                implicitWidth: 200
                implicitHeight: parent.height
                anchors.right: parent.right
                highlighted: true
                onClicked: {
                    enabled = false
                    stackView.currentItem.confirm()
                    enabled = true
                }
            }
        }
    }

    BusyIndicator {
        running: confirmButton.enabled === false
    }

    Drawer {
        id: drawer
        width: Math.min(window.width, window.height) / 3 * 1.5
        height: window.height

        ListView {
            id: listView
            currentIndex: -1
            anchors.fill: parent

            delegate: ItemDelegate {
                id: control
                width: parent.width
                height: 120
                text: modelData.name
                font.pixelSize: 30
                highlighted: ListView.isCurrentItem
                Universal.accent: Universal.Cyan

                onClicked: {
                    if (modelData.switchElement === true) {
                        // save session when switched to Alenka
                        var session = {
                            "images": setImagesForSave(),
                            "minMax": [electrodePlacementMain.minSpikes, electrodePlacementMain.maxSpikes,
                                electrodePlacementMain.customMinSpikes, electrodePlacementMain.customMaxSpikes],
                            "electrodeData": setElectrodeDataForSave(),
                            "sameElectrodeData": setSameElectrodeDataForSave(),
                        }
                        saveSession(JSON.stringify(session, null, 4))
                        // switch to Alenka
                        window.switchToAlenka()

                    } else if (listView.currentIndex != index){
                        changePage(index, modelData)
                    }

                    drawer.close()
                }
            }
            model: [ imageManagerMain, electrodeManagerMain, electrodeSignalLinkMain, electrodePlacementMain, alenka ]
            ScrollIndicator.vertical: ScrollIndicator { }

            onCurrentIndexChanged: {
                if (currentIndex == 3) {
                    confirmButton.text = qsTr("Export image")
                    confirmButton.width = 300

                } else if (confirmButton.text !== qsTr("Next >")){
                    confirmButton.text = qsTr("Next >")
                    confirmButton.width = 200
                }
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Pane {
            id: pane
            property string name: qsTr("Welcome page")
            Image {
                source: "qrc:/images/Doctor_Hibbert.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: parent;
            }

            PinchArea {
                anchors.fill: parent
                pinch.target: pane
                pinch.minimumScale: 1
                pinch.maximumScale: 10
                pinch.dragAxis: Pinch.XAndYAxis
                onSmartZoom: pane.scale = pinch.scale
                onPinchFinished: {
                    pane.scale = 1
                    pane.x = 0
                    pane.y = 0
                }
            }

            function confirm() {  changePage(0, imageManagerMain) }

            function reset() {} // do nothing on this page
        }
    }

    Dialog {
        id: aboutDialog
        modal: true
        focus: true
        x: (window.width - width) / 2
        y: window.height / 6
        standardButtons: Dialog.Ok

        Column {
            id: aboutColumn
            spacing: 20

            Label {
                text: qsTr("About")
                font.bold: true
            }
            Label {
                text: qsTr("Author:   Lenka Svobodová ")
            }
            Label {
                text: qsTr("E-mail:   svobole5@fel.cvut.cz ")
            }
            Label {
                text: qsTr("Year:     2017")
            }
        }
    }

    Dialog {
        id: reallyDialog
        modal: true
        focus: true
        x: (window.width - width) / 2
        y: window.height / 6
        title: "<b>Are you sure?</b>"
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: stackView.currentItem.reset()

        Label {
            text: qsTr("Page will be reset to default state.")
        }
    }

    Dialogs.FileDialog {
        id: saveDialog
        folder: shortcuts.documents
        selectExisting: false
        nameFilters: [ qsTr("All files (*)") ]
        onAccepted: { }
        onRejected: console.log("Saving file canceled.")
    }

    Dialog {
        id: resetDialog
        modal: true
        focus: true
        x: (window.width - width) / 2
        y: window.height / 6
        title: "<b>Are you sure?</b>"
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            imageManagerMain.reset()
            electrodeManagerMain.reset()
            electrodeSignalLinkMain.reset()
            electrodeSignalLinkMain.electrodes.clear()
            electrodePlacementMain.reset()
            electrodePlacementMain.images = []
            electrodePlacementMain.electrodes.clear()
        }

        Label {
            text: qsTr("Application will be reset to default state.")
        }
    }

    Pages.XmlModels {
        id: xmlModels
        sourcePath: file
    }

    Pages.ImageManager { id: imageManagerMain; enabled: false; visible: false }

    Pages.ElectrodeManager {id: electrodeManagerMain; enabled: false; visible: false }

    Pages.ElectrodeSignalLink {id: electrodeSignalLinkMain; enabled: false; visible: false }

    Pages.ElectrodePlacement {id: electrodePlacementMain; enabled: false; visible: false }

    Item { id: alenka; property string name: qsTr("Switch to Alenka"); property bool switchElement: true }


}
