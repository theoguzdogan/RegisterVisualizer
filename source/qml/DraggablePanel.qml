import QtQuick 2.15

Item {
    property var target: parent

    id: draggablePanelRoot
    anchors.fill: parent

    MouseArea {
        property variant clickPos: "1,1"
        anchors.fill: draggablePanelRoot

        onPressed: { clickPos  = Qt.point(mouse.x, mouse.y) }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
            target.x += delta.x;
            target.y += delta.y;
        }
    }
}
