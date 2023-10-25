import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.folderlistmodel 2.1
import QtQuick.Dialogs 1.3
import "./"

Window {
    property string targetName: "SCOC3" //this is the variable for the header

    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal

    width: 1250
    height: 750
    minimumWidth: 1122 + scriptSelectionText.width
    minimumHeight: 650
    visible: true
//    color: "#27273a"
//    opacity: 0.5

    color: "transparent"

    title: qsTr("RegisterVisualizer")
    id: rootObject

    Rectangle {
        id: loadingScreen
        anchors.fill: parent
        color: "transparent"
        radius:10
        z:2
        visible: false

        Rectangle {
            anchors.fill: parent
            radius:10
            opacity: 0.5
            color: "#000000"
        }

        MouseArea {
            anchors.fill: parent
            enabled: true
        }

        Image {
            id: loadingIcon
            anchors.centerIn: parent
            source: "../../../assets/loading.svg"

            NumberAnimation on rotation {
                from: 0
                to: 360
                running: loadingScreen.visible;
                loops: Animation.Infinite
                duration: 1100;
            }
        }

        Text {
            id: loadingText
            color: "#FFFFFF"
            anchors.centerIn: parent
            text: "Loading..."
            font.bold: true
            font.pointSize: 15
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#27273a"
        opacity: 0.96
    }

    Rectangle {
        id: titleBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 35
        color: "transparent"
        radius: 10
        z: 3

        MouseArea {
            anchors.fill: parent
            onDoubleClicked: {
                if(maximizeButton.isMaximized){
                    rootObject.showNormal()
                    Promise.resolve().then(()=>{maximizeButton.isMaximized = false})
                } else{
                    rootObject.showMaximized()
                    Promise.resolve().then(()=>{maximizeButton.isMaximized = true})
                }
            }

            property variant clickPos: "1,1"
            property bool isMinimizedByDragging: false

            onPressed: {
                clickPos  = Qt.point(mouse.x,mouse.y)
                if(maximizeButton.isMaximized){
                    rootObject.showNormal()
                    Promise.resolve().then(()=>{maximizeButton.isMaximized = false; isMinimizedByDragging = true})
                }
            }
            onReleased: {
                if(rootObject.y<=0 && !isMinimizedByDragging){
                    if(!maximizeButton.isMaximized){
                        rootObject.showMaximized()
                        Promise.resolve().then(()=>{maximizeButton.isMaximized = true})
                    }
                } else {
                    isMinimizedByDragging = false
                }
            }

            onPositionChanged: {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                rootObject.x += delta.x;
                rootObject.y += delta.y;
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#292929"
            radius: 10
        }
        Rectangle {
            anchors.top: parent.verticalCenter
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: "#292929"
        }

        Text {
            id: appTitle
            anchors.centerIn: parent
            text: "RegisterVisualizer"
            color: "#FFFFFF"
        }

        Button {
            id: minimizeButton
            height: 25
            width: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: maximizeButton.left
            anchors.margins: 8
            background: Rectangle {
                color: minimizeButton.pressed ? "#7A7A7A" : (minimizeButton.hovered ? "#525252":"transparent")
                radius: 15
            }
            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                text: "—"
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 6
                color: "#FFFFFF"
            }
            onClicked: rootObject.showMinimized()
        }

        Button {
            id: maximizeButton
            property bool isMaximized: false
            height: 25
            width: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: closeButton.left
            anchors.margins: 8
            background: Rectangle {
                color: maximizeButton.pressed ? "#7A7A7A" : (maximizeButton.hovered ? "#525252":"transparent")
                radius: 15
            }
            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 4
                text: maximizeButton.isMaximized ? "⧉" : "□"
                font.pointSize: maximizeButton.isMaximized ? 11 : 9
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "#FFFFFF"
            }
            onClicked: {
                if(isMaximized){
                    rootObject.showNormal()
                    Promise.resolve().then(()=>{isMaximized = false})
                } else{
                    rootObject.showMaximized()
                    Promise.resolve().then(()=>{isMaximized = true})
                }
            }
        }

        Button {
            id: closeButton
            height: 25
            width: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.margins: 6
            background: Rectangle {
                color: closeButton.pressed ? "#FF5145" : (closeButton.hovered ? "#DE473C":"transparent")
                radius: 15
            }
            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                text: "×"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 15
                color: "#FFFFFF"
            }
            onClicked: {
                backend.emptyBuffer()
                backend.stopScript()
                Promise.resolve().then(Qt.quit)
            }
        }
    }

    MouseArea {
        id: resizeLeft
        width: 12
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.leftMargin: 0
        anchors.topMargin: 10
        cursorShape: Qt.SizeHorCursor
        z: 3

        DragHandler {
            target: null
            onActiveChanged: if (active) { rootObject.startSystemResize(Qt.LeftEdge) }
        }
    }

    MouseArea {
        id: resizeRight
        width: 12
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: 0
        anchors.bottomMargin: 25
        anchors.leftMargin: 6
        anchors.topMargin: 10
        cursorShape: Qt.SizeHorCursor
        z: 3

        DragHandler {
            target: null
            onActiveChanged: if (active) { rootObject.startSystemResize(Qt.RightEdge) }
        }
    }

    MouseArea {
        id: resizeBottom
        height: 12
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        cursorShape: Qt.SizeVerCursor
        anchors.rightMargin: 25
        anchors.leftMargin: 15
        anchors.bottomMargin: 0
        z: 3

        DragHandler{
            target: null
            onActiveChanged: if (active) { rootObject.startSystemResize(Qt.BottomEdge) }
        }
    }

    MouseArea {
        id: resizeApp
        x: 1176
        y: 697
        width: 25
        height: 25
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.rightMargin: 0
        cursorShape: Qt.SizeFDiagCursor
        z: 3

        DragHandler{
            target: null
            onActiveChanged: if (active) { rootObject.startSystemResize(Qt.RightEdge | Qt.BottomEdge) }
        }
    }

    Component.onCompleted: {
        backend.setDefaultConfigId("default.yaml")
        Promise.resolve().then(refresh)
        backend.emptyBuffer()
        scriptDialog.open()
    }

    MessageDialog {
        id: scriptDialogWarning
        width: 350
        height: 100
        Rectangle {
            anchors.fill: parent
            color: "#27273a"
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                width: parent.width-20
                wrapMode: Text.WordWrap
                text: "Please select a script to run and click OK."
                color: "#FFFFFF"
            }

            Button {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                text:"OK"
                palette.buttonText: "white"
                width: 55
                height: 35
                background: Rectangle {
//                        color: "#4891d9"
                    radius: 10
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: (scriptDialogButton.pressed ? "#BDDBBD" : (scriptDialogButton.hovered ? "#D3E0E0" : "#BBE6E6")) }
                        GradientStop { position: 1.0; color: (scriptDialogButton.pressed ? "#00B3B3" : (scriptDialogButton.hovered ? "#009999" : "#008080")) }
                    }
                }
                onClicked: scriptDialogWarning.accepted()
            }
        }
        onAccepted: scriptDialog.open()
        onRejected: scriptDialog.open()

    }


    AbstractDialog {
        id: scriptDialog
        width: 430
        height: 330

        onRejected: {
            if(!backend.returnScriptState()){
                scriptDialogWarning.open()
            }
        }

        onVisibilityChanged: {
            if(visible){
                width = 430
                height = 330
                startScriptAnimation()
            } else {
                stopScriptAnimation()
            }
        }

        Rectangle {
            id: scriptSelectRectangle
            color: "#27273a"

            Rectangle {
                id: scriptSelectBackground
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1
                height: 150
                opacity: 0.9
                z:1

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#27273a" }
                    GradientStop { position: 0.4; color: "#27273a" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            Text {
                id: scriptSelectionCaption
                anchors.top: scriptSelectRectangle.top
                anchors.left: scriptSelectionRow.left
                anchors.topMargin: 15
                color: "#ffffff"
                text: "Select GRMON script:"
                font.pointSize: 10
                z:1
            }

            Row {
                id: scriptSelectionRow
                anchors.top: scriptSelectionCaption.bottom
                anchors.topMargin: 15
//                anchors.left: scriptSelectRectangle.left
//                anchors.right: scriptSelectRectangle.right
//                anchors.margins: 15
                anchors.horizontalCenter: parent.horizontalCenter
                height: 35
                spacing: 10
                z:1

                ComboBox {
                    id: scriptComboBox
                    editable: true
                    width: 200
                    height: 35

                    background: Rectangle {
                        color: "#FFFFFF"
                        opacity: 0.5
                    }


                    model: ListModel {
                        id: scriptComboBoxContent
                    }

                    Component.onCompleted: {
                        var grmonScriptList = backend.getGrmonScriptList()
                        for (var it in grmonScriptList){
                            scriptComboBoxContent.append({text:grmonScriptList[it]})
                        }
                    }
                }

                Text{
                    text: scriptComboBox.currentText === "Select an option" ? "" : scriptComboBox.currentText
                    color: "#000000"
                    font.pixelSize: 12
                    visible: scriptComboBox.currentText === "Select an option"

                }

                Button {
                    id: scriptDialogButton
                    text:"OK"
                    palette.buttonText: "white"
                    width: 55
                    height: 35
                    background: Rectangle {
                        radius: 10
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: (scriptDialogButton.pressed ? "#BDDBBD" : (scriptDialogButton.hovered ? "#D3E0E0" : "#BBE6E6")) }
                            GradientStop { position: 1.0; color: (scriptDialogButton.pressed ? "#00B3B3" : (scriptDialogButton.hovered ? "#009999" : "#008080")) }
                        }
                    }
                    onClicked: {
                        if (scriptComboBox.currentText !== "Select an option") {
                            if(backend.returnScriptState()){backend.stopScript()}
                            if(backend.launchScript(scriptComboBox.currentText)){
                                scriptSelection.scriptName = scriptComboBox.currentText
                                scriptDialog.close()
                            }else{
                                console.log("Failed to start the script.")
                            }
                        }
                        Promise.resolve().then(()=>{
                            if (backend.returnScriptState()){
                                scriptDialogWarning.close()
                            }
                        })


                    }
                }
            }

            Rectangle {
                id: movingScene
                width: parent.width
                height: parent.height - 100
                color: "transparent"
//                border.color: "black"
                anchors.bottom: parent.bottom

                Image {
                    id: movingSceneImage
                    anchors.fill: parent
                    source: "../../../assets/starryBackground.jpeg"
                    z: -1
                }

                Rectangle {
                    id: movingObject
                    width: 50
                    height: 50
                    color: "transparent"
                    property bool run: false

                    Image {
                        id: movingObjectImage
                        anchors.fill: parent
                        property bool sourceSwitch: true
                        source: sourceSwitch ? "../../../assets/tai_logo_white.svg" : "../../../assets/tai_logo_outline.svg"
                    }

                    NumberAnimation on x {
                        id: xAnimation
                        running: false
                        from: 0
                        to: (movingScene.width-movingObject.width)
                        property var speedFactor: generateRandomSpeedFactor()
                        duration: (Math.abs(to-from))/speedFactor
                    }

                    onXChanged: {
                        if (run) {
                            if (x === (parent.width-width)){
                                xAnimation.from = (parent.width-width)
                                xAnimation.to = 0
                                xAnimation.speedFactor = generateRandomSpeedFactor()
                                movingObjectImage.sourceSwitch = (!movingObjectImage.sourceSwitch)
                                Promise.resolve().then(xAnimation.restart)
                            }   else if (x == 0) {
                                xAnimation.from = 0
                                xAnimation.to = (parent.width-width)
                                xAnimation.speedFactor = generateRandomSpeedFactor()
                                movingObjectImage.sourceSwitch = (!movingObjectImage.sourceSwitch)
                                Promise.resolve().then(xAnimation.restart)
                            }
                        }
                    }

                    NumberAnimation on y {
                        id: yAnimation
                        running: false
                        from: 0
                        to: (movingScene.height-movingObject.height)
                        property var speedFactor: generateRandomSpeedFactor()
                        duration: (Math.abs(to-from))/speedFactor
                    }

                    onYChanged: {
                        if (run) {
                            if (y === (parent.height-height)){
                                yAnimation.from = (parent.height-height)
                                yAnimation.to = 0
                                yAnimation.speedFactor = generateRandomSpeedFactor()
                                movingObjectImage.sourceSwitch = (!movingObjectImage.sourceSwitch)
                                Promise.resolve().then(yAnimation.restart)
                            }   else if (y == 0) {
                                yAnimation.from = 0
                                yAnimation.to = (parent.height-height)
                                yAnimation.speedFactor = generateRandomSpeedFactor()
                                movingObjectImage.sourceSwitch = (!movingObjectImage.sourceSwitch)
                                Promise.resolve().then(yAnimation.restart)
                            }
                        }
                    }
                }
            }



        }


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
        anchors.top: titleBar.bottom
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

            MouseArea {
                anchors.fill: parent
                property int counter: 0;
                onClicked: {
                    counter++
                    if(counter==3){
                        uselessAnimation.running = true
                        counter=0
                    }
                }
            }

            Image {
                id: logo_tai
                source: "../../../assets/tai_logo_color.svg"
                NumberAnimation on rotation {
                    id: uselessAnimation
                    from: 0; to: 360; running: false;
                    loops: 1; duration: 1100;
                }
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
            }
        }


        Rectangle {
            id: scriptSelection
            radius: 10
            color: "transparent"
            width: 167+scriptSelectionText.width
            height: 35
            anchors.right: referenceConfHeaderContainer.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10

            property string scriptName: "-"

            Rectangle {
                anchors.fill: parent
                color: "#4d4d63"
                border.color: "#8f8fa8"
                opacity: 0.5
                radius: 10
            }

            Text {
                id: scriptSelectionHeader
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                text: "GRMON Script:"
                color: "#FFFFFF"
            }

            Text {
                id: scriptSelectionText
                anchors.left: scriptSelectionHeader.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                text: parent.scriptName
                color: "#FFFFFF"
            }

            Button {
                id: scriptSelectButton
                anchors.left: scriptSelectionText.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                height: parent.height
                width: parent.height
                background: Rectangle {
                    radius: 10
//                    color: "transparent"
//                    border.color: "#8f8fa8"
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: loadingScreen.visible ? "#BBE6E6" : (scriptSelectButton.pressed ? "#BDDBBD" : (scriptSelectButton.hovered ? "#D3E0E0" : "#BBE6E6")) }
                        GradientStop { position: 1.0; color: loadingScreen.visible ? "#008080" : (scriptSelectButton.pressed ? "#00B3B3" : (scriptSelectButton.hovered ? "#009999" : "#008080")) }
                    }
                }

                Image {
                    id: scriptButtonImage
                    anchors.fill: parent
                    anchors.margins: 7
                    source: ((!loadingScreen.visible) && parent.hovered) ? "../../assets/file-select_hovered.svg" : "../../assets/file-select.svg"
                }

                onClicked: {
                    scriptDialog.open()
                }
            }
        }

        Rectangle {
            id: referenceConfHeaderContainer
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
            anchors.right: scanConfButton.left
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
            }
        }

        Button {
            id: scanConfButton
            text: "Scan"
            width: 90
            height: 30
            anchors.right: refreshButton.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 8

            palette.buttonText: "white"

            background: Rectangle {
                radius: 10
                gradient: Gradient {
                    GradientStop { position: 0.0; color: loadingScreen.visible ? "#BBE6E6" : (scanConfButton.pressed ? "#BDDBBD" : (scanConfButton.hovered ? "#D3E0E0" : "#BBE6E6")) }
                    GradientStop { position: 1.0; color: loadingScreen.visible ? "#008080" : (scanConfButton.pressed ? "#00B3B3" : (scanConfButton.hovered ? "#009999" : "#008080")) }
                }
            }

            onClicked: {
                scanConf()
            }
        }

        Button {
            id: refreshButton
            text: "Refresh"
            width: 90
            height: 30
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            palette.buttonText: "white"

            background: Rectangle {
                radius: 10
                gradient: Gradient {
                    GradientStop { position: 0.0; color: loadingScreen.visible ? "#BBE6E6" : (refreshButton.pressed ? "#BDDBBD" : (refreshButton.hovered ? "#D3E0E0" : "#BBE6E6")) }
                    GradientStop { position: 1.0; color: loadingScreen.visible ? "#008080" : (refreshButton.pressed ? "#00B3B3" : (refreshButton.hovered ? "#009999" : "#008080")) }
                }
            }

            onClicked: {
                refresh()
            }
        }

