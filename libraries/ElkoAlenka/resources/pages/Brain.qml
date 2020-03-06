import QtQuick 2.7
import QtQuick.Dialogs 1.2

BrainForm {

    mouseArea.onClicked: {
        if (brainImage.source == plusImgSource) {
            // close file dialog if opened
            if (loader.sourceComponent === fileComp) {
                loader.sourceComponent = undefined
            }

            // open file dialog
            loader.sourceComponent = fileComp

        } else {
            // check image
            checkbox.checked = !checkbox.checked
            menu.visible = false
        }
    }

    mouseArea.onDoubleClicked: {
        menu.open()
    }

    mouseArea.onPressed: {

        //check for open dialogs and menu on the page a close them
        for(var i = 0; i < 4; i++) {
            if (brainImage.parent.children[i].loader.sourceComponent !== undefined) {
                brainImage.parent.children[i].loader.sourceComponent = undefined
            }
             brainImage.parent.children[i].menu.close()
        }
    }

    changeMenu.onTriggered: {
        // close opened file dialog
        if (loader.sourceComponent === fileComp) {
            loader.sourceComponent = undefined
        }

        // open file dialog
        loader.sourceComponent = fileComp
    }

    deleteMenu.onTriggered: {

        if (brainImage.source == plusImgSource) {

            console.log("Last picture cannot be deleted.")

        } else {

            // delete image and move following images one position forward
            for (var j = imageManager.swipe.currentIndex; j < imageManager.swipe.count; j++) {

                var temp = imageManager.swipe.itemAt(j).images
                var i = (j === imageManager.swipe.currentIndex) ? orderNum : 0

                for (i; i < temp.count - 1; i++) {

                    temp.itemAt(i).source           = temp.itemAt(i+1).source
                    temp.itemAt(i).checkbox.visible = temp.itemAt(i+1).checkbox.visible
                    temp.itemAt(i).checkbox.checked = temp.itemAt(i+1).checkbox.checked
                    temp.itemAt(i).visible          = temp.itemAt(i+1).visible
                }

                if (j < imageManager.swipe.count - 1) { //there is at least one more swipe page
                    temp.itemAt(i).source           = imageManager.swipe.itemAt(j+1).images.itemAt(0).source
                    temp.itemAt(i).checkbox.checked = imageManager.swipe.itemAt(j+1).images.itemAt(0).checkbox.checked
                    temp.itemAt(i).checkbox.visible = (temp.itemAt(i).source == plusImgSource) ? false : true

                } else if (j === imageManager.swipe.count - 1) {    //last page
                    temp.itemAt(i).visible = false

                    var empty = true
                    for (var k = 0; k < imageManager.swipe.itemAt(j).images.count; k++) {
                        empty = empty && !imageManager.swipe.itemAt(j).images.itemAt(k).visible
                    }

                    // if last page is empty, delete it
                    if (empty === true) {
                        imageManager.swipe.removeItem(imageManager.swipe.count - 1)
                    }
                }
            }
            console.log("Image has been deleted.")
        }
    }

    closeMenu.onTriggered: {
        menu.close();
    }

    checkbox.onCheckStateChanged:  {
        brainImage.opacity = checkbox.checked ? 0.5 : 1
    }

    function checkIfImage(source) {
        var fileExtension = source.substring(source.length-4,source.length).toLowerCase()
        return ( (fileExtension === (".jpg")) || (fileExtension === ".png") || (fileExtension === ".bmp"))
    }

    Component {
        id: fileComp

        FileDialog {
            id: fileDialog
            nameFilters: [ "Image files (*.jpg *.png *.bmp)", "JPEG Image (*.jpg)", "PNG Image (*.png)", "Bitmap Image (*.bmp)" ]
            folder: shortcuts.pictures
            onAccepted: {
                var path = fileDialog.fileUrl
                if (checkIfImage(path.toString())) {

                    if(brainImage.source == plusImgSource) {

                        // add new empty picture
                        if (orderNum < imageManager.swipe.itemAt(imageManager.swipe.currentIndex).images.count - 1) {
                            imageManager.swipe.itemAt(imageManager.swipe.currentIndex).images.itemAt(orderNum+1).visible = true

                        } else {
                            imageManager.swipe.addItem(newPage.createObject(imageManager.swipe, {"imageModel": imageManager.pluses}))
                            imageManager.swipe.currentIndex++
                            console.log("Page number " + swipe.currentIndex + " was added to swipe. (Counting from zero.)")
                        }
                    }
                    brainImage.source = path
                    console.log("You chose: " + source)

                } else {
                    console.log("Chosen file is not an image.")
                    info.open()
                }

                // close file dialog
                loader.sourceComponent = undefined
            }
            onRejected: {
                loader.sourceComponent = undefined
//                console.log("Choosing file canceled.")
            }
            Component.onCompleted: { open() }
        }
    }

    Loader {
        id: loader
    }

    property alias loader: loader

}
