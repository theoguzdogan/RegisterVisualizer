import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    property string registerId;
    property string moduleId;
    property bool alert;

    width: 150
    height: 20

    palette.buttonText: "white"

    background: Rectangle {
        radius: 3

        gradient: Gradient {
            GradientStop { position: 0.0; color: pressed ? "#9ecbf7" : (hovered ? "#52a7fa" : "#4891d9") }
            GradientStop { position: 1.0; color: pressed ? "#81bdf7" : (hovered ? "#81bffc" : "#2358a3") }
        }
    }

    onClicked: {
        backend.setGlobalFieldId(-1)
        backend.setGlobalModuleId(parseInt(moduleId))
        clearConf()
        createFieldButtons(registerId)
        Promise.resolve().then(updateRegisterTextBox)
        refresh()
    }

    ToolTip.delay: 500
    ToolTip.timeout: 5000
    ToolTip.visible: hovered

    Component.onCompleted: {
        ToolTip.text = qsTr(backend.getFileList()[moduleId].split(".")[0] + " > " + backend.getRegisterList()[registerId])
    }

    Button {
        id: registerTabCloseButton
        width: 20
        height: 20

        anchors.right: parent.right

//        text: "X"
        Image {
            source: registerTabCloseButton.hovered ? "../../../assets/close-filled.svg" : "../../../assets/close-filled-grey.svg"

            width: parent.width-4
            height: parent.height-4
            anchors.centerIn: parent
        }


        background: Rectangle {
            color: "transparent"
            radius: 10
            width: parent.width-4
            height: parent.height-4
        }
//        onPressed: background.color = "#a3bed0"
//        onReleased: { background.color = "#4891d9"
//            if (hovered) {background.color = "#74a8db"}
//            else {background.color = "#4891d9"}
//        }

//        onHoveredChanged: {
//            if (hovered) {background.color = "#74a8db"}
//            else {background.color = "#4891d9"}
//        }

        onClicked: {
            destroyRegisterTabAlias(moduleId, registerId)
        }
    }

}


