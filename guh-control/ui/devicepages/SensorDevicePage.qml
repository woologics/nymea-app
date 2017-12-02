import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Guh 1.0
import "../components"
import "../customviews"

Page {
    id: root
    property var device: null
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)


    header: GuhHeader {
        text: device.name
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/info.svg"
            onClicked: pageStack.push(Qt.resolvedUrl("GenericDeviceStateDetailsPage.qml"), {device: root.device})
        }
    }

    ListView {
        anchors { fill: parent }
        spacing: app.margins
        model: ListModel {
            Component.onCompleted: {
                var supportedInterfaces = ["temperaturesensor", "humiditysensor"]
                for (var i = 0; i < supportedInterfaces.length; i++) {
                    if (root.deviceClass.interfaces.indexOf(supportedInterfaces[i]) >= 0) {
                        append({name: supportedInterfaces[i]});
                    }
                }
            }
        }
        delegate: SensorView {
            width: parent.width
            interfaceName: modelData
            device: root.device
            deviceClass: root.deviceClass
        }
    }
}