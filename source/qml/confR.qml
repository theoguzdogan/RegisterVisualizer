import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import QtQuick.Timeline 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
//    border.color: "black"
    width: confColumn.width

    property var regAddr: backend.getRegAddr()
    property var currentValue
    property var resetValue

    Component.onCompleted: {
        currentValue = backend.fieldGetFromTarget(regAddr)
    }

    Row {
        id: valueButtonRow
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 6
        spacing: 6

        Column {
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: currentValueText
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
    }

    Text {
        id: generalDescriptionHeader
        anchors.top: valueButtonRow.bottom
        anchors.left: parent.left
        anchors.topMargin: 8
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