//        Button {
//            id: saveAllButton
//            text: "Save All"
//            width: 90
//            height: 30
//            anchors.right: parent.right
//            anchors.verticalCenter: parent.verticalCenter

//            palette.buttonText: "white"

//            background: Rectangle {
//                radius: 10
//                gradient: Gradient {
//                    GradientStop { position: 0.0; color: loadingScreen.visible ? "#BBE6E6" : (saveAllButton.pressed ? "#BDDBBD" : (saveAllButton.hovered ? "#D3E0E0" : "#BBE6E6")) }
//                    GradientStop { position: 1.0; color: loadingScreen.visible ? "#008080" : (saveAllButton.pressed ? "#00B3B3" : (saveAllButton.hovered ? "#009999" : "#008080")) }
//                }

//            }

//            onClicked: {
//                configFileDialog.open()
//            }
//        }
    }

    Row {
        id: topBar
        width: parent.width/3
        anchors.left: parent.left
        anchors.top: confBar.bottom
        anchors.topMargin: 15
        anchors.leftMargin: 4
        spacing: 4

        Text {
            text: "Modules"
            width: (parent.width) / 2
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 11
            color: "#FFFFFF"
        }

        Text {
            text: "Registers"
            width: (parent.width) / 2
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 11
            color: "#FFFFFF"
        }
    }

    Rectangle {
        id: registerTabContainer
        height: 20
        color: "transparent"
        anchors.left: topBar.right
        anchors.right: tabContainer.right
        anchors.top: confBar.bottom
        anchors.topMargin: 15
        anchors.rightMargin: 10
        anchors.leftMargin: 18

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

        Rectangle {
            anchors.right: tabFlick.right
            anchors.top: tabFlick.top
            anchors.bottom: tabFlick.bottom
            width: 20
            opacity: 0.9
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#27273a" }
            }
            visible: !tabFlick.atXEnd
        }

        Rectangle {
            anchors.left: tabFlick.left
            anchors.top: tabFlick.top
            anchors.bottomMargin: 5
            width: 20
            opacity: 0.9
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#27273a" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            visible: !tabFlick.atXBeginning
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
        id: tabContainer
        anchors.left: registerScrollView.right
        anchors.top: registerTabContainer.bottom
        anchors.right: parent.right
        anchors.bottom: selectedUnitViewer.top
        anchors.rightMargin: 4
        anchors.leftMargin: 4
        anchors.bottomMargin: 4
        radius: 10
        color: "#4d4d63"
        opacity: 0.5
        border.color: "#8f8fa8"
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
            cursorShape: Qt.ForbiddenCursor
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
            anchors.right: baseSelection.left
            anchors.margins: 5
            property var regAddr
            property var targetData
            color: baseSelection.isHex ? ((text === targetData) ? "black" : "red") : ((binaryToHex(text) === targetData) ? "black" : "red")
            background: Rectangle {
                color: "white"
                border.color: "#8f8fa8"
                opacity: 0.9
                radius: 10
            }

            ToolTip.delay: 500
            ToolTip.visible: ((!registerDataViewPlaceHolder.visible) && ((!loadingScreen.visible)&&(hovered)))
            ToolTip.text: "Register Address: " + regAddr

            onTextChanged: {
                if (!registerDataViewPlaceHolder.visible) {
                    if (baseSelection.isHex){
                        if (text === ""){
                            text = backend.sshGet(regAddr)
                        }
                        Promise.resolve().then(()=>{backend.bufferSet(regAddr, text)})

                    }else{
                        if (text === ""){
                            text = hexToBinary(backend.sshGet(regAddr))
                        }
                        Promise.resolve().then(()=>{backend.bufferSet(regAddr, binaryToHex(text))})
                    }
                    if (!confPlaceHolder.visible) {
                        createConfScreen(backend.returnGlobalFieldId())
                    }
                }
            }
        }

        Rectangle {
            id: baseSelection
            anchors.right: sendButton.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 5
            width: 50
            height: 20
            color: "transparent"

            property bool isHex: true

            Rectangle {
                anchors.left: hexRadioButton.left
                anchors.top: hexRadioButton.top
                anchors.topMargin: 1
                anchors.bottom: binRadioButton.bottom
                anchors.bottomMargin: 1
                width: binRadioButton.height - 2
                radius: binRadioButton.height - 2

                gradient: Gradient
                {
                    GradientStop { position: 0.000;  color: baseSelection.isHex ? "#81bffc" : "#2358a3"}
                    GradientStop { position: 1.000; color: baseSelection.isHex ? "#2358a3" : "#81bffc"}
                }

            }



            Button {
                id: hexRadioButton
                property bool selected : parent.isHex

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.height+1
                    anchors.right: parent.right
                    color: "#FFFFFF"
                    text: "Hex"
                    font.bold: baseSelection.isHex
                    verticalAlignment: Text.AlignVCenter
                }

                height: parent.height/2
                background: Rectangle{
                    color: "transparent"
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.height - 6
                    height: parent.height - 6
                    radius: parent.height - 6
                    color: "#FFFFFF"
                    visible: parent.selected
                }

                onClicked: {
                    parent.isHex = !parent.isHex
                    Promise.resolve().then(changeBase)
                }
            }

            Button {
                id: binRadioButton
                property bool selected : !parent.isHex

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.height+1
                    anchors.right: parent.right
                    color: "#FFFFFF"
                    text: "Bin"
                    font.bold: !baseSelection.isHex
                    verticalAlignment: Text.AlignVCenter
                }

                height: parent.height/2
                background: Rectangle{
                    color: "transparent"
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.height - 6
                    height: parent.height - 6
                    radius: parent.height - 6
                    color: "#FFFFFF"
                    visible: parent.selected
                }

                onClicked: {
                    parent.isHex = !parent.isHex
                    Promise.resolve().then(changeBase)
                }
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
                    GradientStop { position: 0.0; color: loadingScreen.visible ? "#BBE6E6" : ((!registerDataViewPlaceHolder.visible) && sendButton.pressed) ? "#BDDBBD" : (((!registerDataViewPlaceHolder.visible)&&sendButton.hovered) ? "#D3E0E0" : "#BBE6E6") }
                    GradientStop { position: 1.0; color: loadingScreen.visible ? "#008080" : ((!registerDataViewPlaceHolder.visible) && sendButton.pressed) ? "#00B3B3" : (((!registerDataViewPlaceHolder.visible)&&sendButton.hovered) ? "#009999" : "#008080") }
                }
            }

            onClicked: {
                if (!registerDataViewPlaceHolder.visible) {
                    if (baseSelection.isHex){
                        backend.sshSet(registerTextBox.regAddr, registerTextBox.text)
                    } else {
                        backend.sshSet(registerTextBox.regAddr, binaryToHex(registerTextBox.text))
                    }
                    Promise.resolve().then(()=>{
                        if(backend.returnScriptState()){
                           updateRegisterTextBox()
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
                    GradientStop { position: 0.0; color: loadingScreen.visible ? "#BBE6E6" : ((!registerDataViewPlaceHolder.visible) && registerConfigSaveButton.pressed) ? "#BDDBBD" : (((!registerDataViewPlaceHolder.visible)&&registerConfigSaveButton.hovered) ? "#D3E0E0" : "#BBE6E6") }
                    GradientStop { position: 1.0; color: loadingScreen.visible ? "#008080" : ((!registerDataViewPlaceHolder.visible) && registerConfigSaveButton.pressed) ? "#00B3B3" : (((!registerDataViewPlaceHolder.visible)&&registerConfigSaveButton.hovered) ? "#009999" : "#008080") }
                }
            }

            onClicked: {
                if (!registerDataViewPlaceHolder.visible){
                    if (baseSelection.isHex) {
                        backend.saveRegConfig(registerTextBox.text)
                    } else {
                        backend.saveRegConfig(binaryToHex(registerTextBox.text))
                    }
                }
            }
        }
    }

    Text {
        id: fieldScrollViewHeader
        anchors.left: tabContainer.left
        anchors.top: tabContainer.top
        anchors.leftMargin: 4
        anchors.topMargin: 4
        text: "Fields"
        width: fieldScrollView.width
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 11
        color: "#FFFFFF"
        visible: !fieldPlaceHolder.visible
    }


    ScrollView {
        id: fieldScrollView
        anchors.left: tabContainer.left
        anchors.bottom: tabContainer.bottom
        anchors.top: fieldScrollViewHeader.bottom
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
        anchors.left: tabContainer.left
        anchors.bottom: tabContainer.bottom
        anchors.top: tabContainer.top
        anchors.margins: 4
        width: rootObject.width / 6
        clip: true
        color: "transparent"
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
        anchors.bottom: tabContainer.bottom
        anchors.top: fieldScrollView.top
        anchors.right: tabContainer.right
        anchors.rightMargin: 6
        anchors.leftMargin: 6
        anchors.bottomMargin: 6
//        width: (rootObject.width / 2) - 30
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
        anchors.right: tabContainer.right
        anchors.bottom: tabContainer.bottom
        anchors.top: tabContainer.top
        anchors.margins: 4
        clip: true
        color: "transparent"
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

            Component.onCompleted: {
                if(backend.returnScriptState()){
                   createPinButtons()
                }
            }

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

//            MouseArea {
//                anchors.fill: parent
//                cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.ArrowCursor
//            }

        }

        Rectangle {
            anchors.right: flickablePinBoard.right
            anchors.top: flickablePinBoard.top
            anchors.bottom: flickablePinBoard.bottom
            anchors.bottomMargin: 5
            width: 25
            opacity: 0.9
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#404052" }
            }
            visible: !flickablePinBoard.atXEnd
        }

        Rectangle {
            anchors.left: flickablePinBoard.left
            anchors.top: flickablePinBoard.top
            anchors.bottom: flickablePinBoard.bottom
            anchors.bottomMargin: 5
            width: 25
            opacity: 0.9
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#404052" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            visible: !flickablePinBoard.atXBeginning
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

        Promise.resolve().then(checkSelectedModule)
        if (!registerPlaceHolder.visible) {
            createRegisterButtons(backend.returnGlobalModuleId())
            if (!fieldPlaceHolder.visible) {
                createFieldButtons(backend.returnGlobalRegId())
                if (!confPlaceHolder.visible) {
                    createConfScreen(backend.returnGlobalFieldId())
                }
            }
        }
        if(!registerDataViewPlaceHolder.visible){
            updateRegisterTextBox()
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
        var fileList = backend.getFileList()
        for(var i = 0; i < fileList.length; i++) {
            var name = fileList[i].split(".")[0]
            var moduleItem = Qt.createComponent("module.qml")
            .createObject(moduleColumn, {
                              "moduleId": i,
                              "text": name,
                              "Layout.alignment": Qt.AlignHCenter | Qt.AlignVCenter,
                              "alert": backend.returnConfigState() ? backend.checkAllConfigValues(0, name) : 0
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
        backend.setFilePath(moduleId)
        for(var i = 0; i < backend.getRegisterList().length; i++) {
            var name = backend.getRegisterList()[i]
            var registerItem = Qt.createComponent("register.qml")
            .createObject(registerColumn, {
                              "registerId": i,
                              "text": name,
                              "Layout.alignment": Qt.AlignHCenter | Qt.AlignVCenter,
                              "alert": backend.returnConfigState() ? backend.checkAllConfigValues(1, (backend.getFileList()[backend.returnGlobalModuleId()].split(".")[0]+"."+name)) : 0
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
//        updateRegisterTextBox()
        checkSelectedRegister()
    }

    function updateRegisterTextBox(registerId = backend.returnGlobalRegId()) {
        registerTextBox.regAddr = backend.getRegAddr()
        var isReadonly = !backend.getRegWriteable(registerId)

        if (isReadonly){
            registerTextBox.targetData = backend.sshGet(registerTextBox.regAddr)
            registerTextBox.text = baseSelection.isHex ? (registerTextBox.targetData) : hexToBinary(registerTextBox.targetData)
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
                    registerTextBox.text = baseSelection.isHex ? (registerTextBox.targetData) : hexToBinary(registerTextBox.targetData)
                }
                else {
                    registerTextBox.text = baseSelection.isHex ? (bufferData) : hexToBinary(bufferData)
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
                              "Layout.alignment": Qt.AlignHCenter | Qt.AlignVCenter
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

        if (backend.returnGlobalModuleId()===parseInt(moduleId) && parseInt(backend.returnGlobalRegId())===parseInt(registerId)){
            clearFields()
            clearConf()
            Promise.resolve().then(()=>{
                if (registerTabRow.children.length>0) {
                    if (destroyedId===0){
                        moduleButtonClicked(registerTabRow.children[0].moduleId)
                        Promise.resolve().then(()=>{registerButtonClicked(registerTabRow.children[0].registerId)})
                    } else if (destroyedId>0) {
                        moduleButtonClicked(registerTabRow.children[destroyedId-1].moduleId)
                        Promise.resolve().then(()=>{registerButtonClicked(registerTabRow.children[destroyedId-1].registerId)})
                    }
                } else if (registerTabRow.children.length===0) {
                    Promise.resolve().then(()=>{
                        backend.setGlobalRegId(-1)
                        clearRegisters()
                        backend.setGlobalModuleId(-1)
                        registerTextBox.clear()
                        refresh()
                    })
                }
            })
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
        for(var i = 0; i < backend.getFieldList(registerId).length; i++) {
            var name = backend.getFieldList(registerId)[i]
            var fieldItem = Qt.createComponent("field.qml")
            .createObject(fieldColumn, {
                              "fieldId": i,
                              "text": name,
                              "Layout.alignment": Qt.AlignHCenter | Qt.AlignVCenter,
                              "alert": backend.returnConfigState() ? backend.checkAllConfigValues(2, (backend.getFileList()[backend.returnGlobalModuleId()].split(".")[0]+"."+backend.getRegisterList()[backend.returnGlobalRegId()]+"."+name)) : 0
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
                                        "alert": backend.returnConfigState() ? backend.checkAllConfigValues(0, pinConfig[1]) : 0
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
                                        "alert": backend.returnConfigState() ? backend.checkAllConfigValues(1, (pinConfig[1]+'.'+pinConfig[2])) : 0
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
                                        "alert": backend.returnConfigState() ? backend.checkAllConfigValues(2, (pinConfig[1]+'.'+pinConfig[2]+'.'+pinConfig[3])) : 0
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
                                        "alert": backend.returnConfigState() ? backend.checkAllConfigValues(0, pinConfig[1].split('\r')[0]) : 0
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
                                        "alert": backend.returnConfigState() ? backend.checkAllConfigValues(1, (pinConfig[1]+'.'+pinConfig[2].split('\r')[0])) : 0
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
                                        "alert": backend.returnConfigState() ? backend.checkAllConfigValues(2, (pinConfig[1]+'.'+pinConfig[2]+'.'+pinConfig[3].split('\r')[0])) : 0
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

    function scanConf(){
        if(backend.returnScriptState()){
            backend.checkAllConfigValues(-1)
        } else {
            console.log("Script process is not running.")
        }
        Promise.resolve().then(refresh)
    }

    function hexToBinary(hex) {
        var binary = parseInt(hex, 16).toString(2);
        if (binary !== "NaN" && binary.length <= 32) {
            binary = ("0".repeat((32-(binary.length)))) + binary;
        }
        return binary;
    }

    function binaryToHex(binary) {
        // Remove "Bin: " prefix if present
        binary = binary.replace("Bin: ", "");

        // Ensure the binary string has a multiple of 4 characters
        while (binary.length % 4 !== 0) {
            binary = "0" + binary;
        }

        var hex = parseInt(binary, 2).toString(16).toUpperCase();
        return "0x"+hex;
    }

    function changeBase(){
        registerTextBox.text = baseSelection.isHex ? binaryToHex(registerTextBox.text) : hexToBinary(registerTextBox.text)
    }

    function startScriptAnimation() {
        movingObject.run = true
        movingScene.width = 430
        movingScene.height = 330
        xAnimation.from = 0
        xAnimation.to = (movingScene.width-movingObject.width)
        yAnimation.from = 0
        yAnimation.to = (movingScene.height-movingObject.height)
        Promise.resolve().then(()=>{
            xAnimation.start()
            yAnimation.start()
        })
    }

    function stopScriptAnimation() {
        movingObject.run = false
        Promise.resolve().then(()=>{
           xAnimation.stop()
           yAnimation.stop()
               Promise.resolve().then(()=>{
                  movingObject.x = 0
                  movingObject.y = 0
           })
        })
    }

    function generateRandomSpeedFactor() {
        return parseFloat((Math.random() * 0.1 + 0.1).toFixed(2));
    }

    Connections {
        target: backend
        function onConsoleReady(){
            console.log("loading end")
            loadingScreen.visible = false;
        }
        function onConsoleLoading(){
            console.log("loading start")
            loadingScreen.visible = true;
        }
    }
}
