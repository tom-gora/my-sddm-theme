/*
 *   Copyright 2018 Marian Arlt <marianarlt@icloud.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 3 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 6.2
import Qt5Compat.GraphicalEffects

FocusScope {
    id: backgroundComponent

    property bool configBlur: config.blur == "true"
    property alias imageSource: backgroundImage.source

    Image {
        id: backgroundImage

        anchors.fill: parent
        clip: true
        fillMode: Image.PreserveAspectCrop
        focus: true
        smooth: true
    }

    GaussianBlur {
        id: backgroundBlur

        anchors.fill: backgroundImage
        source: backgroundImage
        deviation: configBlur ?  config.BlurRadius - 1 : 0
        radius: configBlur ? config.BlurRadius : 0
        samples: configBlur ? config.BlurRadius * 2 + 1 : 0
    }

    MouseArea {
        anchors.fill: parent

        onClicked: container.focus = true
    }
}
