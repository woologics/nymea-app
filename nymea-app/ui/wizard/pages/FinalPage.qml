import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "qrc:/ui/wizard"
import "qrc:/ui/components"
import Nymea 1.0

WizardPageBase {
    id: root

    Label {
        anchors.centerIn: parent
        text: qsTr("All Done")
    }

    Button {
        anchors { bottom: parent.bottom; bottomMargin: app.margins; horizontalCenter: parent.horizontalCenter }
        text: qsTr("OK")
        onClicked: {
            print("Wizard: Completing Final page")
            root.complete()
        }
    }

}
