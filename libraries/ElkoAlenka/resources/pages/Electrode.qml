import QtQuick 2.7
import QtQuick.Controls 2.1


Item {
    id: root
    property int columnCount
    property int rowCount
    property int size: 60
    property int indexNumber: 1
    property int repeaterIndex
    property bool draggable: true
    property bool flickable: true
    property int yPosition: 0
    property ListModel linkList

    property alias basicE: electrode
    property alias mouseArea: mouseArea
    property alias root: root
    property alias color: electrode.color

    width: columnCount*size; height: rowCount*size;

    Rectangle {
        id: sourceBorder;
        anchors.fill: parent;
        border.color: "black"
        color: "transparent"
        radius: size/2
    }
    onColorChanged: {
        sourceBorder.border.color = (Qt.colorEqual(root.color, "white")) ? "black" : root.color
    }

    Flickable {
        id: flick
        enabled: flickable

        BasicElectrode {
            id: electrode
            columnCount: root.columnCount
            rowCount: root.rowCount
            size: root.size
            droppingEnabled: false
            linkedTracks: linkList
            parent: root

            Behavior on scale { NumberAnimation { duration: 200 } }
            Behavior on x { NumberAnimation { duration: 0 } }
            Behavior on y { NumberAnimation { duration: 0 } }

            Drag.active: mouseArea.drag.active

            PinchArea {
                enabled: draggable
                anchors.fill: parent
                pinch.target: electrode
                pinch.minimumRotation: -360
                pinch.maximumRotation: 360
                pinch.minimumScale: 0.1
                pinch.maximumScale: 10
                pinch.dragAxis: Pinch.XAndYAxis
                onSmartZoom: {
                    if (pinch.scale > 0) {
                        electrode.rotation = 0;
                        electrode.scale = Math.min(root.width, root.height) / Math.max(electrode.sourceSize.width, electrode.sourceSize.height) * 0.85
                        electrode.x = flick.contentX + (flick.width - electrode.width) / 2
                        electrode.y = flick.contentY + (flick.height - electrode.height) / 2
                    } else {
                        electrode.rotation = pinch.previousAngle
                        electrode.scale = pinch.previousScale
                        electrode.x = pinch.previousCenter.x - electrode.width / 2
                        electrode.y = pinch.previousCenter.y - electrode.height / 2
                    }
                }
                MouseArea {
                    id: mouseArea
                    property int tempX: 0
                    property int tempY: 0
                    hoverEnabled: true
                    anchors.fill: parent
                    anchors.centerIn: parent
                    drag.target: electrode
                    scrollGestureEnabled: false  // 2-finger-flick gesture should pass through to the Flickable
                    onPressed: {
                        tempX = Math.round(electrode.x)
                        tempY = Math.round(electrode.y)
                        electrode.z = ++electrodePlacementMain.zHighest
                    }
                    onWheel: {
                        if (draggable) {
                            if (wheel.modifiers & Qt.ControlModifier) {
                                electrode.rotation += wheel.angleDelta.y / 120 * 5;
                                if (Math.abs(electrode.rotation) < 4) {
                                    electrode.rotation = 0;
                                }
                            } else {
                                electrode.rotation += wheel.angleDelta.x / 120;
                                if (Math.abs(electrode.rotation) < 0.6) {
                                    electrode.rotation = 0;
                                }
                                electrode.scale += electrode.scale * wheel.angleDelta.y / 120 / 10;
                            }
                        }
                    }
                    onReleased: {
                        if (tempX !== Math.round(electrode.x) || tempY !== Math.round(electrode.y)) {
                            var previousParent = electrode.parent
                            electrode.parent = (electrode.Drag.target === null) ?  root : electrode.Drag.target

                            if (previousParent == root & electrode.parent != root ) {
                                electrode.x = electrode.x + electrode.parent.width
                                        + electrodePlacement.electrodeRep.itemAt(root.repeaterIndex).elec.x
                                        + electrodePlacement.column.padding
                                        - electrodePlacement.imageArea.x / electrodePlacement.imageArea.scale

                                electrode.y = electrode.y + root.yPosition - electrodePlacement.column.spacing
                                        - electrodePlacement.column.height * electrodePlacement.scrollIndicator.position
                                        - electrodePlacement.imageArea.y / electrodePlacement.imageArea.scale

                                electrode.scale = electrode.scale / electrodePlacement.imageArea.scale

                            } else if (electrode.parent == root){
                                electrode.x = 0
                                electrode.y = 0
                                electrode.scale = 1
                                electrode.rotation = 0
                            } //else nothing (just moving with mouse)
                        }
                    }
                    onDoubleClicked: menu.open()
                }
            }

            Menu {
                id: menu
                x: root.width/2
                y: root.height/2
                width: 150
                closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent | Popup.CloseOnEscape
                onOpened: elecTimer.start()
                onClosed: elecTimer.stop()
                MenuItem {
                    text: qsTr("Fix position")
                    onTriggered: {
                        draggable = false
                        mouseArea.drag.target = null
                    }
                }
                MenuItem {
                    text: qsTr("Change position")
                    onTriggered: {
                        draggable = true
                        mouseArea.drag.target = electrode
                    }
                }
                MenuItem {
                    text: qsTr("Change color...")
                    onTriggered: colorMenu.open()

                    Menu {
                        id: colorMenu
                        x: parent.width
                        y: 0
                        width: 120
                        title: qsTr("Change color...")
                        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnPressOutsideParent | Popup.CloseOnEscape

                        signal menuClicked(color itemColor)
                        onMenuClicked: {
                            electrode.color = itemColor
                            sourceBorder.border.color = (Qt.colorEqual(itemColor, "white")) ? "black" : itemColor
                            root.parent.color = itemColor
                            colorMenu.close()
                        }

                        Column {
                            spacing: 0
                            Repeater {
                                model: ["purple", "blue", "green", "yellow", "orange", "red"]
                                MenuItem {
                                    Rectangle {anchors.fill: parent; color: modelData}
                                    onTriggered: colorMenu.menuClicked(modelData)
                                }
                            }
                            MenuItem {
                                text: "default"
                                onTriggered: colorMenu.menuClicked("white")
                            }
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Reset position")
                    onTriggered: {
                        electrode.parent = root
                        electrode.x = 0
                        electrode.y = 0
                        electrode.scale = 1
                        electrode.rotation = 0
                    }
                }
                MenuItem {
                    text: qsTr("Close menu")
                    onTriggered: menu.close()
                }
            }

            Timer {
                id: elecTimer
                interval: 5000
                onTriggered: menu.close()
            }
        }
    }
}
