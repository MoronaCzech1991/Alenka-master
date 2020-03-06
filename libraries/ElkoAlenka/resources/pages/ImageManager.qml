import QtQuick 2.7
import QtQuick.Controls 2.1



ImageManagerForm {

    // return array with sources of checked images
    function getCheckedImages() {
        var sourceArray = []
        for (var k = 0; k < swipe.count; k++) {
            for (var i = 0; i < swipe.itemAt(k).images.count; i++) {
                if (swipe.itemAt(k).images.itemAt(i).checkbox.checked) {
                    sourceArray.push(swipe.itemAt(k).images.itemAt(i).source)
                }
            }
        }
        return sourceArray
    }

    function checkImage(imageSource) {
        for (var k = 0; k < swipe.count; k++) {
            for (var i = 0; i < swipe.itemAt(k).images.count; i++) {
                if (swipe.itemAt(k).images.itemAt(i).source == imageSource) {
                    swipe.itemAt(k).images.itemAt(i).checkbox.checked = true
                    return
                }
            }
        }

        // in not in default choice, add picture and check it (checkbox)
        var orderNum = getLastImageIndex()
        swipe.itemAt(swipe.count-1).images.itemAt(orderNum).source = imageSource
        swipe.itemAt(swipe.count-1).images.itemAt(orderNum).checkbox.checked = true

        // add new empty picture
        if (orderNum < swipe.itemAt(swipe.count-1).images.count - 1) {
            swipe.itemAt(swipe.count-1).images.itemAt(orderNum+1).visible = true

        } else {
            swipe.addItem(newPage.createObject(swipe, {"imageModel": pluses}))
            swipe.currentIndex++
            console.log("Page number " + swipe.currentIndex + " was added to swipe. (Counting from zero.)")
        }
    }

    function getLastImageIndex() {
        // return index of plus picture (last picture in swipe)
        for (var k = 0; k < swipe.count; k++) {
            for (var i = 0; i < swipe.itemAt(k).images.count; i++) {
                if (swipe.itemAt(k).images.itemAt(i).source == "qrc:/images/plus.png") {
                    return i
                }
            }
        }
    }

    // implement next button
    function confirm() {

        // close opened dialogs
        for (var k = 0; k < swipe.count; k++) {
            for (var i = 0; i < swipe.itemAt(k).images.count; i++) {
                if(swipe.itemAt(k).images.itemAt(i).loader.sourceComponent !== undefined)
                    swipe.itemAt(k).images.itemAt(i).loader.sourceComponent = undefined
            }
        }


        var checkedImages = getCheckedImages()
        //        console.log("User chose " + checkedImages.length + " image(s): " + checkedImages.toString())
        electrodePlacementMain.images = checkedImages
        changePage(1, window.electrodeManagerMain)
    }

    // reset page to default state
    function reset() {
        for (var k = 0; k < swipe.count; k++) {
            for (var i = 0; i < swipe.itemAt(k).images.count; i++) {
                swipe.itemAt(k).images.itemAt(i).checkbox.checked = false
            }
        }
    }
}
