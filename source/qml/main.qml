import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.folderlistmodel 2.1
import QtQuick.Dialogs 1.3

Window {
    property int columnGap: 120
    property string targetName: "STARKIT" //this is the variable for the header

    width: 1200
    height: 720
    minimumWidth: 1100
    minimumHeight: 650
    visible: true
//    color: "#27273a"

    title: qsTr("RegisterVisualiser")
    id: rootObject

    Rectangle
    {
        anchors.fill: parent
        gradient: Gradient
        {
            GradientStop { position: 0.000; color: "#52002D" }
            GradientStop { position: 0.600; color: "#00013D" }
            GradientStop { position: 1.000; color: "#00013D" }
        }
    }

    Component.onCompleted: {
        backend.setDefaultConfigId("default.yaml")
        Promise.resolve().then(refresh)
    }

    AbstractDialog {
            id: configFileDialog
            width: 300
            height: 100

            Rectangle {
                id: newConfigRectangle
                color: "#27273a"

                Text {
                    id: newConfigCaption
                    anchors.top: newConfigRectangle.top
                    anchors.left: newConfigRectangle.left
                    anchors.margins: 15
                    color: "#ffffff"
                    text: "Enter the name of the new configuration:"
                    font.pointSize: 10
                }

                Row {
                    id: newConfigRow
                    anchors.top: newConfigCaption.bottom
                    anchors.left: newConfigRectangle.left
                    anchors.right: newConfigRectangle.right
                    anchors.margins: 15
                    height: 35
                    spacing: 10

                    TextField {
                        id: newConfigTextField
                        width: 200
                        height: 35
                        placeholderText: "Config Name"

                        onTextChanged: {
                            var confFileList = backend.getConfFileList()
                            for (var i=0; i<confFileList.length; i++){
                                if (text === confFileList[i]){
                                    configFileDialog.height = 130
                                    newConfigWarning.visible = true
                                    break
                                }
                                else {
                                    configFileDialog.height = 100
                                    newConfigWarning.visible = false
                                }
                            }
                        }
                    }

                    Button {
                        id: configFileDialogButton
                        text:"OK"
                        width: 55
                        height: 35
                        background: Rectangle {
                            color: "#4891d9"
                            radius: 10
                        }

                        onClicked: {
                            backend.checkAndSaveAll(newConfigTextField.text)
                            configContent.clear()
                            var configList = backend.getConfFileList()
                            for (var it in configList){
                                configContent.append({text:configList[it]})
                            }
                            backend.setDefaultConfigId(newConfigTextField.text)
                            configComboBox.currentIndex = backend.returnGlobalConfigId()
                            newConfigTextField.clear()
                            configFileDialog.close()
                        }
                    }
                }


                Text {
                    id: newConfigWarning
                    anchors.left: newConfigRectangle.left
                    anchors.bottom: newConfigRectangle.bottom
                    anchors.margins: 15
                    color: "#ff0000"
                    text: "File already exists, content will be overwritten."
                    font.pointSize: 10
                    visible: false
                }

            }
    }


    Rectangle {
        id: confBar
        width: parent.width
        height: 65
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 20
        color: "transparent"

        Rectangle {
            id: logo
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 55
            color: "transparent"
            opacity: 0.6

            Image {
                id: logo_tai
                source: "../../../assets/tai_logo_white.svg"
            }
        }

        Rectangle {

            id: mainHeader
            anchors.left: logo.right
            anchors.verticalCenter: parent.verticalCenter
            width: headerText.width +16
            height: headerText.height +10
            color: "transparent"

            Text {
                color: "#ffffff"
                text: targetName + " Registers"
                font.pixelSize: 30
                font.family: "Segoe UI"
                id: headerText
                anchors.centerIn: parent
                opacity: 0.8
            }
        }

        Rectangle {
            anchors.right: configComboBox.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width : referenceConfHeader.width + configComboBox.width/2 + 20
            height : configComboBox.height
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                color: "#4d4d63"
                border.color: "#8f8fa8"
                opacity: 0.5
                radius: 10
            }

            Text {
                id: referenceConfHeader
                text: "Reference Configurations"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 11
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
            }
        }



        ComboBox {
            id: configComboBox
            editable: true
            anchors.right: refreshButton.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 200
            height: 35

            background: Rectangle {
                color: "#FFFFFF"
                radius: 10
                opacity: 0.5
            }

            model: ListModel {
                id: configContent

                Component.onCompleted: {
                    configComboBox.currentIndex = backend.returnGlobalConfigId()
                }

            }

            Component.onCompleted: {
                var configList = backend.getConfFileList()
                for (var it in configList){
                    configContent.append({text:configList[it]})
                }
            }

            onCurrentValueChanged: {
                backend.setConfFilePath(currentIndex)
                createModuleButtons()

                if(!registerPlaceHolder.visible){
                    createRegisterButtons(backend.returnGlobalModuleId())
                    if(!fieldPlaceHolder.visible){
                        createFieldButtons(backend.returnGlobalRegId())
                        if(!confPlaceHolder.visible){
                            createConfScreen(backend.returnGlobalFieldId())
                        }
                    }
                }
                createPinButtons()
            }
        }

        Button {
            id: refreshButton
            text: "Refresh"
            width: 90
            height: 30
            anchors.right: saveAllButton.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            palette.buttonText: "white"

            background: Rectangle {
                radius: 10
                gradient: Gradient {
                    GradientStop { position: 0.0; color: refreshButton.pressed ? "#BDDBBD" : (refreshButton.hovered ? "#A7C2A7" : "#A89F91") }
                    GradientStop { position: 1.0; color: refreshButton.pressed ? "#00B3B3" : (refreshButton.hovered ? "#009999" : "#008080") }
                }
            }

            onClicked: {
                refresh()
            }
        }

        Button {
            id: saveAllButton
            text: "Save All"
            width: 90
            height: 30
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            palette.buttonText: "white"

            background: Rectangle {
                radius: 10
                gradient: Gradient {
                    GradientStop { position: 0.0; color: saveAllButton.pressed ? "#BDDBBD" : (saveAllButton.hovered ? "#A7C2A7" : "#A89F91") }
                    GradientStop { position: 1.0; color: saveAllButton.pressed ? "#00B3B3" : (saveAllButton.hovered ? "#009999" : "#008080") }
                }

            }

            onClicked: {
                configFileDialog.open()
            }
        }
    }

    Row {
        id: topBar
        width: parent.width
        anchors.left: parent.left
        anchors.top: confBar.bottom
        anchors.topMargin: 15
        anchors.right: parent.right
        anchors.margins: 4
        spacing: 4

        Text {
            text: "Modules"
            width: parent.width / 6
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 11
            color: "#FFFFFF"
        }

        Text {
            text: "Registers"
            width: parent.width / 6
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 11
            color: "#FFFFFF"
        }

        Rectangle {
                    width: (parent.width / 6) + (parent.width / 2)
                    height: 20
                    color: "transparent"

                    Flickable {
                        id: tabFlick
                        width: parent.width
                        height: 20
                        clip: true

                        // Set the scroll direction to horizontal
                        contentWidth: registerTabRow.width
                        boundsBehavior: Flickable.StopAtBounds

                        // Define a row of buttons
                        Row {
                            id: registerTabRow
                            spacing: 1
                        }
                    }
                }
    }

    ScrollView {
        id: moduleScrollView
        anchors.left: parent.left
        anchors.bottom: pinBoard.top
        anchors.top: topBar.bottom
        anchors.leftMargin: 4
        anchors.bottomMargin: 4
        anchors.topMargin: 4
        width: rootObject.width / 6
        clip: true

        Column {
            id: moduleColumn
            anchors.centerIn: parent
            spacing: 2
        }
    }

    ScrollView {
        id: registerScrollView
        anchors.left: moduleScrollView.right
        anchors.bottom: pinBoard.top
        anchors.top: topBar.bottom
        anchors.leftMargin: 4
        anchors.bottomMargin: 4
        anchors.topMargin: 4
        width: rootObject.width / 6
        clip: true

        Column {
            id: registerColumn
            anchors.centerIn: parent
            spacing: 2
        }
    }

    Rectangle {
        id: selectedUnitViewer
        anchors.left: registerScrollView.right
        anchors.right: parent.right
        anchors.bottom: registerDataView.top
        anchors.margins: 4
        height: 40
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#4d4d63"
            border.color: "#8f8fa8"
            border.width: 1

            radius: 10
            opacity: 0.5
        }

        Rectangle {
            id: moduleUnit
            height: 40
            width: (parent.width-12)/3
            radius: 10
//            border.color: "white"
            color: "transparent"
            anchors.left: parent.left
            anchors.leftMargin: 6
            Text {
                id: moduleUnitHeader
                text: "Module:"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }
            Rectangle {
                id: moduleUnitIndicator
                height: 30
                anchors.left: moduleUnitHeader.right
                anchors.leftMargin: 6
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                radius: 10
                border.color: "#8f8fa8"
                color: "transparent"

                Rectangle {
                    id: moduleUnitIndicatorBackground
                    anchors.fill: parent
                    radius: 10
                    color: "#4d4d63"
                    opacity: 0.5
                }

                Text {
                    id: moduleUnitIndicatorText
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                    visible: moduleUnitIndicatorBackground.visible
                }
            }
        }
        Rectangle {
            id: registerUnit
            height: 40
            width: (parent.width-12)/3
            radius: 10
//            border.color: "white"
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                id: registerUnitHeader
                text: "Register:"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 6
            }
            Rectangle {
                id: registerUnitIndicator
                height: 30
                anchors.left: registerUnitHeader.right
                anchors.leftMargin: 6
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                radius: 10
                border.color: "#8f8fa8"
                color: "transparent"

                Rectangle {
                    id: registerUnitIndicatorBackground
                    anchors.fill: parent
                    radius: 10
                    color: "#4d4d63"
                    opacity: 0.5
                }

                Text {
                    id: registerUnitIndicatorText
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                    visible: registerUnitIndicatorBackground.visible
                }
            }
        }
        Rectangle {
            id: fieldUnit
            height: 40
            width: (parent.width-12)/3
            radius: 10
            color: "transparent"
            anchors.right: parent.right
            anchors.rightMargin: 6
            Text {
                id: fieldUnitHeader
                text: "Field:"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 6
            }
            Rectangle {
                id: fieldUnitIndicator
                height: 30
                anchors.left: fieldUnitHeader.right
                anchors.leftMargin: 6
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                radius: 10
                border.color: "#8f8fa8"
                color: "transparent"

                Rectangle {
                    id: fieldUnitIndicatorBackground
                    anchors.fill: parent
                    radius: 10
                    color: "#4d4d63"
                    opacity: 0.5
                }

                Text {
                    id: fieldUnitIndicatorText
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                    visible: fieldUnitIndicatorBackground.visible
                }
            }
        }
    }

    Rectangle {
        id: registerDataViewPlaceHolder
        anchors.left: registerScrollView.right
        anchors.right: parent.right
        anchors.bottom: pinBoard.top
        anchors.margins: 4
        height: 40
        color: "#4d4d63"
        radius: 10
        z: 1
        opacity: 0.5

        onVisibleChanged: {
            if (visible) {
                registerTextBox.clear()
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: true
        }
    }

    Rectangle {
        id: registerDataView
        anchors.left: registerScrollView.right
        anchors.right: parent.right
        anchors.bottom: pinBoard.top
        anchors.margins: 4
        height: 40
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#4d4d63"
            border.color: "#8f8fa8"
            border.width: 1
            radius: 10
            opacity: registerDataViewPlaceHolder.visible ? 0 : 0.5
        }

        Text {
            id: registerDataViewHeader
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 4

            width: 140
            color: "white"
            text: qsTr("Current Register Data:")
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 10
            horizontalAlignment: Text.AlignHCenter
        }

        TextField {
            id: registerTextBox
            anchors.left: registerDataViewHeader.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: sendButton.left
            anchors.margins: 5
            property var regAddr
            property var targetData
            color: (text === targetData) ? "black" : "red"
            background: Rectangle {
                color: "white"
                border.color: "#8f8fa8"
                opacity: 0.9
                radius: 10
            }

            ToolTip.delay: 500
//            ToolTip.timeout: 5000
            ToolTip.visible: (!registerDataViewPlaceHolder.visible) && hovered
            ToolTip.text: hexToBinary(text)

            onTextChanged: {
                if (!registerDataViewPlaceHolder.visible) {
                    if (text === ""){
                        text = backend.sshGet(regAddr)
                    }
                    Promise.resolve().then(()=>{backend.bufferSet(regAddr, text)})
                    if (!confPlaceHolder.visible) {
                        createConfScreen(backend.returnGlobalFieldId())
                    }
                }
            }

            function hexToBinary(hex) {
                    var binary = parseInt(hex, 16).toString(2);
                    if (binary !== "NaN" && binary.length <= 32) {
                        binary = ("0".repeat((32-(binary.length)))) + binary;
                    }
                    binary = "Bin: " + binary
                    return binary;
                }
        }

        Button {
            id: sendButton
            anchors.right: registerConfigSaveButton.left
            anchors.margins: 5
            anchors.verticalCenter: parent.verticalCenter
            text: "Send"
            width: 80
            height: parent.height-10

            palette.buttonText: "white"

            background: Rectangle {
                radius: 10

                gradient: Gradient {
                    GradientStop { position: 0.0; color: ((!registerDataViewPlaceHolder.visible) && sendButton.pressed) ? "#BDDBBD" : (((!registerDataViewPlaceHolder.visible)&&sendButton.hovered) ? "#A7C2A7" : "#A89F91") }
                    GradientStop { position: 1.0; color: ((!registerDataViewPlaceHolder.visible) && sendButton.pressed) ? "#00B3B3" : (((!registerDataViewPlaceHolder.visible)&&sendButton.hovered) ? "#009999" : "#008080") }
                }
            }

            onClicked: {
                if (!registerDataViewPlaceHolder.visible) {
                    console.log("RegisterValue sent.")
                    backend.sshSet(registerTextBox.regAddr, registerTextBox.text)
                    Promise.resolve().then(()=>{
                        refresh()
                        updateRegisterTextBox()
                        createPinButtons()
                    })
                    Promise.resolve().then(()=>{
                        if ((registerTextBox.text === registerTextBox.targetData)){
                        console.log("REGISTER WRITEMEM ERROR: check sshSet() function of backend or connection.")
                        }
                    })
                }
            }
        }

        Button {
            id: registerConfigSaveButton
            anchors.right: parent.right
            anchors.margins: 5
            anchors.verticalCenter: parent.verticalCenter
            text: "Override Config"
            width: 80
            height: parent.height-10

            palette.buttonText: "white"

            background: Rectangle {
                radius: 10

                gradient: Gradient {
                    GradientStop { position: 0.0; color: ((!registerDataViewPlaceHolder.visible) && registerConfigSaveButton.pressed) ? "#BDDBBD" : (((!registerDataViewPlaceHolder.visible)&&registerConfigSaveButton.hovered) ? "#A7C2A7" : "#A89F91") }
                    GradientStop { position: 1.0; color: ((!registerDataViewPlaceHolder.visible) && registerConfigSaveButton.pressed) ? "#00B3B3" : (((!registerDataViewPlaceHolder.visible)&&registerConfigSaveButton.hovered) ? "#009999" : "#008080") }
                }
            }

            onClicked: {
                if (!registerDataViewPlaceHolder.visible){
                    backend.saveRegConfig(registerTextBox.text)
                    Promise.resolve().then(()=>{
                        refresh()
                        updateRegisterTextBox()
                        createPinButtons()
                    })
                //saved config value check may be added
                }
            }
        }
    }


    ScrollView {
        id: fieldScrollView
        anchors.left: registerScrollView.right
        anchors.bottom: selectedUnitViewer.top
        anchors.top: topBar.bottom
        anchors.leftMargin: 4
        anchors.bottomMargin: 4
        anchors.topMargin: 4
        width: rootObject.width / 6
        clip: true

        Column {
            id: fieldColumn
            anchors.centerIn: parent
            spacing: 2
        }
    }



    Rectangle {
        id: registerPlaceHolder
        anchors.left: moduleScrollView.right
        anchors.bottom: pinBoard.top
        anchors.top: topBar.bottom
        anchors.leftMargin: 4
        anchors.bottomMargin: 4
        anchors.topMargin: 4
        width: rootObject.width / 6
        clip: true
        color: "#4d4d63"
        radius: 10
        border.color: "#8f8fa8"
        opacity: 0.5

        Text{
            text: "Please select a module to list its registers."
            horizontalAlignment: Text.AlignHCenter
            color: "#FFFFFF"
            font.pointSize: 10
            anchors.centerIn: parent
            wrapMode: Text.Wrap
            width: parent.width - 16

        }
    }

    Rectangle {
        id: fieldPlaceHolder
        anchors.left: registerScrollView.right
        anchors.bottom: selectedUnitViewer.top
        anchors.top: topBar.bottom
        anchors.leftMargin: 4
        anchors.bottomMargin: 4
        anchors.topMargin: 4
        width: rootObject.width / 6
        clip: true
        color: "#4d4d63"
        radius: 10
        border.color: "#8f8fa8"
        opacity: 0.5

        onVisibleChanged: {
            if (visible){
                registerDataViewPlaceHolder.visible = true
            }
            else {
                registerDataViewPlaceHolder.visible = false
            }
        }

        Text{
            text: "Please select a register to list its fields."
            horizontalAlignment: Text.AlignHCenter
            color: "#FFFFFF"
            font.pointSize: 10
            anchors.centerIn: parent
            wrapMode: Text.Wrap
            width: parent.width - 16

        }
    }

