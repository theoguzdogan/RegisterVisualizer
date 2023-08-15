import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    property string fieldId;
    property bool alert;

    signal fieldClicked(string fieldId);

    width: rootObject.width / 6

    background: Rectangle {
        id: fieldButtonBackground
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
        fieldClicked(fieldId)
    }

    Image {
        source: "../../../assets/warning.svg"
        width: 23
        anchors.right: parent.right
        anchors.rightMargin: 5
        height: 25
        visible: alert
    }

    Button {
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.verticalCenter: parent.verticalCenter

        background: Rectangle{
            color: "#4891d9"
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

        onPressed: background.color = "#a3bed0"
        onReleased: { background.color = "#4891d9"
            if (hovered) {background.color = "#74a8db"}
            else {background.color = "#4891d9"}
        }

        onHoveredChanged: {
            if (hovered) {
                background.color = "#74a8db"
                fieldButtonBackground.color = "#4891d9"
            }
            else {
                background.color = "#4891d9"
                if (parent.hovered) {
                    fieldButtonBackground.color = "#74a8db"
                }
            }
        }

        onClicked: {
            console.log("small but 2 pressed")
            if (backend.findPinConfig("field", fieldId) !== -1) {
                backend.removeFromPinConfig("field", fieldId);
                pinButtonImage.source = "../../../assets/push-pin-fill.svg"
            }
            else {
                backend.addToPinConfig("field", fieldId);
                pinButtonImage.source = "../../../assets/push-pin-bold.svg"
            }

            createFieldButtons(backend.returnGlobalRegId())
            createPinButtons()
        }

        Component.onCompleted: {
            if (backend.findPinConfig("field", fieldId) !== -1) {
                pinButtonImage.source = "../../../assets/push-pin-fill.svg"
            }
            else {
                pinButtonImage.source = "../../../assets/push-pin-bold.svg"
            }
        }
    }

    function changeBorderToSelectedState(){
        fieldButtonBackground.border.color = "#FFFFFF"
        fieldButtonBackground.border.width = 2
    }
    function changeBorderToNormalState(){
        fieldButtonBackground.border.width = 0
    }
}
