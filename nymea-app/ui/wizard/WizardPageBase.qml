import QtQuick 2.9
import QtQuick.Controls 2.1

Page {
    id: root

    signal back()
    signal next(var next)
    signal complete()
}
