/*   Modified SDDM Chili theme Based on original work of Marian
      > https://github.com/MarianArlt/sddm-chili
     and fork, fixing the theme to work in QT6
      > https://github.com/sphaugh/sddm-chili
     Tweaked to better line up with my simple lock screen"

		 Original credits retaained as below:
     --------------------------------------------
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
import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2
import SddmComponents 2.0

import "components"


Rectangle {

    id: root

    FontLoader { id: ubuntuRegular; source: "assets/fonts/UbuntuNerdFont-Regular.ttf" }
    FontLoader { id: ubuntuBold; source: "assets/fonts/UbuntuNerdFont-Bold.ttf" }

    property string generalFontColor: "white"
    property int generalFontSize: config.FontPointSize ? parseInt(config.FontPointSize) : Math.max(1, root.height / 80)
    property string notificationMessage

    height: config.ScreenHeight
    width: config.ScreenWidth

    TextConstants {
        id: textConstants

    }
    Repeater {
        model: screenModel

        Wallpaper {
            height: geometry.height
            imageSource: config.background
            width: geometry.width
            x: geometry.x
            y: geometry.y
        }
    }
    ColumnLayout {
        id: container

        LayoutMirroring.childrenInherit: true
        LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
        anchors.fill: parent

        RowLayout {
            id: header

            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: false
            Layout.rightMargin: generalFontSize * 1.5
            Layout.topMargin: 200

            KeyboardLayoutButton {
                Layout.topMargin: -1
                implicitHeight: clockLabel.height * 1.2
                implicitWidth: clockLabel.height * 1.8
            }
            Item {
                id: clock
                Layout.fillHeight: true
                Layout.minimumWidth: Math.max(timeLabel.width, dateLabel.width)
                Layout.alignment: Qt.AlignCenter
                
                Component.onCompleted: {
                    updateDateTime();
                }
                
                function updateDateTime() {
                    // Get the current date/time once
                    let now = new Date();
                    
                    // Update time - using 24-hour format with large font
                    timeLabel.text = now.toLocaleString(Qt.locale("en_US"), "hh:mm");
                    
                    // Update date - full day name, day, month and year
                    dateLabel.text = now.toLocaleString(Qt.locale("en_US"), "dddd, dd MMMM yyyy");
                }
                
                Column {
                    anchors.centerIn: parent
                    spacing: root.generalFontSize * 0.5
                    
                    Label {
                        id: timeLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: generalFontColor
                        font.family: ubuntuRegular
                        font.pointSize: 150
                        font.weight: Font.Regular 
                        renderType: Text.QtRendering
                    }
                    
                    Label {
                        id: dateLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: generalFontColor
                        font.pointSize: 26
                        font.weight: bold
                        font.family: ubuntuBold
                        renderType: Text.QtRendering
                    }
                }
                
                Timer {
                    interval: 1000
                    repeat: true
                    running: true
                    onTriggered: {
                        updateDateTime();
                    }
                }
            }
        }
        StackView {
            id: loginFormStack

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: 150
            focus: true // StackView is an implicit focus scope. Therefore focus needs to be passed to its children.

            initialItem: LoginForm {
                id: userListComponent

                faceSize: config.AvatarPixelSize ? parseInt(config.AvatarPixelSize) : root.width / 15
                focus: true
                lastUserName: userModel.lastUser
                notificationMessage: {
                    var text = "";
                    text += root.notificationMessage;
                    return text;
                }
                showUserList: {
                    if (!userListModel.hasOwnProperty("count") || !userListModel.hasOwnProperty("disableAvatarsThreshold"))
                        return (userList.y + loginFormStack.y) > 0;
                    if (userListModel.count == 0)
                        return false;
                    return userListModel.count <= userListModel.disableAvatarsThreshold && (userList.y + loginFormStack.y) > 0;
                }
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                userListModel: userModel
                usernameFontColor: root.generalFontColor
                usernameFontSize: root.generalFontSize

                actionItems: [
                    ActionButton {
                        enabled: sddm.canSuspend
                        iconSize: Math.max(1, root.generalFontSize * 3)
                        iconSource: "../assets/suspend.svg"
                        text: config.translationSuspend ? config.translationSuspend : "Suspend"

                        onClicked: sddm.suspend()
                    },
                    ActionButton {
                        enabled: sddm.canReboot
                        iconSize: Math.max(1, root.generalFontSize * 3)
                        iconSource: "../assets/reboot.svg"
                        text: config.translationReboot ? config.translationReboot : textConstants.reboot

                        onClicked: sddm.reboot()
                    },
                    ActionButton {
                        enabled: sddm.canPowerOff
                        iconSize: Math.max(1, root.generalFontSize * 3)
                        iconSource: "../assets/poweroff.svg"
                        text: config.translationPowerOff ? config.translationPowerOff : textConstants.shutdown

                        onClicked: sddm.powerOff()
                    }
                ]

                onLoginRequest: function (username, password) {
                    root.notificationMessage = "";
                    sddm.login(username, password, sessionMenu.currentIndex);
                }
            }
            Behavior on opacity {
                OpacityAnimator {
                    duration: 150
                }
            }
        }
        Loader {
            id: inputPanel

            property bool keyboardActive: item ? item.active : false

            function showHide() {
                state = state == "hidden" ? "visible" : "hidden";
            }

            Layout.fillWidth: true
            source: "components/VirtualKeyboard.qml"
            state: "hidden"

            states: [
                State {
                    name: "visible"

                    PropertyChanges {
                        target: loginFormStack
                        y: Math.min(0, root.height - inputPanel.height - userListComponent.visibleBoundary)
                    }
                    PropertyChanges {
                        opacity: 1
                        target: inputPanel
                        y: root.height - inputPanel.height
                    }
                },
                State {
                    name: "hidden"

                    PropertyChanges {
                        target: loginFormStack
                        y: 0
                    }
                    PropertyChanges {
                        opacity: 0
                        target: inputPanel
                        y: root.height - root.height / 4
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"

                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                                property: "y"
                                target: loginFormStack
                            }
                            NumberAnimation {
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                                property: "y"
                                target: inputPanel
                            }
                            OpacityAnimator {
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                                target: inputPanel
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"

                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                                property: "y"
                                target: loginFormStack
                            }
                            NumberAnimation {
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                                property: "y"
                                target: inputPanel
                            }
                            OpacityAnimator {
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                                target: inputPanel
                            }
                        }
                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]

            onKeyboardActiveChanged: {
                if (keyboardActive) {
                    state = "visible";
                } else {
                    state = "hidden";
                }
            }
        }
        RowLayout {
            id: footer

            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: generalFontSize
            Layout.fillHeight: false
            Layout.leftMargin: generalFontSize * 1.5

            SessionMenu {
                id: sessionMenu

                rootFontColor: root.generalFontColor
                rootFontSize: root.generalFontSize
            }
        }
        Connections {
            function onLoginFailed() {
                notificationMessage = textConstants.loginFailed;
                notificationResetTimer.start();
            }

            target: sddm
        }
        Timer {
            id: notificationResetTimer

            interval: 3000

            onTriggered: notificationMessage = ""
        }
    }
}
