/*
 *   Copyright 2018 Marian Arlt <marianarlt@icloud.com>
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
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
import QtQuick.Layouts 6.2
import QtQuick.Controls 6.2

LoginFormLayout {
    property int inputSpacing: 8
    property string lastUserName
    property bool passwordFieldOutlined: config.PasswordFieldOutlined == "true"

    signal loginRequest(string username, string password)

    function startLogin() {
        var username = userList.selectedUser;
        var password = passwordField.text;
        loginRequest(username, password);
    }

    Component.onCompleted: {
        passwordField.forceActiveFocus();
    }

    RowLayout {
        Layout.leftMargin: inputSpacing * 2
        Layout.topMargin: 50
        Layout.minimumWidth: passwordField.width + inputSpacing * 2

        TextField {
            id: passwordField

            color: "white"
            echoMode: TextInput.Password
            focus: true
            font.pointSize: 36
            implicitHeight: usernameFontSize * 8
            implicitWidth: root.width / 4
            placeholderText: "󰌆 "
            placeholderTextColor: "white"
            horizontalAlignment: Text.AlignHCenter
            leftPadding: 24  
            rightPadding: 24
            topPadding: 16
            bottomPadding: 16

            background: Rectangle {
                border.color: "transparent"
                border.width: 0
                color: passwordFieldOutlined ? "transparent" : config.AccentColor
                radius: 8
            }

            Keys.onEscapePressed: {
                loginFormStack.currentItem.forceActiveFocus();
            }
            Keys.onPressed: function (event) {
                if (event.key == Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true;
                }
                if (event.key == Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true;
                }
            }
            onAccepted: startLogin()

            Connections {
                function onLoginFailed() {
                    passwordField.selectAll();
                    passwordField.forceActiveFocus();
                }

                target: sddm
            }
        }
    }
}
