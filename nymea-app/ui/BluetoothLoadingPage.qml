import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2

import "components"
import Nymea 1.0


Page {
    id: root
    header: GuhHeader {
        text: qsTr("Establish bluetooth connection")
        onBackPressed: pageStack.pop()
    }

    property string name
    property string address

    NetworkManagerControler {
        id: networkManger
        name: root.name
        address: root.address

        Component.onCompleted: networkManger.connectDevice()
    }

    Connections {
        target: networkManger.manager
        onInitializedChanged: {
            if (networkManger.manager.initialized) {
                pageStack.push(Qt.resolvedUrl("WirelessControlerPage.qml"), { name: root.name, address: root.address, networkManger: networkManger } )
            } else {
                pageStack.pop()
            }
        }

        onConnectedChanged: {
            if (!networkManger.manager.connected) {
                pageStack.pop()
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: true
        }

        Label {
            id: workingMessage
            Layout.alignment: Qt.AlignHCenter
            text: networkManger.manager.statusText
        }

        Label {
            id: initializingMessage
            Layout.alignment: Qt.AlignHCenter
            text: networkManger.manager.initializing ? qsTr("Initialize services...") : ""
        }
    }
}