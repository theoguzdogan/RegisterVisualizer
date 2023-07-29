import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


Button {
    property int type
    property string module
    property string reg
    property string regId
    property string field
    property string pinId
    property bool alert

    width: rootObject.width / 6

    background: Rectangle {
        id: pinButtonBackground
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
        switch (type) {
        case 1:
            moduleFunct()
            break;

        case 2:
            moduleFunct()
            registerFunct()
            break;

        case 3:
            moduleFunct()
            registerFunct()
            fieldFunct()
            break;
        }
    }

    Image {
        source: "../../../assets/warning.svg"
        width: rootObject.width / 6 / 8
        anchors.right: parent.right
        anchors.rightMargin: 5
        height: 25
        visible: alert
    }

    ToolTip.delay: 500
    ToolTip.timeout: 5000
    ToolTip.visible: hovered

    Component.onCompleted: {
        switch (type) {
        case 1:
            ToolTip.text = qsTr(module)
            break;
        case 2:
            ToolTip.text = qsTr(module+" > "+reg)
            break;
        case 3:
            ToolTip.text = qsTr(module+" > "+reg+" > "+field)
            break;
        }
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
            source: "../../../assets/push-pin-fill.svg"
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
                pinButtonBackground.color = "#4891d9"
            }
            else {
                background.color = "#4891d9"
                if (parent.hovered) {
                    pinButtonBackground.color = "#74a8db"
                }
            }
        }

        onClicked: {
            console.log("pin small but 2 pressed")
            backend.removeFromPinConfig(pinId);
            refresh()
        }
    }

    function moduleFunct(){
        var fileList = backend.getFileList()
        for (var i = 0; i < fileList.length; i++) {
            if (fileList[i].split(".")[0].split("\r")[0] === module.split("\r")[0]) {
                moduleButtonClicked(i)
                break;
            }
        }

    }

    function registerFunct(){
        var regList = backend.getRegisterList()
        for (var i = 0; i < regList.length; i++) {
            if (regList[i] === reg.split("\r")[0]) {
                regId = i.toString();
                registerButtonClicked(i.toString())
                break;
            }
        }
    }

    function fieldFunct(){
        var fieldList = backend.getFieldList(regId)
        for (var i = 0; i < fieldList.length; i++) {
            if (fieldList[i] === field.split("\r")[0]) {
                fieldButtonClicked(i)
                break;
            }
        }
    }
}
