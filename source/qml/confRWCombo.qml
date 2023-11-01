import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {

    property var valueList
    property var resetValue

    property var regAddr
    property var currentValue: backend.fieldGet(regAddr)
    property var desiredValue: currentValue

    function checkCurrent(){
        currentValue = backend.fieldGet(regAddr)
        currentText.text = "Current Value:" + currentValue
    }

    function checkConfCurrent() {
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
    }

    width: confColumn.width
    id: parentRectangle

    Component.onCompleted: {
        regAddr = backend.getRegAddr()
        Promise.resolve().then(checkConfCurrent())
    }

    MessageDialog {
        id: invalidValueDialog
        text: "The input is empty, field value will remain unchanged."
    }



    ComboBox {
        id: valueComboBox
        width: (rootObject.width / 2) - 20
        height: 35
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        editable: true
        model: ListModel {
            id: comboContent
        }

        Component.onCompleted: {
            for (var i=0; i< valueList.length; i++){
                comboContent.append({text:valueList[i]})
            }
            valueComboBox.currentIndex = parseInt(backend.fieldGet(regAddr),16)
        }
    }

    Row {
        id: valueButtonRow
        anchors.top: valueComboBox.bottom
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

            ToolTip.delay: 500
            ToolTip.visible: ((!loadingScreen.visible)&&(hovered))
            ToolTip.text: "Apply the selected value on the data word below (Not applied directly on target)."

            onClicked: {
                desiredValue = valueComboBox.currentIndex

                if (desiredValue === -1){
                    invalidValueDialog.open()
                }
                else {
                    backend.fieldSet(regAddr, backend.returnHex(desiredValue))
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

            ToolTip.delay: 500
            ToolTip.visible: ((!loadingScreen.visible)&&(hovered))
            ToolTip.text: "Apply the reset value on the data word below (Not applied directly on target)."

            onClicked: {
                var resetValue = backend.getResetValue(backend.returnGlobalFieldId())
                desiredValue = parseInt(resetValue, 16)
                backend.fieldSet(regAddr, resetValue)
                Promise.resolve().then(updateRegisterTextBox)

                checkConfCurrent()
                createModuleButtons()
                createRegisterButtons(backend.returnGlobalModuleId())
                createFieldButtons(backend.returnGlobalRegId())
                valueComboBox.currentIndex = desiredValue
            }
        }


    }

    Row {
        id: configFileControls
        anchors.top: valueButtonRow.bottom
        anchors.right: parentRectangle.right
        anchors.left: parentRectangle.left
        anchors.topMargin: 6
        spacing: 6

        Text {
            id: configValue0
            width: parentRectangle.width
            height: 33
            text: "Current value is same as saved on selected configuration."
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#FCE130"
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
            color: "#FC8C14"
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




