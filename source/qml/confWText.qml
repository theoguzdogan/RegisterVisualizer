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
    property var desiredValue

    function checkConf() {
        var configValue = backend.getValueFromConfigFile()
        if (configValue === "-1") {
            configValue1.visible = false
            configValue2.visible = true
        }
        else {
            configValue1.text = "Value in the selected configuration is: " + backend.getValueFromConfigFile()
            configValue2.visible = false
            configValue1.visible = true
        }
    }

    width: confColumn.width
    id: parentRectangle


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
    }

    Row {
        id: valueButtonRow
        anchors.top: valueTextField.bottom
        anchors.right: parent.right
        anchors.margins: 6
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Reset Value: " + resetValue
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 10
            color: "#FFFFFF"
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

            ToolTip.delay: 500
            ToolTip.visible: ((!loadingScreen.visible)&&(hovered))
            ToolTip.text: "Apply the selected value on the data word below (Not applied directly on target)."

            onClicked: {
                desiredValue = valueTextField.text

                if (desiredValue === ""){
                    invalidValueDialog.open()
                }
                else {
                    backend.fieldSet(regAddr, desiredValue);
                    Promise.resolve().then(updateRegisterTextBox)
                }

                checkConf()

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

            ToolTip.delay: 500
            ToolTip.visible: ((!loadingScreen.visible)&&(hovered))
            ToolTip.text: "Apply the reset value on the data word below (Not applied directly on target)."

            onClicked: {
                desiredValue = backend.getResetValue(backend.returnGlobalFieldId())
                backend.fieldSet(regAddr, desiredValue)
                Promise.resolve().then(updateRegisterTextBox)

                checkConf()
                createModuleButtons()
                createRegisterButtons(backend.returnGlobalModuleId())
                createFieldButtons(backend.returnGlobalRegId())
                valueTextField.text = desiredValue
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
            id: configValue1
            width: parentRectangle.width - configComboBox.width - 12
            height: 33
            text: "Value in the selected configuration is: " + backend.getValueFromConfigFile()
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#FFFFFF"
            font.pointSize: 10
            wrapMode: Text.Wrap
            visible: false
        }
        Text {
            id: configValue2
            width: parentRectangle.width - configComboBox.width - 12
            height: 33
            text: "Value not found in config."
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#FFFFFF"
            font.pointSize: 10
            wrapMode: Text.Wrap
            visible: false
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

    Text {
        id: warning
        anchors.top: generalDescription.bottom
        anchors.left: parent.left
        anchors.topMargin: 4
        anchors.leftMargin: 10
        text: "This is a write-only field! The last value sent by the UI, may differ from the real value."
        color: "#FF0000"
        font.pointSize: 10
        wrapMode: Text.Wrap
        width: parent.width - 10
    }
}
