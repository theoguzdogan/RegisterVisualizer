import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    property string registerId;
    property bool alert;

    signal registerClicked(string registerId);

    width: rootObject.width / 6

    palette.buttonText: "white"

    background: Rectangle {
        id: registerButtonBackground
        radius: 10

        gradient: Gradient {
            GradientStop { position: 0.0; color: loadingScreen.visible ? "#4891d9" : (pressed ? "#9ecbf7" : (hovered ? "#52a7fa" : "#4891d9")) }
            GradientStop { position: 1.0; color: loadingScreen.visible ? "#2358a3" : (pressed ? "#81bdf7" : (hovered ? "#81bffc" : "#2358a3")) }
        }
    }

    onClicked: {
        registerClicked(registerId)
    }

    Image {
        source: "../../../assets/warning.svg"
        width: 23
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.rightMargin: 5
        height: 25
        visible: alert
    }

    Button {
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.verticalCenter: parent.verticalCenter

        background: Rectangle{
            color: "transparent"
            radius: 10
        }

        height: parent.height-4
        width: parent.height-4

        Image {
            id: pinButtonImage
            width: parent.width-9
            height: parent.height-9
            anchors.centerIn: parent
        }

        onClicked: {
            if (backend.findPinConfig("reg", registerId) !== -1) {
                backend.removeFromPinConfig("reg", registerId);
                Promise.resolve().then(()=>{
                    if (backend.findPinConfig("reg", regId) !== -1) {
                       pinButtonImage.source = "../../../assets/push-pin-fill.svg"
                    }
                    else {
                       pinButtonImage.source = "../../../assets/push-pin-bold.svg"
                    }
                })
            }
            else {
                backend.addToPinConfig("reg", registerId);
                Promise.resolve().then(()=>{
                    if (backend.findPinConfig("reg", regId) !== -1) {
                       pinButtonImage.source = "../../../assets/push-pin-fill.svg"
                    }
                    else {
                       pinButtonImage.source = "../../../assets/push-pin-bold.svg"
                    }
                })
            }

//            createRegisterButtons(backend.returnGlobalModuleId())
            createPinButtons()
        }

        Component.onCompleted: {
            if (backend.findPinConfig("reg", registerId) !== -1) {
                pinButtonImage.source = "../../../assets/push-pin-fill.svg"
            }
            else {
                pinButtonImage.source = "../../../assets/push-pin-bold.svg"
            }
        }
    }

    function changeBorderToSelectedState(){
        registerButtonBackground.border.color = "#FFFFFF"
        registerButtonBackground.border.width = 2
    }
    function changeBorderToNormalState(){
        registerButtonBackground.border.width = 0
    }

}
