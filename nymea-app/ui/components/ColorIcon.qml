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
import QtGraphicalEffects 1.0

Item {
    id: icon

    property string name
    property alias color: colorizedImage.color
    property int margins: 0

    //TODO: Should be in the style
    readonly property color keyColor: "#808080"

    property alias status: image.status

    Image {
        id: image
        anchors.fill: parent
        anchors.margins: parent ? parent.margins : 0
        source: width > 0 && height > 0 && icon.name ?
                    icon.name.endsWith(".svg") ? icon.name
                                               : "qrc:/ui/images/" + icon.name + ".svg"
                                                 : ""
        sourceSize {
            width: width
            height: height
        }
        cache: true
    }

    ColorOverlay {
        id: colorizedImage

        anchors.fill: parent
        anchors.margins: parent ? parent.margins : 0
        visible: image.status == Image.Ready
        source: image
    }
}
