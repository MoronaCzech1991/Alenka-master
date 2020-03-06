import QtQuick 2.7
import QtQuick.Controls 2.1

Switch {
    id: control
    indicator.width: 100
    indicator.height: 40

    Component.onCompleted: {
        indicator.children[1].width = 40
        indicator.children[1].height = 40
        indicator.children[1].radius = 20
        indicator.children[0].radius = 20
    }
}
