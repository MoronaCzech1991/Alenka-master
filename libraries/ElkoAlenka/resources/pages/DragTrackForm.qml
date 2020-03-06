import QtQuick 2.7

Item {
    id: root
    property int size: 80
    property string trackName: "X"
    property int trackId: -1
    property int spikes: 0

    property alias mouseArea: mouseArea
    property alias tile: tile
    property alias root: root

    width: size; height: size

    MouseArea {
        id: mouseArea
        width: size; height: size
        anchors.centerIn: parent
        drag.target: tile

        Rectangle {
            id: tile
            width: size; height: size; radius: size/2
            border.color: "black"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Drag.active: mouseArea.drag.active
            Drag.hotSpot.x: width/2
            Drag.hotSpot.y: height/2

            Text {
                text: trackName
                font.pixelSize: root.size / 2
                minimumPixelSize: 10
                anchors.fill: parent
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
            }
        }
    }
}
