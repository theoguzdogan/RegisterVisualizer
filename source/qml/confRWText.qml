import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {
    property var configList: backend.getConfFileList()
    property var resetValue
    property var regAddr: backend.getRegAddr()
    property var currentValue: backend.grmonGet(regAddr)
    property var desiredValue: currentValue

    function checkCurrent(){
        currentValue = backend.fieldGet(regAddr)
        currentText.text = "Current Value:" + currentValue
    }

    function checkConfCurrent(){
        checkCurrent()
        var configValue = backend.getValueFromConfigFile()
        if (configValue === "-1"){
            configValue0.visible = false
            configValue1.visible = false
            configValue2.visible = true
        }
        else if (configValue === currentValue){
            configValue0.visible = true
            configValue1.visible = false
            configValue2.visible = false
        }
        else if (configValue !== currentValue){
            configValue0.visible = false
            configValue1.text = "Warning: value in the selected configuration is: " + configValue
            configValue1.visible = true
            configValue2.visible = false
        }
        return configValue
    }

    width: confColumn.width
    id: parentRectangle

    Component.onCompleted: {
        checkConfCurrent()
    }

    MessageDialog {
        id: invalidValueDialog
        text: "The input is empty, field value will remain unchanged."
    }

    TextField {
        id: valueTextField
        width: (rootObject.width / 2) - 20
        height: 35
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        placeholderText: "Enter HEX Value"
        text: backend.fieldGet(regAddr)
    }

    Row {
        id: valueButtonRow
        anchors.top: valueTextField.bottom
        anchors.right: parent.right
        anchors.margins: 6
        spacing: 6

        Column {
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: currentText
                anchors.right: parent.right
                text: "Current Value: " + currentValue
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 10
                color: "#FFFFFF"
            }
            Text {
                anchors.right: parent.right
                text: "Reset Value: " + resetValue
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 10
                color: "#FFFFFF"
            }
        }

        Button {
            id: setButton
            text: "Set"
            width: (parentRectangle.width - 36)/7
            height: 30

            palette.buttonText: "white"

            background: Rectangle {
                radius: 10
                gradient: Gradient {
                    GradientStop { position: 0.0; color: loadingScreen.visible ? "#BBE6E6" : (setButton.pressed ? "#BDDBBD" : (setButton.hovered ? "#D3E0E0" : "#BBE6E6")) }
                    GradientStop { position: 1.0; color: loadingScreen.visible ? "#008080" : (setButton.pressed ? "#00B3B3" : (setButton.hovered ? "#009999" : "#008080")) }
                }
            }

            onClicked: {
                desiredValue = valueTextField.text

                if (desiredValue === ""){
                    invalidValueDialog.open()
                }
                else {
                    backend.fieldSet(regAddr, desiredValue)
                    Promise.resolve().then(updateRegisterTextBox)
                }
                checkConfCurrent()

                createModuleButtons()
                createRegisterButtons(backend.returnGlobalModuleId())
                createFieldButtons(backend.returnGlobalRegId())
            }
        }

        Button {
            id: resetButton
            text: "Reset"
            width: (parentRectangle.width - 36)/7
            height: 30

            palette.buttonText: "white"

            background: Rectangle {
                radius: 10

                gradient: Gradient {
                    GradientStop { position: 0.0; color: loadingScreen.visible ? "#BBE6E6" : (resetButton.pressed ? "#BDDBBD" : (resetButton.hovered ? "#D3E0E0" : "#BBE6E6")) }
                    GradientStop { position: 1.0; color: loadingScreen.visible ? "#008080" : (resetButton.pressed ? "#00B3B3" : (resetButton.hovered ? "#009999" : "#008080")) }
                }
            }

            onClicked: {
//                desiredValue = resetValue
//                backend.fieldSet(regAddr, desiredValue)

//                checkConfCurrent()

                createModuleButtons()
                createRegisterButtons(backend.returnGlobalModuleId())
                createFieldButtons(backend.returnGlobalRegId())
//                valueTextField.text = currentValue
            }
        }
    }

    Row {
        id: configFileControls
        anchors.top: valueButtonRow.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.topMargin: 6
        spacing: 6

        Text {
            id: configValue0
            width: parentRectangle.width
            height: 33
            text: "Current value is same as saved on selected configuration."
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#00FF00"
            font.pointSize: 10
            wrapMode: Text.Wrap
        }
        Text {
            id: configValue1
            width: parentRectangle.width
            height: 33
            text: "Warning: value in the selected configuration is: "
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#FF0000"
            font.pointSize: 10
            wrapMode: Text.Wrap
        }
        Text {
            id: configValue2
            width: parentRectangle.width
            height: 33
            text: "Value not found in config."
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#FFFFFF"
            font.pointSize: 10
            wrapMode: Text.Wrap
        }

    }

    Text {
        id: generalDescriptionHeader
        anchors.top: configFileControls.bottom
        anchors.left: parent.left
        anchors.topMargin: 15
        anchors.leftMargin: 6
        anchors.bottomMargin: 4
        text: "General Description:"
        font.bold: true
        color: "#FFFFFF"
        font.pointSize: 10
        wrapMode: Text.Wrap
        width: parent.width - 10
    }

    Text {
        id: generalDescription
        anchors.top: generalDescriptionHeader.bottom
        anchors.left: parent.left
        anchors.topMargin: 4
        anchors.leftMargin: 10
        text: "Lorem ipsum dolor"
        color: "#FFFFFF"
        font.pointSize: 10
        wrapMode: Text.Wrap
        width: parent.width - 10
    }


}




