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

import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Nymea 1.0

Page {
    id: root
    property alias text: header.text

    // a ruleAction object needs to be set and prefilled with either deviceId or interfaceName
    property RuleAction ruleAction: null

    // optionally, a rule which will be used when determining params for the actions
    property Rule rule: null

    readonly property Device device: ruleAction && ruleAction.deviceId ? engine.deviceManager.devices.getDevice(ruleAction.deviceId) : null
    readonly property DeviceClass deviceClass: device ? engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId) : null

    signal backPressed();
    signal done();

    onRuleActionChanged: buildInterface()
    Component.onCompleted: buildInterface()

    header: NymeaHeader {
        id: header
        onBackPressed: root.backPressed();

        property bool interfacesMode: root.ruleAction.interfaceName !== ""
        onInterfacesModeChanged: root.buildInterface()

        HeaderButton {
            imageSource: header.interfacesMode ? "../images/view-expand.svg" : "../images/view-collapse.svg"
            visible: root.ruleAction.interfaceName === ""
            onClicked: header.interfacesMode = !header.interfacesMode
        }
    }

    ListModel {
        id: generatedModel
        dynamicRoles: true
    }

    function buildInterface() {
        print("building iface", root.ruleAction, root.ruleAction.interfaceName, header.interfacesMode, root.ruleAction.interfaceName === "")
        if (header.interfacesMode) {
            if (root.device) {
                generatedModel.clear();
                for (var i = 0; i < Interfaces.count; i++) {
                    var iface = Interfaces.get(i);
                    if (root.deviceClass.interfaces.indexOf(iface.name) >= 0) {
                        for (var j = 0; j < iface.actionTypes.count; j++) {
                            var ifaceAt = iface.actionTypes.get(j);
                            var dcAt = root.deviceClass.actionTypes.findByName(ifaceAt.name)
                            generatedModel.append({displayName: ifaceAt.displayName, actionTypeId: dcAt.id})
                        }
                    }
                }
                listView.model = generatedModel
            } else if (root.ruleAction.interfaceName !== "") {
                print("showing actions for interface", root.ruleAction.interfaceName)
                listView.model = Interfaces.findByName(root.ruleAction.interfaceName).actionTypes
            } else {
                console.warn("You need to set device or interfaceName");
            }
        } else {
            if (root.device) {
                generatedModel.clear();
                for (var i = 0; i < deviceClass.actionTypes.count; i++) {
                    var actionType = deviceClass.actionTypes.get(i);
                    generatedModel.append({displayName: actionType.displayName, actionTypeId: actionType.id})
                }

                // Append an item for browse mode
                if (root.deviceClass.browsable) {
                    generatedModel.append({displayName: qsTr("Open an item on this thing..."), actionTypeId: "browse"})
                }

                listView.model = generatedModel;

//                listView.model = deviceClass.actionTypes
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar {}

        delegate: NymeaListItemDelegate {
            id: delegate
            text: model.displayName
            width: parent.width
            iconName: model.actionTypeId === "browse" ? "../images/browser/BrowserIconFolder.svg" : "../images/action.svg"
            property ActionType actionType: root.deviceClass.actionTypes.getActionType(model.actionTypeId)
            progressive: model.actionTypeId === "browse" || actionType.paramTypes.count > 0

            onClicked: {
                if (header.interfacesMode) {
                    if (root.device) {
                        root.ruleAction.actionTypeId = model.actionTypeId;
                        root.ruleAction.browserItemId = "";
                        root.ruleAction.interfaceAction = "";
                        var actionType = root.deviceClass.actionTypes.getActionType(model.actionTypeId)
                        if (actionType.paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction, rule: root.rule})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else if (root.ruleAction.interfaceName !== "") {
                        root.ruleAction.interfaceAction = model.name;
                        root.ruleAction.browserItemId = "";
                        root.ruleAction.actionTypeId = "";
                        if (listView.model.get(index).paramTypes.count > 0) {
                            var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction, rule: root.rule})
                            paramsPage.onBackPressed.connect(function() {pageStack.pop()});
                            paramsPage.onCompleted.connect(function() {
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            root.done();
                        }
                    } else {
                        console.warn("Neither deviceId not interfaceName set. Cannot continue...");
                    }
                } else {
                    if (root.device) {
                        if (model.actionTypeId === "browse") {
                            var page = pageStack.push(Qt.resolvedUrl("SelectBrowserItemActionPage.qml"), {device: root.device});
                            page.selected.connect(function(selectedItemId) {
                                print("selected is", selectedItemId)
                                root.ruleAction.browserItemId = selectedItemId;
                                root.ruleAction.actionTypeId = "";
                                root.ruleAction.interfaceAction = "";
                                pageStack.pop();
                                root.done();
                            })
                        } else {
                            var actionType = root.deviceClass.actionTypes.getActionType(model.actionTypeId);
                            console.log("ActionType", actionType.id, "selected. Has", actionType.paramTypes.count, "params");
                            root.ruleAction.actionTypeId = actionType.id;
                            root.ruleAction.browserItemId = "";
                            root.ruleAction.interfaceAction = "";
                            if (actionType.paramTypes.count > 0) {
                                var paramsPage = pageStack.push(Qt.resolvedUrl("SelectRuleActionParamsPage.qml"), {ruleAction: root.ruleAction, rule: root.rule})
                                paramsPage.onBackPressed.connect(function() { pageStack.pop(); });
                                paramsPage.onCompleted.connect(function() {
                                    pageStack.pop();
                                    root.done();
                                })
                            } else {
                                root.done();
                            }
                        }
                    }
                }
            }
        }
    }
}
