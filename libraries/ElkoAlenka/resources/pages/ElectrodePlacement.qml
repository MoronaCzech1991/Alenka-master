import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Universal 2.1

ElectrodePlacementForm {

    statisticsTableButton.onClicked:   {
        showStatistics(false)
        statisticsTable.open()
    }

    statisticsButton.onClicked: {
        if (statisticsButton.highlighted)
            hideStatistics()
        else
            showStatistics(true)
    }

    // implement reset button on page footer
    function reset() {

        // reset page to default position
        var electrodeI;
        for (var i = 0; i < electrodeRep.count; i++) {
            for (var j = 0; j < electrodeRep.itemAt(i).elec.children.length; j++) {
                electrodeI = electrodeRep.itemAt(i).elec.children[j];

                electrodeI.basicE.parent = electrodeI.root;
                electrodeI.basicE.x = 0
                electrodeI.basicE.y = 0
                electrodeI.basicE.scale = 1
                electrodeI.basicE.rotation = 0
                electrodeI.root.indexNumber = 1
            }
        }
        imageArea.scale = 1;
        imageArea.x = 0;
        imageArea.y = 0;
    }

    function showStatistics(changeColors) {
        var i   = 0.2 * (customMaxSpikes - customMinSpikes) + customMinSpikes;
        var ii  = 0.4 * (customMaxSpikes - customMinSpikes) + customMinSpikes;
        var iii = 0.6 * (customMaxSpikes - customMinSpikes) + customMinSpikes;
        var iv  = 0.8 * (customMaxSpikes - customMinSpikes) + customMinSpikes;
        var electrodeColor;
        var currElec;
        var currElecSpikes;
        electrodeSpikesModel.clear()

        for (var m = 0; m < electrodeRep.count; m++) {

            for (var j = 0; j < electrodeRep.itemAt(m).elec.children.length; j++) {
                currElec = electrodeRep.itemAt(m).elec.children[j].basicE;

                for (var k = 0; k < currElec.rowCount; k++) {

                    for (var l = 0; l < currElec.columnCount; l++) {

                        if(currElec.rowRep.itemAt(k).colRep.itemAt(l).trackName !== "") {

                            currElecSpikes = currElec.rowRep.itemAt(k).colRep.itemAt(l).spikes

                            if(changeColors) {

                                if (currElecSpikes < customMinSpikes) {
                                    electrodeColor = gradient.stops[0].color

                                } else if ( currElecSpikes <= i ) {
                                    electrodeColor = gradient.stops[0].color;

                                } else if (currElecSpikes <= ii) {
                                    electrodeColor = gradient.stops[1].color;

                                } else if (currElecSpikes <= iii) {
                                    electrodeColor = gradient.stops[2].color;

                                } else if (currElecSpikes <= iv) {
                                    electrodeColor = gradient.stops[3].color;

                                } else if (currElecSpikes <= customMaxSpikes) {
                                    electrodeColor = gradient.stops[4].color;

                                } else {
                                    electrodeColor = gradient.stops[4].color;
                                }

                                currElec.rowRep.itemAt(k).colRep.itemAt(l).colorFill = electrodeColor;
                                statisticsButton.text = "Hide statistics"
                                statisticsButton.highlighted = true






                            } else if (j === 0){
                                electrodeSpikesModel.append({"name": currElec.rowRep.itemAt(k).colRep.itemAt(l).name, "spikes": currElecSpikes})
                            }
                        }
                    }
                }
            }
        }
    }

    function hideStatistics() {
        var currElec;

        for (var m = 0; m < electrodeRep.count; m++) {

            for (var j = 0; j < electrodeRep.itemAt(m).elec.children.length; j++) {
                currElec = electrodeRep.itemAt(m).elec.children[j].basicE;

                for (var k = 0; k < currElec.rowCount; k++) {

                    for (var l = 0; l < currElec.columnCount; l++) {

                        currElec.rowRep.itemAt(k).colRep.itemAt(l).colorFill = "white";
                    }
                }
            }
        }

        statisticsButton.text = "Show statistics"
        statisticsButton.highlighted = false
    }

    gradientMouse.onPressed: {
        window.confirmButton.enabled = false
        window.confirmButton.text = ""
        window.resetButton.enabled = false
        window.resetButton.text = ""

        // open dialog with setting of color gradient
        stackView.push(colorDialog, {})
    }

    comboBox.onCurrentIndexChanged: {
        changeNames(comboBox.currentIndex);
    }

    zoomSwitch.onCheckedChanged: {
        // enable or disable image zoom
        zoomEnabled = zoomSwitch.checked;
    }

    fixButton.onCheckedChanged: {
        // fix or change electrodes positions
        var electrodeI;
        for (var i = 0; i < electrodeRep.count; i++) {
            for (var j = 0; j < electrodeRep.itemAt(i).elec.children.length; j++) {
                electrodeI = electrodeRep.itemAt(i).elec.children[j];

                electrodeI.draggable = !fixButton.checked;
                electrodeI.mouseArea.drag.target = (fixButton.checked) ? null : electrodeI.basicE;
            }
        }
    }

    function setColors(color1, color3, color5, color7, color9) {
        // set colors of gradient
        for (var i = 0; i < arguments.length; i++) {
            setColor(i, arguments[i])
        }
    }

    function setColor(gradientNum, color) {
        // set gradient color on specific gradient stop
        gradient.stops[gradientNum].color = color
    }

    Component.onCompleted: {
        setColors(Universal.color(Universal.Cobalt), Universal.color(Universal.Green),
                  Universal.color(Universal.Yellow), Universal.color(Universal.Orange),
                  Universal.color(Universal.Red))
        customMinSpikes = minSpikes
        customMaxSpikes = maxSpikes
    }

    function changeNames(comboBoxValue) {
        var currElec
        for (var i = 0; i < electrodeRep.count; i++) {

            for (var j = 0; j < electrodeRep.itemAt(i).elec.children.length; j++) {
                currElec = electrodeRep.itemAt(i).elec.children[j].basicE;

                for (var k = 0; k < currElec.rowCount; k++) {

                    for (var l = 0; l < currElec.columnCount; l++) {

                        switch (comboBoxValue) {
                        case 0: // only default name
                            currElec.rowRep.itemAt(k).colRep.itemAt(l).name = currElec.rowRep.itemAt(k).colRep.itemAt(l).defaultName;
                            break;
                        case 1: // only wave names (non-linked are empty)
                            currElec.rowRep.itemAt(k).colRep.itemAt(l).name = currElec.rowRep.itemAt(k).colRep.itemAt(l).trackName;
                            break;
                        default: // wave names, non-linked default name
                            currElec.rowRep.itemAt(k).colRep.itemAt(l).name =
                                    (currElec.rowRep.itemAt(k).colRep.itemAt(l).trackName === "") ?
                                        currElec.rowRep.itemAt(k).colRep.itemAt(l).defaultName : currElec.rowRep.itemAt(k).colRep.itemAt(l).trackName;
                            break;
                        }
                    }
                }
            }
        }
    }

    // implement export image button
    function confirm() {
        // check if opened dialog, close it
        if(loader.sourceComponent === fileComp) {
            loader.sourceComponent = undefined
        }

        // open file dialog
        loader.sourceComponent = fileComp;
    }

    Component {
        id: fileComp

        QtObject {
            Component.onCompleted: window.exportDialog();
        }
    }

    Loader {
        // loader for file dialog
        id: loader
    }

}
