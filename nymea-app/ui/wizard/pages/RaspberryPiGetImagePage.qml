import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "qrc:/ui/wizard"
import "qrc:/ui/components"

WizardPageBase {
    id: root

    Label {
        anchors.centerIn: parent
        text: "Download image, flash to sd card"
    }

    Button {
        anchors { bottom: parent.bottom; bottomMargin: app.margins; horizontalCenter: parent.horizontalCenter }
        text: qsTr("Next")
        onClicked: {
            root.complete()
        }
    }

}
