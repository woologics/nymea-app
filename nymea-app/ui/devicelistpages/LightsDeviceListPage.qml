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
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"

DeviceListPageBase {

    header: NymeaHeader {
        text: qsTr("Lights")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/system-shutdown.svg"
            onClicked: {
                var allOff = true;
                for (var i = 0; i < devicesProxy.count; i++) {
                    var device = devicesProxy.get(i);
                    if (device.states.getState(device.deviceClass.stateTypes.findByName("power").id).value === true) {
                        allOff = false;
                        break;
                    }
                }

                for (var i = 0; i < devicesProxy.count; i++) {
                    var device = devicesProxy.get(i);
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("power");

                    var params = [];
                    var param1 = {};
                    param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                    param1["value"] = allOff ? true : false;
                    params.push(param1)
                    engine.deviceManager.executeAction(device.id, actionType.id, params)
                }
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: devicesProxy
        spacing: app.margins

        delegate: Pane {
            id: itemDelegate
            width: parent.width

            property bool inline: width > 500

            property Device device: devicesProxy.getDevice(model.id)
            property DeviceClass deviceClass: device.deviceClass

            property StateType connectedStateType: deviceClass.stateTypes.findByName("connected");
            property State connectedState: connectedStateType ? device.states.getState(connectedStateType.id) : null

            property StateType powerStateType: deviceClass.stateTypes.findByName("power");
            property ActionType powerActionType: deviceClass.actionTypes.findByName("power");
            property State powerState: device.states.getState(powerStateType.id)

            property StateType brightnessStateType: deviceClass.stateTypes.findByName("brightness");
            property ActionType brightnessActionType: deviceClass.actionTypes.findByName("brightness");
            property State brightnessState: brightnessStateType ? device.states.getState(brightnessStateType.id) : null

            property StateType colorStateType: deviceClass.stateTypes.findByName("color");
            property State colorState: colorStateType ? device.states.getState(colorStateType.id) : null

            Material.elevation: 1
            topPadding: 0
            bottomPadding: 0
            leftPadding: 0
            rightPadding: 0
            contentItem: ItemDelegate {
                id: contentItem
                implicitHeight: nameRow.implicitHeight
                //                gradient: Gradient {
                //                    GradientStop { position: 0.0; color: "transparent" }
                //                    GradientStop { position: 1.0; color: Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, 0.05) }
                //                }


                topPadding: 0

                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: app.margins / 2
                    color: itemDelegate.colorStateType ? itemDelegate.colorState.value : "#00000000"
                }

                contentItem: ColumnLayout {
                    spacing: 0
                    RowLayout {
                        enabled: itemDelegate.connectedState === null || itemDelegate.connectedState.value === true
                        id: nameRow
                        z: 2 // make sure the switch in here is on top of the slider, given we cheated a bit and made them overlap
                        spacing: app.margins
                        Item {
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: height
                            Layout.alignment: Qt.AlignVCenter

//                            DropShadow {
//                                anchors.fill: icon
//                                horizontalOffset: 0
//                                verticalOffset: 0
//                                radius: 2.0
//                                samples: 17
//                                color: app.foregroundColor
//                                source: icon
//                            }

                            ColorIcon {
                                id: icon
                                anchors.fill: parent
                                color: itemDelegate.connectedState !== null && itemDelegate.connectedState.value === false
                                       ? "red"
                                       : app.accentColor
                                name: itemDelegate.connectedState !== null && itemDelegate.connectedState.value === false ?
                                          "../images/dialog-warning-symbolic.svg"
                                        : itemDelegate.powerState.value === true ? "../images/light-on.svg" : "../images/light-off.svg"
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: model.name
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        ThrottledSlider {
                            id: inlineSlider
                            visible: contentItem.enabled && itemDelegate.brightnessStateType && itemDelegate.inline
                            from: 0; to: 100
                            value: itemDelegate.brightnessState ?  itemDelegate.brightnessState.value : 0
                            onMoved: {
                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = itemDelegate.brightnessActionType.paramTypes.get(0).id;
                                param1["value"] = value;
                                params.push(param1)
                                engine.deviceManager.executeAction(itemDelegate.device.id, itemDelegate.brightnessActionType.id, params)
                            }
                        }
                        Switch {
                            checked: itemDelegate.powerState.value === true
                            onClicked: {
                                var params = [];
                                var param1 = {};
                                param1["paramTypeId"] = itemDelegate.powerActionType.paramTypes.get(0).id;
                                param1["value"] = checked;
                                params.push(param1)
                                engine.deviceManager.executeAction(device.id, itemDelegate.powerActionType.id, params)
                            }
                        }
                    }
                }
                onClicked: {
                    enterPage(index, false)
                }
            }
        }
    }
}
