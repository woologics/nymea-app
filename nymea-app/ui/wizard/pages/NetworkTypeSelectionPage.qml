import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "qrc:/ui/wizard"
import "qrc:/ui/components"

WizardPageBase {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: app.margins

        Pane {
            Layout.fillWidth: true
            contentItem: Label {
                text: qsTr("Set up WiFi")
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.next(["RaspberryPiWiFiInstructionsPage", "BluetootSetupPage"])
                }
            }
        }
        Pane {
            Layout.fillWidth: true
            contentItem: Label {
                text: qsTr("Wired")
            }
        }
        Pane {
            Layout.fillWidth: true
            contentItem: Label {
                text: qsTr("Back")
            }
            MouseArea {
                anchors.fill: parent
                onClicked: root.back()
            }
        }
    }
}