//confscreen
    ScrollView {
        id: confScrollView
        anchors.left: fieldScrollView.right
        anchors.bottom: selectedUnitViewer.top
        anchors.top: topBar.bottom
        anchors.leftMargin: 4
        anchors.bottomMargin: 4
        anchors.topMargin: 4
        width: (rootObject.width / 2) - 20
        clip: true

        Column {
            id: confColumn
            anchors.fill: parent
            spacing: 2
        }
    }

    Rectangle {
        id: confPlaceHolder
        anchors.left: fieldScrollView.right
        anchors.bottom: selectedUnitViewer.top
        anchors.top: topBar.bottom
        anchors.leftMargin: 4
        anchors.bottomMargin: 4
        anchors.topMargin: 4
        width: (rootObject.width / 2) - 20
        clip: true
        color: "#4d4d63"
        radius: 10
        border.color: "#8f8fa8"
        opacity: 0.5

        Text{
            text: "Please select a field to open configuration menu."
            horizontalAlignment: Text.AlignHCenter
            color: "#FFFFFF"
            font.pointSize: 10
            anchors.centerIn: parent
            wrapMode: Text.Wrap
            width: parent.width - 16

        }
    }

    Rectangle {
        id: pinBoard
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 4
        height: 73
        width: parent.width
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#4d4d63"
            border.color: "#8f8fa8"
            border.width: 1
            radius: 10
            opacity: 0.5
        }

        Rectangle {
            id: pinBoardHeader
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 120
            height: parent.height
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#4d4d63"
                border.color: "#8f8fa8"
                border.width: 1
                radius: 10
                opacity: 0.6
            }

            //TRIAL AREA
            Component.onCompleted: {
                createPinButtons()



            }
            //TRIAL AREA

            Text {
                color: "#ffffff"
                anchors.centerIn: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "Pin Board"
                font.pointSize: 12
            }
        }

        Flickable {
                id: flickablePinBoard
                width: parent.width
                height: parent.height
                anchors.left: pinBoardHeader.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 5
                anchors.leftMargin: 5
                anchors.rightMargin: 5

                contentWidth: column.width
                contentHeight: column.height
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Column {
                    id: column
                    spacing: 5
                    height: parent.height

                    Row {
                        spacing: 5
                        id: pinButtonRow0
                    }

                    Row {
                        spacing: 5
                        id: pinButtonRow1
                    }
                }

            }

        Rectangle {
            id: pinBoardPlaceHolder
            anchors.verticalCenter: pinBoard.verticalCenter
            anchors.horizontalCenter: flickablePinBoard.horizontalCenter
            width: flickablePinBoard.width-2
            height: pinBoard.height-2
            clip: true
            color: "#4d4d63"
            radius: 10

            Text{
                text: "Pinned buttons can be seen here."
                horizontalAlignment: Text.AlignHCenter
                color: "#FFFFFF"
                font.pointSize: 10
                anchors.centerIn: parent
                wrapMode: Text.Wrap


            }
        }
    }


    function refresh() {
        createPinButtons()
        createModuleButtons()
//        Promise.resolve().then(checkSelectedModule)
        if (!registerPlaceHolder.visible) {
            createRegisterButtons(backend.returnGlobalModuleId())
            if (!fieldPlaceHolder.visible) {
                createFieldButtons(backend.returnGlobalRegId())
                if (!confPlaceHolder.visible) {
                    createConfScreen(backend.returnGlobalFieldId())
                }
            }
        }

        checkSelectedRegisterTabAlias()
    }

    function createConfScreen(fieldId) {
        clearConf()
        var confType = backend.getConfType(fieldId);
        var isReadable = backend.getReadable(fieldId);
        var isWriteable = backend.getWriteable(fieldId);
        var resetValue = backend.getResetValue(fieldId);
        var currentValue = "0"//backend.sshGet(backend.getFieldAddr());

        var itemName
        var values

        switch (confType){
        case -1:
            itemName = "confR.qml"
            break;
        case 0:
            if (isReadable) {
                itemName = "confRWCombo.qml"
                values = backend.getValueDescriptions(fieldId)
            }
            else {
                itemName = "confWCombo.qml"
                values = backend.getValueDescriptions(fieldId)
            }
            break;
        case 1:
            if (isReadable) {
                itemName = "confRWText.qml"
            }
            else {
                itemName = "confWText.qml"
            }
            break;
        }

        var moduleItem = Qt.createComponent(itemName)
        .createObject(confColumn, {
                          "Layout.alignment": Qt.AlignHCenter | Qt.AlignVCenter,
                          "valueList": values,
                          "resetValue": resetValue,
                          "currentValue": currentValue

                      });
        confPlaceHolder.visible = false
    }

