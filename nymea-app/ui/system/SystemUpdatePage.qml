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

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import "../components"
import Nymea 1.0

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("System update")
        backButtonVisible: true
        onBackPressed: pageStack.pop()

        HeaderButton {
            text: qsTr("Settings")
            imageSource: "../images/settings.svg"
            onClicked: {
                pageStack.push(repositoryListComponent)
            }
        }
    }

    Connections {
        target: engine.systemController
        onEnableRepositoryFinished: {
            if (!success) {
                var popup = errorDialogComponent.createObject(app, {errorCode: qsTr("Failure adding repository.") })
                popup.open();
            }
        }
    }

    PackagesFilterModel {
        id: updatesModel
        packages: engine.systemController.packages
        updatesOnly: true
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: updatesModel.count === 0

            ColumnLayout {
                width: parent.width
                anchors.centerIn: parent
                spacing: app.margins * 2

                ColorIcon {
                    Layout.preferredHeight: app.iconSize * 4
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignHCenter
                    name: "../images/system-update.svg"
                    color: app.accentColor
                    RotationAnimation on rotation {
                        from: 0; to: 360
                        duration: 2000
                        running: engine.systemController.updateManagementBusy
                        loops: Animation.Infinite
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: engine.systemController.updateManagementBusy ? qsTr("Checking for updates...") : qsTr("Your system is up to date.")
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Check for updates")
                    enabled: !engine.systemController.updateManagementBusy
                    onClicked: {
                        engine.systemController.checkForUpdates()
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: updatesModel.count > 0

            RowLayout {
                Layout.margins: app.margins
                spacing: app.margins

                ColorIcon {
                    Layout.preferredHeight: app.iconSize * 2
                    Layout.preferredWidth: height
                    name: "../images/system-update.svg"
                    color: app.accentColor
                    RotationAnimation on rotation {
                        from: 0; to: 360
                        duration: 2000
                        running: engine.systemController.updateManagementBusy
                        loops: Animation.Infinite
                    }
                }

                ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: engine.systemController.updateManagementBusy ? qsTr("Checking for updates...") : qsTr("%n update(s) available", "", updatesModel.count)
                    }
                    GridLayout {
                        columns: width > 250 ? 2 : 1
                        Button {
                            Layout.fillWidth: true
                            text: qsTr("Check again")
                            enabled: !engine.systemController.updateManagementBusy
                            onClicked: {
                                engine.systemController.checkForUpdates()
                            }
                        }
                        Button {
                            Layout.fillWidth: true
                            text: qsTr("Update all")
                            visible: updatesModel.count > 0
                            enabled: !engine.systemController.updateManagementBusy
                            onClicked: {
                                var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                                var text = qsTr("This will start a system update. Note that the update might take several minutes and your %1:core might not be functioning properly during this time and restart during the process.\nDo you want to proceed?").arg(app.systemName)
                                var popup = dialog.createObject(app,
                                                                {
                                                                    headerIcon: "../images/system-update.svg",
                                                                    title: qsTr("System update"),
                                                                    text: text,
                                                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                                                });
                                popup.open();
                                popup.accepted.connect(function() {
                                    engine.systemController.updatePackages()
                                })
                            }
                        }
                    }
                }

            }

            ThinDivider {}

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: count > 0
                model: updatesModel
                clip: true
                delegate: NymeaListItemDelegate {
                    width: parent.width
                    text: model.displayName
                    subText: model.candidateVersion
                    prominentSubText: false
                    iconName: model.updateAvailable
                              ? Qt.resolvedUrl("../images/system-update.svg")
                                : Qt.resolvedUrl("../images/view-" + (model.installedVersion.length > 0 ? "expand" : "collapse") + ".svg")
                    iconColor: model.updateAvailable
                               ? "green"
                                 : model.installedVersion.length > 0 ? "blue" : iconKeyColor
                    onClicked: {
                        pageStack.push(packageDetailsComponent, {pkg: updatesModel.get(index)})
                    }
                }
            }
        }

        ThinDivider {}

        NymeaListItemDelegate {
            Layout.fillWidth: true
            text: qsTr("Install or remove software")
            onClicked: {
                pageStack.push(packageListComponent, {packages: engine.systemController.packages})
            }
        }
    }

    Component {
        id: repositoryListComponent
        Page {
            id: repositoryListPage
            header: NymeaHeader {
                text: qsTr("Configure update sources")
                onBackPressed: pageStack.pop()
            }
            ListView {
                anchors.fill: parent
                model: engine.systemController.repositories
                delegate: CheckDelegate {
                    width: parent.width
                    text: model.displayName
                    checked: model.enabled
                    onClicked: {
                        if (checked) {
                            var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                            var text = qsTr("Enabling additional software sources allows to install unreleased %1:core packages.\nThis can potentially break your system and lead to problems.\nPlease only use this if you are sure you want this and consider reporting the issues you find when testing unreleased channels.").arg(app.systemName)
                            var popup = dialog.createObject(app,
                                                            {
                                                                headerIcon: "../images/dialog-warning-symbolic.svg",
                                                                title: qsTr("Enable package source"),
                                                                text: text,
                                                                standardButtons: Dialog.Ok | Dialog.Cancel
                                                            });
                            popup.open();
                            popup.accepted.connect(function() {
                                engine.systemController.enableRepository(model.id, true)
                            })
                            popup.rejected.connect(function() {
                                checked = false
                            })
                        } else {
                            engine.systemController.enableRepository(model.id, false)
                        }
                    }
                }
            }
            UpdateRunningOverlay {
            }
        }
    }

    Component {
        id: packageListComponent
        Page {
            id: packageListPage

            property var packages: null

            header: NymeaHeader {
                text: qsTr("All packages")
                onBackPressed: pageStack.pop()
            }

            ListView {
                anchors.fill: parent
                model: PackagesFilterModel {
                    id: filterModel
                    packages: packageListPage.packages
                }
                delegate: NymeaListItemDelegate {
                    width: parent.width
                    text: model.displayName
                    subText: model.candidateVersion
                    prominentSubText: false
                    iconName: model.updateAvailable
                              ? Qt.resolvedUrl("../images/system-update.svg")
                                : Qt.resolvedUrl("../images/view-" + (model.installedVersion.length > 0 ? "expand" : "collapse") + ".svg")
                    iconColor: model.updateAvailable
                               ? "green"
                                 : model.installedVersion.length > 0 ? "blue" : iconKeyColor
                    onClicked: {
                        pageStack.push(packageDetailsComponent, {pkg: filterModel.get(index)})
                    }
                }
            }
            UpdateRunningOverlay {
            }
        }
    }

    Component {
        id: packageDetailsComponent
        Page {
            id: packageDetailsPage

            property Package pkg: null

            header: NymeaHeader {
                text: qsTr("Package information")
                onBackPressed: pageStack.pop()
            }

            GridLayout {
                anchors { left: parent.left; top: parent.top; right: parent.right }
                columns: app.landscape ? 2 : 1
                RowLayout {
                    Layout.margins: app.margins
                    spacing: app.margins
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize * 2
                        Layout.preferredWidth: app.iconSize * 2
                        name: "../images/plugin.svg"
                        color: app.accentColor
                    }
                    Label {
                        Layout.fillWidth: true
                        text: pkg.displayName
                        font.pixelSize: app.largeFont
                        elide: Text.ElideRight
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: packageDetailsPage.pkg.summary
                    wrapMode: Text.WordWrap
                }

                NymeaListItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Installed version:")
                    subText: packageDetailsPage.pkg.installedVersion.length > 0 ? packageDetailsPage.pkg.installedVersion : qsTr("Not installed")
                    progressive: false
                }

                NymeaListItemDelegate {
                    Layout.fillWidth: true
                    text: qsTr("Candidate version:")
                    subText: packageDetailsPage.pkg.candidateVersion
                    visible: packageDetailsPage.pkg.updateAvailable || packageDetailsPage.pkg.installedVersion.length === 0
                    progressive: false
                }
                Button {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    visible: packageDetailsPage.pkg.updateAvailable || packageDetailsPage.pkg.installedVersion.length === 0
                    text: packageDetailsPage.pkg.updateAvailable ? qsTr("Update") : qsTr("Install")
                    onClicked: {
                        var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                        var text = qsTr("This will start a system update. Note that the update might take several minutes and your %1:core might not be functioning properly or restart during this time.").arg(app.systemName)
                                + "\n\n"
                                + qsTr("\nDo you want to proceed?")
                        var popup = dialog.createObject(app,
                                                        {
                                                            headerIcon: "../images/system-update.svg",
                                                            title: qsTr("Start update"),
                                                            text: text,
                                                            standardButtons: Dialog.Ok | Dialog.Cancel
                                                        });
                        popup.open();
                        popup.accepted.connect(function() {
                            engine.systemController.updatePackages(packageDetailsPage.pkg.id)
                        })

                    }
                }
                Button {
                    Layout.fillWidth: true
                    Layout.margins: app.margins
                    text: qsTr("Remove")
                    visible: packageDetailsPage.pkg.canRemove
                    onClicked: {
                        var dialog = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
                        var text = qsTr("This will start a system update. Note that the update might take several minutes and your %1:core might not be functioning properly during this time and restart during the process.\nDo you want to proceed?").arg(app.systemName)
                        var popup = dialog.createObject(app,
                                                        {
                                                            headerIcon: "../images/system-update.svg",
                                                            title: qsTr("Remove package"),
                                                            text: text,
                                                            standardButtons: Dialog.Ok | Dialog.Cancel
                                                        });
                        popup.open();
                        popup.accepted.connect(function() {
                            engine.systemController.removePackages(packageDetailsPage.pkg.id)
                        })
                    }
                }

            }
            UpdateRunningOverlay {
            }
        }
    }


    UpdateRunningOverlay {
    }

    Component {
        id: errorDialogComponent

        ErrorDialog {
            id: errorDialog
        }
    }
}
