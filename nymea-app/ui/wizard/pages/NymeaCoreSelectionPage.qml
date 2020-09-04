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
                text: qsTr("Set up on Raspberry Pi")
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.next(["RaspberryPiGetImagePage", "NetworkTypeSelectionPage"])
                }
            }
        }
        Pane {
            Layout.fillWidth: true
            contentItem: Label {
                text: qsTr("Manual installation")
            }
        }
        Pane {
            Layout.fillWidth: true
            contentItem: Label {
                text: qsTr("My %1 system is already connected.")
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    print("Wizard: Completing core selection page")
                    root.complete()
                }
            }
        }
    }
}