//confscreen
    function createModuleButtons() {
        clearModules()
        backend.checkAllConfigValues(-1)
        var fileList = backend.getFileList()
        for(var i = 0; i < fileList.length; i++) {
            var name = fileList[i].split(".")[0]
            var moduleItem = Qt.createComponent("module.qml")
            .createObject(moduleColumn, {
                              "moduleId": i,
                              "text": name,
                              "Layout.alignment": Qt.AlignHCenter | Qt.AlignVCenter,
                              "alert": backend.checkAllConfigValues(0, name),
                          });
            moduleItem.moduleClicked.connect(moduleButtonClicked)
        }
        Promise.resolve().then(checkSelectedModule)
    }

    function moduleButtonClicked(moduleId) {
        backend.setGlobalRegId(-1)
        backend.setGlobalFieldId(-1)
        clearFields()
        clearConf()
        createRegisterButtons(moduleId)
        checkSelectedRegisterTabAlias()
        checkSelectedModule()
    }

    function checkSelectedModule() {
        for (var i=0; i<moduleColumn.children.length; i++){
            moduleColumn.children[i].changeBorderToNormalState();
        }
        var moduleId = backend.returnGlobalModuleId()
        Promise.resolve().then(() => {
            if (moduleId === -1){
                moduleUnitIndicatorBackground.visible = false
            }
            else {
                moduleColumn.children[moduleId].changeBorderToSelectedState();
                moduleUnitIndicatorText.text = backend.getFileList()[moduleId].split(".")[0]
                moduleUnitIndicatorBackground.visible = true

            }
        })
        Promise.resolve().then(checkSelectedRegister)
        Promise.resolve().then(checkSelectedField)
    }
    //MODULE(FILE) BUTTONS END

    //REGISTER BUTTONS START
    function createRegisterButtons(moduleId) {
        clearRegisters()
        backend.checkAllConfigValues(-1, "")
        backend.setFilePath(moduleId)
        for(var i = 0; i < backend.getRegisterList().length; i++) {
            var name = backend.getRegisterList()[i]
            var registerItem = Qt.createComponent("register.qml")
            .createObject(registerColumn, {
                              "registerId": i,
                              "text": name,
                              "Layout.alignment": Qt.AlignHCenter | Qt.AlignVCenter,
                              "alert": backend.checkAllConfigValues(1, (backend.getFileList()[backend.returnGlobalModuleId()].split(".")[0]+"."+name)),
                          });
            registerItem.registerClicked.connect(registerButtonClicked)
        }
        registerPlaceHolder.visible = false
        Promise.resolve().then(checkSelectedRegister)
    }

    function registerButtonClicked(registerId) {
        backend.setGlobalFieldId(-1)
        clearConf()
        createFieldButtons(registerId)
        createRegisterTabAlias(registerId)
        updateRegisterTextBox()
        checkSelectedRegister()
    }

    function updateRegisterTextBox(registerId = backend.returnGlobalRegId()) {
        registerTextBox.regAddr = backend.getRegAddr()
        var isReadonly = !backend.getRegWriteable(registerId)

        if (isReadonly){
            registerTextBox.targetData = backend.sshGet(registerTextBox.regAddr)
            registerTextBox.text = registerTextBox.targetData
            registerTextBox.readOnly = true
            sendButton.enabled = false
            registerConfigSaveButton.enabled = false
        } else {
            var bufferData = backend.checkBuffer(registerTextBox.regAddr)
            Promise.resolve().then(()=>{
            registerTextBox.targetData = backend.sshGet(registerTextBox.regAddr)
            })
            Promise.resolve().then(()=>{
                if (bufferData === "-1") {
                    registerTextBox.text = registerTextBox.targetData
                }
                else {
                    registerTextBox.text = bufferData
                }
            })
            registerTextBox.readOnly = false
            sendButton.enabled = true
            registerConfigSaveButton.enabled = true
        }
    }

    function createRegisterTabAlias(registerId) {
        var name = backend.getRegisterList()[registerId]
        var moduleId = backend.returnGlobalModuleId()

        var duplicateAlert = false

        for (var i=0; i<registerTabRow.children.length; i++) {
            if(parseInt(registerTabRow.children[i].moduleId) === moduleId && registerTabRow.children[i].registerId === registerId){
                duplicateAlert = true
            }
        }

        if (!duplicateAlert) {
            var registerItem = Qt.createComponent("registerTab.qml")
            .createObject(registerTabRow, {
                              "registerId": registerId,
                              "moduleId": backend.returnGlobalModuleId(),
                              "text": name,
                              "Layout.alignment": Qt.AlignHCenter | Qt.AlignVCenter,
                              "alert": backend.checkAllConfigValues(1, (backend.getFileList()[backend.returnGlobalModuleId()].split(".")[0]+"."+name)),
                          });
        }
        refresh()
    }

    function destroyRegisterTabAlias(moduleId, registerId) {
        var destroyedId

        for (var i=0; i<registerTabRow.children.length; i++) {
            if(registerTabRow.children[i].moduleId === moduleId && registerTabRow.children[i].registerId === registerId){
                registerTabRow.children[i].destroy()
                destroyedId = i
            }
        }
        refresh()

        if (backend.returnGlobalModuleId()===parseInt(moduleId) && parseInt(backend.returnGlobalRegId())===parseInt(registerId)){
            backend.setGlobalRegId(-1)
            clearFields()
            clearConf()
        }

        else {
            //SELECT CLOSEST TAB !!!!!!!!!!!!!!!!!!!!!!!!
        }
    }

    function checkSelectedRegisterTabAlias() {
        var selectedRegisterTab;
        for(var i=0; i<registerTabRow.children.length; i++){
            if(parseInt(registerTabRow.children[i].moduleId) === backend.returnGlobalModuleId() && registerTabRow.children[i].registerId === backend.returnGlobalRegId()) {
                registerTabRow.children[i].opacity = 1
                selectedRegisterTab = i
            }
            else {
                registerTabRow.children[i].opacity = 0.5
            }
        }
        return i
    }

    function checkSelectedRegister() {
        for (var i=0; i<registerColumn.children.length; i++){
            registerColumn.children[i].changeBorderToNormalState();
        }
        var regId = backend.returnGlobalRegId()
        Promise.resolve().then(() => {
            if (parseInt(regId) === -1){
                registerUnitIndicatorBackground.visible = false
            }
            else {
                registerColumn.children[regId].changeBorderToSelectedState();
                registerUnitIndicatorText.text = backend.getRegisterList()[regId].split(".")[0]
                registerUnitIndicatorBackground.visible = true
            }
        })
    }



    //REGISTER BUTTONS END

    //FIELD BUTTONS END
    function createFieldButtons(registerId) {
        clearFields()
        backend.checkAllConfigValues(-1, "")
        for(var i = 0; i < backend.getFieldList(registerId).length; i++) {
            var name = backend.getFieldList(registerId)[i]
            var fieldItem = Qt.createComponent("field.qml")
            .createObject(fieldColumn, {
                              "fieldId": i,
                              "text": name,
                              "Layout.alignment": Qt.AlignHCenter | Qt.AlignVCenter,
                              "alert": backend.checkAllConfigValues(2, (backend.getFileList()[backend.returnGlobalModuleId()].split(".")[0]+"."+backend.getRegisterList()[backend.returnGlobalRegId()]+"."+name)),
                          });
            fieldItem.fieldClicked.connect(fieldButtonClicked)
        }
        fieldPlaceHolder.visible = false
        Promise.resolve().then(checkSelectedField)
    }

    function fieldButtonClicked(fieldId) {
        clearConf()
        createConfScreen(fieldId)
        checkSelectedField()
    }

    function checkSelectedField() {
        for (var i=0; i<fieldColumn.children.length; i++){
            fieldColumn.children[i].changeBorderToNormalState();
        }
        var fieldId = backend.returnGlobalFieldId()
        Promise.resolve().then(() => {
            if (parseInt(fieldId) === -1){
                fieldUnitIndicatorBackground.visible = false
            }
            else {
               fieldColumn.children[fieldId].changeBorderToSelectedState();
               fieldUnitIndicatorText.text = backend.getFieldList(backend.returnGlobalRegId())[fieldId].split(".")[0]
               fieldUnitIndicatorBackground.visible = true
            }
        })

    }
    //FIELD BUTTONS END

    //PIN BUTTONS START
    function createPinButtons() {
        clearPinBoard()
        var pinButtonCount = backend.returnPinConfig("init")
        if (pinButtonCount === 0) {
            pinBoardPlaceHolder.visible = true
        }
        else {
            pinBoardPlaceHolder.visible = false
        }

        for (var i=0; i<pinButtonCount; i++) {
            var pinConfig = backend.returnPinConfig(i)
            var pinType = parseInt(pinConfig[0])


            if (i%2 == 0){
                switch (pinType) {
                    case 1:
                        var pinItem00 = Qt.createComponent("pinButton.qml")
                        .createObject(pinButtonRow0, {
                                        "pinId": i,
                                        "text": pinConfig[pinType],
                                        "type": pinType,
                                        "module": pinConfig[1],
                                        "alert": backend.checkAllConfigValues(0, pinConfig[1])
                                      });
                        break;
                    case 2:
                        var pinItem01 = Qt.createComponent("pinButton.qml")
                        .createObject(pinButtonRow0, {
                                        "pinId": i,
                                        "text": pinConfig[pinType],
                                        "type": pinType,
                                        "module": pinConfig[1],
                                        "reg": pinConfig[2],
                                        "alert": backend.checkAllConfigValues(1, (pinConfig[1]+'.'+pinConfig[2]))
                                      });
                        break;
                    case 3:
                        var pinItem02 = Qt.createComponent("pinButton.qml")
                        .createObject(pinButtonRow0, {
                                        "pinId": i,
                                        "text": pinConfig[pinType],
                                        "type": pinType,
                                        "module": pinConfig[1],
                                        "reg": pinConfig[2],
                                        "field": pinConfig[3],
                                        "alert": backend.checkAllConfigValues(2, (pinConfig[1]+'.'+pinConfig[2]+'.'+pinConfig[3]))
                                      });
                        break;
                }

            }
            else {
                switch (pinType) {
                    case 1:
                        var pinItem10 = Qt.createComponent("pinButton.qml")
                        .createObject(pinButtonRow1, {
                                        "pinId": i,
                                        "text": pinConfig[pinType],
                                        "type": pinType,
                                        "module": pinConfig[1],
                                        "alert": backend.checkAllConfigValues(0, pinConfig[1].split('\r')[0])
                                      });
                        break;
                    case 2:
                        var pinItem11 = Qt.createComponent("pinButton.qml")
                        .createObject(pinButtonRow1, {
                                        "pinId": i,
                                        "text": pinConfig[pinType],
                                        "type": pinType,
                                        "module": pinConfig[1],
                                        "reg": pinConfig[2],
                                        "alert": backend.checkAllConfigValues(1, (pinConfig[1]+'.'+pinConfig[2].split('\r')[0]))
                                      });
                        break;
                    case 3:
                        var pinItem12 = Qt.createComponent("pinButton.qml")
                        .createObject(pinButtonRow1, {
                                        "pinId": i,
                                        "text": pinConfig[pinType],
                                        "type": pinType,
                                        "module": pinConfig[1],
                                        "reg": pinConfig[2],
                                        "field": pinConfig[3],
                                        "alert": backend.checkAllConfigValues(2, (pinConfig[1]+'.'+pinConfig[2]+'.'+pinConfig[3].split('\r')[0]))
                                      });
                        break;
                }
            }


        }

    }

    //PIN BUTTONS END

    function clearModules() {
        for (var i = 0 ; i < moduleColumn.children.length; i++) {
            moduleColumn.children[i].destroy()
        }
    }

    function clearRegisters() {
        registerPlaceHolder.visible = true
        for (var i = 0 ; i < registerColumn.children.length; i++) {
            registerColumn.children[i].destroy()
        }
    }

    function clearFields() {
        fieldPlaceHolder.visible = true
        for (var i = 0 ; i < fieldColumn.children.length; i++) {
            fieldColumn.children[i].destroy()
        }
    }

    function clearConf() {
        confPlaceHolder.visible = true
        backend.resetConfigId()
        for (var i = 0 ; i < confColumn.children.length; i++) {
            confColumn.children[i].destroy()
        }
    }

    function clearPinBoard(){
        for (var i = 0 ; i < pinButtonRow0.children.length; i++) {
            pinButtonRow0.children[i].destroy()
        }
        for (i = 0 ; i < pinButtonRow1.children.length; i++) {
            pinButtonRow1.children[i].destroy()
        }
    }

    Connections { target: backend }
}
