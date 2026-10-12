import QtQuick

Item {
    id: controlsRoot

    property bool showControls: (typeof config !== "undefined" && config.showTopLeftControls === "false") ? false : true
    property bool showAgeRating: (typeof config !== "undefined" && config.showAgeRating === "false") ? false : true
    property string textRepair: (typeof config !== "undefined" && config.textRepair) ? config.textRepair : "Sửa nhanh"
    property string textAuxiliary: (typeof config !== "undefined" && config.textAuxiliary) ? config.textAuxiliary : "5v5 offline"

    signal repairClicked()
    signal auxiliaryClicked()

    visible: showControls
    width: 140
    height: col.height

    Column {
        id: col
        spacing: 12
        anchors.left: parent.left
        anchors.top: parent.top

        // 1. Sửa nhanh (Quick Diagnostics)
        Item {
            id: repairBtn
            width: 80
            height: 64

            Rectangle {
                id: repairCircle
                width: 40
                height: 40
                radius: 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                color: repairArea.containsMouse ? Qt.rgba(0.15, 0.25, 0.45, 0.85) : Qt.rgba(0.08, 0.15, 0.30, 0.70)
                border.width: 1.5
                border.color: repairArea.containsMouse ? "#38bdf8" : Qt.rgba(0.38, 0.65, 0.95, 0.60)

                Image {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    source: "assets/icons/repair.svg"
                    fillMode: Image.PreserveAspectFit
                }

                scale: repairArea.pressed ? 0.92 : (repairArea.containsMouse ? 1.08 : 1.0)
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
            }

            Text {
                id: repairText
                text: controlsRoot.textRepair
                anchors.top: repairCircle.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 11
                font.bold: true
                color: repairArea.containsMouse ? "#ffffff" : "#cbd5e1"
            }

            MouseArea {
                id: repairArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: controlsRoot.repairClicked()
            }
        }

        // 2. 5v5 Offline (Auxiliary / Guest Launcher)
        Item {
            id: auxBtn
            width: 80
            height: 64

            Rectangle {
                id: auxSquare
                width: 40
                height: 40
                radius: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                color: auxArea.containsMouse ? Qt.rgba(0.15, 0.25, 0.45, 0.85) : Qt.rgba(0.08, 0.15, 0.30, 0.70)
                border.width: 1.5
                border.color: auxArea.containsMouse ? "#38bdf8" : Qt.rgba(0.38, 0.65, 0.95, 0.60)

                Image {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    source: "assets/icons/game_5v5.svg"
                    fillMode: Image.PreserveAspectFit
                }

                scale: auxArea.pressed ? 0.92 : (auxArea.containsMouse ? 1.08 : 1.0)
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
            }

            Text {
                id: auxText
                text: controlsRoot.textAuxiliary
                anchors.top: auxSquare.bottom
                anchors.topMargin: 4
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 11
                font.bold: true
                color: auxArea.containsMouse ? "#ffffff" : "#cbd5e1"
            }

            MouseArea {
                id: auxArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: controlsRoot.auxiliaryClicked()
            }
        }

        // 3. 16+ Age rating badge
        Item {
            id: badgeItem
            width: 120
            height: 52
            visible: controlsRoot.showAgeRating

            Image {
                anchors.fill: parent
                source: "assets/icons/badge_16.svg"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            opacity: 0.92
        }
    }
}

