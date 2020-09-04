import QtQuick 2.9
import QtQuick.Controls 2.1
import "qrc:/ui/wizard"
import "qrc:/ui/components"

WizardPageBase {
    id: root

    EmptyViewPlaceholder {
        anchors.centerIn: parent
        width: parent.width - app.margins * 2
        title: qsTr("Welcome to nymea")
        text: qsTr("This wizard will guide you to the steps to set up a nymea system.")
        imageSource: "qrc:/ui/images/guh-logo.svg"
        buttonText: qsTr("Next")
        onButtonClicked: root.complete()
    }

}
