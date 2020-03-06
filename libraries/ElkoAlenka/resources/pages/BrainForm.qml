import QtQuick 2.7
import QtQuick.Controls 2.1

Image {
    id: brainImage

    property int orderNum: 0
    readonly property string plusImgSource: "qrc:/images/plus.png"

    property alias info: info
    property alias mouseArea: mouseArea
    property alias checkbox: checkbox
    property alias menu: menu
    property alias changeMenu: changeMenu
    property alias deleteMenu: deleteMenu
    property alias closeMenu: closeMenu
    property alias brainImage: brainImage

    source: ""
    fillMode: Image.PreserveAspectFit
    width: parent.width/2
    height: parent.height/2

    Dialog {
        id: info
        modal: true
        focus: true
        x: (window.width - width) / 2
        y: (window.height - height) / 6
        title: qsTr("<b>Information</b>")
        standardButtons: Dialog.Ok

        Label { text: qsTr("Please choose a image file (*.jpg *.png *.bmp)") }
    }

    CheckBox {
        id: checkbox
        visible: brainImage.source != plusImgSource
        checked: false
        anchors.fill: parent
        indicator: Rectangle {
            implicitWidth: 26
            implicitHeight: 26
            x: checkbox.x + checkbox.width - 2*width
            y: checkbox.y + checkbox.height - 2*height
            radius: 3
            border.color: "black"

            Rectangle {
                width: 14
                height: 14
                x: 6
                y: 6
                radius: 2
                color: checkbox.checked ? "skyblue" : "black"
                visible: checkbox.checked
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        scrollGestureEnabled: false

        Menu {
            id: menu
            x: mouseArea.mouseX
            y: mouseArea.mouseY

            MenuItem {
                id: changeMenu
                text: qsTr("Change")
            }
            MenuItem {
                id: deleteMenu
                text: qsTr("Delete")
            }
            MenuItem {
                id: closeMenu
                text: qsTr("Close menu")
            }
        }
    }
}
