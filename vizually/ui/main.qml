import QtQuick 2.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Extras 1.4
import Images 1.0

ApplicationWindow {
    id: window
    objectName: "window"
    width: 1600; height: 900
    title: project && project.loaded ?
               ((project.url.toString().length > 0 ? project.displayUrl : "Untitled") + (project.unsavedChanges ? "*" : "")) : ""
    property var currentChose: undefined
    property real defaultSize: 400
    property real zoomRatio: 1.0

    FileDialog {
        id: fileDialog
        title: "Choose an Image for testing"
        folder: shortcuts.home
        onAccepted: {
            console.log(fileUrl)
            mainImage.load_image(fileUrl)
        }
        property var imageNameFilters : ["*.png", "*.jpg", ".jpeg"]
        Component.onCompleted: {
            if (typeof contextInitialUrl !== 'undefined') {
                // Launched from python with context properties set.
                imageNameFilters = contextImageNameFilters;
                picturesLocation = contextPicturesLocation;
                if (contextInitialUrl == "")
                    fileDialog.open();
                else
                    folderModel.folder = contextInitialUrl + "/";
            } else {
                // Launched via QML viewer without context properties set.
                fileDialog.open();
            }
        }
    }
    Button {
        x: 150; y: 450
        text: 'gray'
        onClicked: mainImage.apply('gray')
    }
    Label {
        id: mousePosition
        x: 150; y: 550
        text: "%1".arg(zoomArea.mouseX.toString())
    }

    Flickable {
        id: flickable
        x: 350; y: 0
        width: 1250; height: 900
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: width * zoomRatio; contentHeight: height * zoomRatio // current size of viewport
        clip: true
        ScrollBar.vertical: ScrollBar {
            id: verticalScrollBar
            active: horizontalScrollBar.active
        }
        ScrollBar.horizontal: ScrollBar {
            id: horizontalScrollBar
            active: verticalScrollBar.active
        }
        Rectangle {
            id: photoFrame
            width: mainImage.width + 10; height: mainImage.height + 10
            scale: defaultSize / Math.max(image.sourceSize.width, image.sourceSize.height)
            Behavior on scale { NumberAnimation { duration: 20 } }
            Behavior on x { NumberAnimation { duration: 20 } }
            Behavior on y { NumberAnimation { duration: 20 } }
            border.width: 10
            border.color: "transparent"
            smooth: true
            antialiasing: true
            ImageWriter {
                id: mainImage
                width: _width
                height: _height
                anchors.centerIn:parent
            }
            MouseArea {
                id: zoomArea
                hoverEnabled: true
                anchors.fill: parent
                drag.target: photoFrame
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                onPressed: parent.setToBeSelected();
                onWheel: {
                    if (wheel.modifiers & Qt.ControlModifier) {
                        photoFrame.scale += photoFrame.scale * wheel.angleDelta.y / 120 / 10;
                    }
                }
            }
            function setToBeSelected() {
                if (currentChose) {
                    currentChose.border.color = "transparent"
                }
                currentChose = photoFrame;
                currentChose.border.color = "yellow";
            }
        }
    }  

}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/