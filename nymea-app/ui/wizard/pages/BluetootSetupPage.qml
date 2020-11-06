import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "qrc:/ui/wizard"
import "qrc:/ui/components"
import Nymea 1.0

WizardPageBase {
    id: root

    BluetoothDiscovery {
        id: bluetoothDiscovery
        discoveryEnabled: true
    }

    NetworkManagerController {
        id: networkManager
    }

    QtObject {
        id: d
        property string ssid
    }

    Connections {
        target: networkManager.manager
        onInitializedChanged: {
            if (networkManager.manager.initialized) {
                root.next(wifiSelectionPageComponent)
            } else {
                root.back()
                print("************************* oopsie")
//                pageStack.pop(root)
            }
        }

        onConnectedChanged: {
            if (!networkManager.manager.connected) {
                pageStack.pop(root)
            }
        }
        onCurrentConnectionChanged: {
            if (networkManager.manager.currentConnection && networkManager.manager.currentConnection.ssid === d.ssid) {
                print("Wizard: Connected to WiFi. Completing BT Setup part.")
                root.complete()
            }
        }
        onWirelessStatusChanged: {
            print("Wireless status changed:", networkManager.manager.networkStatus)
            if (networkManager.manager.wirelessStatus === WirelessSetupManager.WirelessStatusFailed) {
                wrongPasswordText.visible = true
                pageStack.pop(authenticationPage)
            }
        }
    }

    function connectDevice(btDeviceInfo) {
        networkManager.bluetoothDeviceInfo = btDeviceInfo
        networkManager.connectDevice();
        print("**** connecting")
        root.next(connectingPageComponent)
    }

    ListView {
        anchors.fill: parent

        model: bluetoothDiscovery.deviceInfos
        clip: true

        delegate: NymeaListItemDelegate {
            width: parent.width
            iconName: Qt.resolvedUrl("../../images/connections/bluetooth.svg")
            text: model.name
            subText: model.address

            onClicked: {
                root.connectDevice(bluetoothDiscovery.deviceInfos.get(index))
            }
        }
    }

    Component {
        id: connectingPageComponent
        WizardPageBase {
            id: connectingPage
            Label {
                anchors.centerIn: parent
                text: qsTr("Connecting...")
            }


            BusyIndicator {
                anchors.centerIn: parent
            }
        }
    }

    Component {
        id: wifiSelectionPageComponent
        WizardPageBase {
            id: wifiSelectionPage
            ListView {
                anchors.fill: parent

                model: WirelessAccessPointsProxy {
                    accessPoints: networkManager.manager.accessPoints
                }
                clip: true

                delegate: NymeaListItemDelegate {
                    width: parent.width
                    text: model.ssid !== "" ? model.ssid : qsTr("Hidden Network")
                    enabled: !networkManager.manager.working
                    subText: model.hostAddress

                    iconColor: model.selectedNetwork ? app.accentColor : "#808080"
                    iconName:  {
                        if (model.protected) {
                            if (model.signalStrength <= 25)
                                return  Qt.resolvedUrl("../../images/nm-signal-25-secure.svg")

                            if (model.signalStrength <= 50)
                                return  Qt.resolvedUrl("../../images/nm-signal-50-secure.svg")

                            if (model.signalStrength <= 75)
                                return  Qt.resolvedUrl("../../images/nm-signal-75-secure.svg")

                            if (model.signalStrength <= 100)
                                return  Qt.resolvedUrl("../../images/nm-signal-100-secure.svg")

                        } else {

                            if (model.signalStrength <= 25)
                                return  Qt.resolvedUrl("../../images/nm-signal-25.svg")

                            if (model.signalStrength <= 50)
                                return  Qt.resolvedUrl("../../images/nm-signal-50.svg")

                            if (model.signalStrength <= 75)
                                return  Qt.resolvedUrl("../../images/nm-signal-75.svg")

                            if (model.signalStrength <= 100)
                                return  Qt.resolvedUrl("../../images/nm-signal-100.svg")

                        }
                    }

                    onClicked: {
                        print("Connect to ", model.ssid, " --> ", model.macAddress)
                        if (model.selectedNetwork) {
                            pageStack.push(networkInformationPage, { ssid: model.ssid, macAddress: model.macAddress })
                        } else {
                            d.ssid = model.ssid
                            root.next(authenticationPageComponent)
//                            pageStack.push(authenticationPageComponent, { ssid: model.ssid, macAddress: model.macAddress })
                        }
                    }
                }
            }

        }
    }

    Component {
        id: authenticationPageComponent
        WizardPageBase {
            ColumnLayout {
                anchors { left: parent.left; right: parent.right; top: parent.top}
                PasswordTextField {
                    id: passwordTextField
                    signup: false
                    minPasswordLength: 8
                    requireLowerCaseLetter: false
                    requireUpperCaseLetter: false
                    requireSpecialChar: false
                    requireNumber: false
                }
                Button {
                    text: qsTr("OK")
                    onClicked: {
                        networkManager.manager.connectWirelessNetwork(d.ssid, passwordTextField.password)
                        root.next(connectingPageComponent)
                    }
                }
            }
        }
    }
}
