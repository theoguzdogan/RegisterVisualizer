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

    background: Rectangle {
        id: registerButtonBackground
        color: "#4891d9"
        radius: 10
    }

    onPressed: background.color = "#a3bed0"
    onReleased: { background.color = "#4891d9"
        if (hovered) {background.color = "#74a8db"}
        else {background.color = "#4891d9"}
    }

    onHoveredChanged: {
        if (hovered) {background.color = "#74a8db"}
        else {background.color = "#4891d9"}
    }

    onClicked: {
        registerClicked(registerId)
    }

    Image {
        source: "../../../assets/warning.svg"
        width: rootObject.width / 6 / 8
        anchors.right: parent.right
        anchors.rightMargin: 5
        height: 25
        visible: alert
    }

    Button {
        anchors.left: parent.left

        background: Rectangle{
            color: "#4891d9"
            radius: 10
        }

        height: parent.height
        width: parent.height

        Image {
            id: pinButtonImage
            width: parent.width-13
            height: parent.height-13
            anchors.centerIn: parent
        }

        onPressed: background.color = "#a3bed0"
        onReleased: { background.color = "#4891d9"
            if (hovered) {background.color = "#74a8db"}
            else {background.color = "#4891d9"}
        }

        onHoveredChanged: {
            if (hovered) {
                background.color = "#74a8db"
                registerButtonBackground.color = "#4891d9"
            }
            else {
                background.color = "#4891d9"
                if (parent.hovered) {
                    registerButtonBackground.color = "#74a8db"
                }
            }
        }

        onClicked: {

            if (backend.findPinConfig("reg", registerId) !== -1) {
                backend.removeFromPinConfig("reg", registerId);
                pinButtonImage.source = "../../../assets/push-pin-fill.svg"
            }
            else {
                backend.addToPinConfig("reg", registerId);
                pinButtonImage.source = "../../../assets/push-pin-bold.svg"
            }

            createRegisterButtons(backend.returnGlobalModuleId())
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

}
