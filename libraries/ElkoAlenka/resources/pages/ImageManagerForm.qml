import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.Controls.Universal 2.1

Page {
    id: imageManager
    property string name: qsTr("Image Manager")
    property var images
    property ListModel brains: ListModel {
        ListElement { sourcePath: "qrc:/images/brains/brain1.png"}
        ListElement { sourcePath: "qrc:/images/brains/brain3.png"}
        ListElement { sourcePath: "qrc:/images/brains/brain4.png"}
        ListElement { sourcePath: "qrc:/images/brains/brain2.jpg"}
    }
    property ListModel pluses: ListModel {
        ListElement { sourcePath: "qrc:/images/plus.png"}
        ListElement { sourcePath: "qrc:/images/plus.png"}
        ListElement { sourcePath: "qrc:/images/plus.png"}
        ListElement { sourcePath: "qrc:/images/plus.png"}
    }

    property alias swipe: swipe
    property alias imageManager: imageManager

    SwipeView {
        id: swipe
        currentIndex: 0
        anchors {fill: parent; bottom: indicator.top}

        Component.onCompleted: {
            swipe.addItem(newPage.createObject(swipe, {"imageModel": brains}))
            swipe.addItem(newPage.createObject(swipe, {"imageModel": pluses}))
        }
    }


    Component {
        id: newPage

        Pane {
            id: secondPage
            property alias images: rep
            property ListModel imageModel
            width: swipe.width
            height: swipe.height

            Label {
                id: label
                text: swipe.currentIndex === 0 ? qsTr("Photo upload avalaible on next page >>") : ""
                font {pixelSize: 25; italic: true}
                width: parent.width
                z: 2
                anchors {margins: 5; left: parent.left; right: parent.right}
                horizontalAlignment: Qt.AlignHCenter
                wrapMode: Label.Wrap
            }

            Grid {
                id: imageGrid
                columns: 2
                rows: 2
                spacing: 10
                width: parent.width
                height: parent.height

                Repeater {
                    id: rep
                    model: imageModel
                    Brain {
                        orderNum: index
                        source: model.sourcePath
                        visible: (model.sourcePath === "qrc:/images/plus.png" & index > 0) ? false : true
                    }
                }
            }
        }
    }

    PageIndicator {
        id: indicator
        count: swipe.count
        currentIndex: swipe.currentIndex
        anchors {bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
        delegate: Rectangle {
            implicitWidth: 10
            implicitHeight: 10

            radius: width / 2
            color: index === indicator.currentIndex ? indicator.Universal.baseMediumHighColor :
                                                           pressed ? indicator.Universal.baseMediumLowColor : indicator.Universal.baseLowColor
        }
    }
}
