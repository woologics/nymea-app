/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    property Device device: null
    readonly property DeviceClass deviceClass: device.deviceClass

    readonly property Device thing: device

    property bool showLogsButton: true
    property bool showDetailsButton: true
    property bool showBrowserButton: true
    property bool popStackOnBackButton: true

    default property alias data: contentItem.data

    signal backPressed()

    header: NymeaHeader {
        text: device.name
        onBackPressed: {
            root.backPressed();
            if (root.popStackOnBackButton) {
                pageStack.pop()
            }
        }

        HeaderButton {
            imageSource: "../images/folder-symbolic.svg"
            visible: root.deviceClass.browsable && root.showBrowserButton
            onClicked: {
                pageStack.push(Qt.resolvedUrl("DeviceBrowserPage.qml"), {device: root.device})
            }
        }

        HeaderButton {
            imageSource: "../images/navigation-menu.svg"
            onClicked: thingMenu.open();
        }
    }

    TagsProxyModel {
        id: favoritesProxy
        tags: engine.tagsManager.tags
        filterDeviceId: root.device.id
        filterTagId: "favorites"
    }

    AutoSizeMenu {
        id: thingMenu
        x: parent.width - width

        Component.onCompleted: {
            thingMenu.addItem(menuEntryComponent.createObject(thingMenu, {text: qsTr("Magic"), iconSource: "../images/magic.svg", functionName: "openDeviceMagicPage"}))

            if (root.showDetailsButton) {
                thingMenu.addItem(menuEntryComponent.createObject(thingMenu, {text: qsTr("Details"), iconSource: "../images/info.svg", functionName: "openGenericDevicePage"}))
            }
            thingMenu.addItem(menuEntryComponent.createObject(thingMenu, {text: qsTr("Settings"), iconSource: "../images/configure.svg", functionName: "openThingSettingsPage"}))
            if (root.showLogsButton) {
                thingMenu.addItem(menuEntryComponent.createObject(thingMenu, {text: qsTr("Logs"), iconSource: "../images/logs.svg", functionName: "openDeviceLogPage"}))
            }

            if (engine.jsonRpcClient.ensureServerVersion(1.6)) {
                thingMenu.addItem(menuEntryComponent.createObject(thingMenu,
                    {
                        text: Qt.binding(function() { return favoritesProxy.count === 0 ? qsTr("Mark as favorite") : qsTr("Remove from favorites")}),
                        iconSource: Qt.binding(function() { return favoritesProxy.count === 0 ? "../images/starred.svg" : "../images/non-starred.svg"}),
                        functionName: "toggleFavorite"
                    }))

                thingMenu.addItem(menuEntryComponent.createObject(thingMenu,
                    {
                        text: qsTr("Grouping"),
                        iconSource: "../images/view-grid-symbolic.svg",
                        functionName: "addToGroup"
                    }))
            }
        }
        function openDeviceMagicPage() {
            pageStack.push(Qt.resolvedUrl("../magic/DeviceRulesPage.qml"), {device: root.device})
        }
        function openGenericDevicePage() {
            pageStack.push(Qt.resolvedUrl("GenericDevicePage.qml"), {device: root.device})
        }
        function toggleFavorite() {
            if (favoritesProxy.count === 0) {
                engine.tagsManager.tagDevice(root.device.id, "favorites", 100000)
            } else {
                engine.tagsManager.untagDevice(root.device.id, "favorites")
            }
        }
        function addToGroup() {
            var dialog = addToGroupDialog.createObject(root)
            dialog.open();
        }

        function openThingSettingsPage() {
            pageStack.push(Qt.resolvedUrl("../thingconfiguration/ConfigureThingPage.qml"), {device: root.device})
        }

        function openDeviceLogPage() {
            pageStack.push(Qt.resolvedUrl("DeviceLogPage.qml"), {device: root.device });
        }

        Component {
            id: menuEntryComponent
            IconMenuItem {
                width: parent.width
                property string functionName: ""
                onTriggered: thingMenu[functionName]()
            }
        }

        Connections {
            target: engine.deviceManager.devices
            onThingRemoved:{
                if (device == root.device) {
                    print("Device destroyed")
                    pageStack.pop()
                }
            }
        }

        Component {
            id: addToGroupDialog
            MeaDialog {
                title: qsTr("Groups for %1").arg(root.device.name)
                headerIcon: "../images/view-grid-symbolic.svg"
                // NOTE: If CloseOnPressOutside is active (default) it will break the QtVirtualKeyboard
                // https://bugreports.qt.io/browse/QTBUG-56918
                closePolicy: Popup.CloseOnEscape

                RowLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    spacing: app.margins
                    TextField {
                        id: newGroupdTextField
                        Layout.fillWidth: true
                        placeholderText: qsTr("New group")
                    }
                    Button {
                        text: qsTr("OK")
                        enabled: newGroupdTextField.displayText.length > 0 && !groupTags.containsId("group-" + newGroupdTextField.displayText)
                        onClicked: {
                            engine.tagsManager.tagDevice(root.device.id, "group-" + newGroupdTextField.text, 1000)
                            newGroupdTextField.text = ""
                        }
                    }
                }


                ListView {
                    Layout.fillWidth: true
                    height: 200
                    clip: true
                    ScrollIndicator.vertical: ScrollIndicator {}

                    model: TagListModel {
                        id: groupTags
                        tagsProxy: TagsProxyModel {
                            tags: engine.tagsManager.tags
                            filterTagId: "group-.*"
                        }
                    }

                    delegate: CheckDelegate {
                        width: parent.width
                        text: model.tagId.substring(6)
                        checked: innerProxy.count > 0
                        onClicked: {
                            if (innerProxy.count == 0) {
                                engine.tagsManager.tagDevice(root.device.id, model.tagId, 1000)
                            } else {
                                engine.tagsManager.untagDevice(root.device.id, model.tagId, model.value)
                            }
                        }

                        DevicesProxy {
                            id: innerProxy
                            engine: _engine
                            filterTagId: model.tagId
                            filterDeviceId: root.device.id
                        }
                    }
                }
            }

        }
    }

    Rectangle {
        id: infoPane
        visible: setupInProgress || setupFailure || batteryState !== null || (connectedState !== null && connectedState.value === false)
        height: visible ? contentRow.implicitHeight : 0
        anchors { left: parent.left; top: parent.top; right: parent.right }
        property bool setupInProgress: device.setupStatus == Device.DeviceSetupStatusInProgress
        property bool setupFailure: device.setupStatus == Device.DeviceSetupStatusFailed
        property var batteryState: deviceClass.interfaces.indexOf("battery") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("batteryLevel").id) : null
        property var batteryCriticalState: deviceClass.interfaces.indexOf("battery") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("batteryCritical").id) : null
        property var connectedState: deviceClass.interfaces.indexOf("connectable") >= 0 ? device.states.getState(deviceClass.stateTypes.findByName("connected").id) : null
        property bool alertState: setupFailure ||
                                  (connectedState !== null && connectedState.value === false) ||
                                  (batteryCriticalState !== null && batteryCriticalState.value === true)
        color: alertState ? "red" : "transparent"
        z: 1000

        RowLayout {
            id: contentRow
            anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: app.margins; rightMargin: app.margins }
            Item {
                Layout.fillWidth: true
                height: app.iconSize
            }

            Label {
                text: infoPane.setupInProgress ?
                          qsTr("Thing is being set up...")
                        : infoPane.setupFailure ?
                              (root.device.setupDisplayMessage.length > 0 ? root.device.setupDisplayMessage : qsTr("Thing setup failed!"))
                            : (infoPane.connectedState !== null && infoPane.connectedState.value === false) ?
                                  qsTr("Thing is not connected!")
                                : qsTr("Thing runs out of battery!")
                visible: infoPane.alertState
                font.pixelSize: app.smallFont
                color: "white"
            }

            ColorIcon {
                height: app.iconSize / 2
                width: height
                visible: infoPane.setupInProgress || infoPane.setupFailure || (infoPane.connectedState !== null && infoPane.connectedState.value === false)
                color: "white"
                name: infoPane.setupInProgress ?
                          "../images/settings.svg"
                        : "../images/dialog-warning-symbolic.svg"
            }

            ColorIcon {
                height: app.iconSize / 2
                width: height * 1.23
                name: infoPane.batteryState !== null ? "../images/battery/battery-" + ("00" + (Math.floor(infoPane.batteryState.value / 10) * 10)).slice(-3) + ".svg" : ""
                visible: infoPane.batteryState !== null
                color: infoPane.alertState ? "white" : keyColor
            }
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.topMargin: infoPane.height
        clip: true
    }
}
