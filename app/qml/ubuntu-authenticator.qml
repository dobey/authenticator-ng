/*****************************************************************************
 * Copyright: 2013 Michael Zanetti <michael_zanetti@gmx.net>                 *
 *                                                                           *
 * This file is part of ubuntu-authenticator                                 *
 *                                                                           *
 * This prject is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * This project is distributed in the hope that it will be useful,           *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                           *
 ****************************************************************************/

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import OAth 1.0
import QtMultimedia 5.0
import QtQuick.Window 2.0

MainView {

    applicationName: "com.ubuntu.developer.mzanetti.ubuntu-authenticator"

    //automaticOrientation: true

    headerColor: "black"
    backgroundColor: "#555555"
    footerColor: "#888888"

    width: units.gu(40)
    height: units.gu(68)

    PageStack {
        id: pageStack

        Component.onCompleted: pageStack.push(mainPage)

    }
    Page {
        id: mainPage
        title: "Authenticator"
        visible: false

        tools: ToolbarItems {
            opened: true
            locked: true
            ToolbarButton {
                id: addButton
                text: "Add"
                iconSource: "image://theme/add"
                onTriggered: {
                    PopupUtils.open(addMenuComponent, addButton)
                }
            }
        }

        Label {
            anchors.centerIn: parent
            width: parent.width - units.gu(4)
            text: "No accounts set up.\nPlease add an account using the \"Add\" button."
            wrapMode: Text.WordWrap
            fontSize: "large"
            horizontalAlignment: Text.AlignHCenter
            visible: accountsListView.count == 0
        }

        Icon {
            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: units.gu(1)
            }

            width: units.gu(10)
            height: width
            rotation: -90
            name: "keyboard-return"
            visible: accountsListView.count == 0
        }

        ListView {
            id: accountsListView
            anchors.fill: parent
            model: accounts
            interactive: contentHeight > height - units.gu(6) //FIXME: -6gu because of the panel being locked to open

            delegate: Empty {
                id: accountDelegate
                height: delegateColumn.height + units.gu(4)
                removable: true

                property bool activated: false

                onItemRemoved: {
                    print("item removed:", accounts.get(index))
                    var popup = PopupUtils.open(removeQuestionComponent, accountsListView, {account: accounts.get(index)})
                    popup.accepted.connect(function() { accounts.deleteAccount(index); });
                    popup.rejected.connect(function() { accounts.refresh(); });
                }

                Column {
                    id: delegateColumn
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        leftMargin: units.gu(2)
                        topMargin: units.gu(2)
                        rightMargin: refreshButton.width + units.gu(2)
                    }
                    spacing: units.gu(1)
                    height: childrenRect.height

                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        text: name
                        elide: Text.ElideRight
                    }

                    Label {
                        id: otpLabel
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        fontSize: "x-large"
                        text: accountDelegate.activated ? otp : ""
                        Button {
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                            text: "Click here to generate a password"
                            visible: !accountDelegate.activated
                            onClicked: {
                                accounts.get(index).next()
                                accountDelegate.activated = true
                            }
                        }
                    }
                }

                Icon {
                    id: refreshButton
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                    width: accountDelegate.activated ? units.gu(6) : 0
                    height: units.gu(6)
                    name: "reload"
                    visible: accountDelegate.activated
                    MouseArea {
                        anchors.fill: parent
                        onClicked: accounts.generateNext(index)
                    }
                }

                onPressAndHold: {
                    PopupUtils.open(editSheetComponent, mainPage, {account: accounts.get(index)})
                }
            }
        }
    }

    Component {
        id: editSheetComponent
        ComposerSheet {

            property QtObject account: null

            onConfirmClicked: {
                var newAccount = account;
                if (newAccount == null) {
                    newAccount = accounts.createAccount()
                }

                newAccount.name = nameField.text
                newAccount.secret = secretField.text
                newAccount.counter = parseInt(counterField.text)
                newAccount.pinLength = parseInt(pinLengthField.text)
                //print("account is", newAccount, newAccount.name, newAccount.secret, newAccount.counter, newAccount.pinLength)
            }

            __rightButton.enabled: nameField.text.length > 0 && secretField.text.length >= 16

            Component.onCompleted: {
                __foreground.__styleInstance.headerColor = "#333333"
                __foreground.__styleInstance.backgroundColor = "#222222"
            }

            Flickable {
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                }
                contentHeight: settingsColumn.height
                clip: true

                Column {
                    id: settingsColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    spacing: units.gu(2)

                    Label {
                        text: "Name"
                    }
                    TextField {
                        id: nameField
                        width: parent.width
                        text: account ? account.name : ""
                        placeholderText: "Enter the account name"
                        onTextChanged: print("bar", text)
                    }

                    Label {
                        text: "Key"
                    }
                    TextArea {
                        id: secretField
                        width: parent.width
                        text: account ? account.secret : ""
                        autoSize: true
                        wrapMode: Text.WrapAnywhere
                        placeholderText: "Enter the 16 or 32 digits key"
                    }
                    Row {
                        width: parent.width
                        property int cellWidth: (width - spacing) / 2
                        spacing: units.gu(2)
                        Row {
                            width: parent.cellWidth
                            spacing: units.gu(1)

                            Label {
                                text: "Counter"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            TextField {
                                id: counterField
                                text: account ? account.counter : 0
                                width: parent.width - x
                                inputMask: "0009"
                            }
                        }
                        Row {
                            width: parent.cellWidth
                            spacing: units.gu(1)

                            Label {
                                text: "Pin length"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            TextField {
                                id: pinLengthField
                                text: account ? account.pinLength : 6
                                width: parent.width - x
                                inputMask: "0D"
                            }
                        }
                        Item {
                            width: parent.width
                            height: Qt.inputMethod.keyboardRectangle.height
                        }
                    }
                }
            }
        }
    }

    AccountModel {
        id: accounts
    }

    Component {
        id: grabCodeComponent
        Page {
            id: grabCodePage

            tools: ToolbarItems {
                opened: true
                locked: true
            }

            QRCodeReader {
                id: qrCodeReader

                onValidChanged: {
                    if (valid) {
                        var account = accounts.createAccount();
                        account.name = qrCodeReader.accountName;
                        account.secret = qrCodeReader.secret;
                        account.counter = qrCodeReader.counter;
                        pageStack.pop();
                    }
                }
            }

            Camera {
                id: camera

                flash.mode: Camera.FlashTorch

                focus.focusMode: Camera.FocusContinuous
                focus.focusPointMode: Camera.FocusPointAuto

                Component.onCompleted: {
                    captureTimer.start()
                }
            }

            Timer {
                id: captureTimer
                interval: 3000
                repeat: true
                onTriggered: {
                    print("capturing");
                    qrCodeReader.grab();
                }
            }

            VideoOutput {
                anchors {
                    fill: parent
                    topMargin: units.gu(8)
                }
                fillMode: Image.PreserveAspectCrop
                orientation: device.naturalOrientation === "portrait"  ? -90 : 0
                source: camera
                focus: visible

            }
            Label {
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                    margins: units.gu(1)
                }
                text: "Scan a QR-Code containing account information"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                fontSize: "large"
            }
        }
    }

    // We must use Item element because Screen component does not work with QtObject
    Item {
        id: device
        property string naturalOrientation: Screen.primaryOrientation == Qt.LandscapeOrientation ? "landscape" : "portrait"
        visible: false
    }

    Component {
        id: addMenuComponent
        Popover {
            id: addMenuPopover
            height: menuColumn.height
            Column {
                id: menuColumn
                width: parent.width
                height: childrenRect.height

                Repeater {
                    model: ListModel {
                        ListElement { text: "Add manually"; icon: "edit" }
                        ListElement { text: "Scan QR-Code"; icon: "camera-symbolic" }
                    }
                    delegate: Standard {
                        text: model.text
                        icon: Icon {
                            name: model.icon
                            height: parent.height
                            width: height
                        }

                        onClicked: {
                            switch (index) {
                            case 0:
                                PopupUtils.open(editSheetComponent, mainPage)
                                break;
                            case 1:
                                pageStack.push(grabCodeComponent)
                                break
                            }
                            PopupUtils.close(addMenuPopover)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: removeQuestionComponent
        Dialog {
            id: removeQuestionDialog
            title: "Remove account?"
            text: qsTr("Are you sure you want to remove %1?").arg(account.name)

            property QtObject account

            signal accepted()
            signal rejected()

            Button {
                text: qsTr("Yes")
                onClicked: {
                    PopupUtils.close(removeQuestionDialog);
                    removeQuestionDialog.accepted();
                }
            }
            Button {
                text: qsTr("Cancel")
                onClicked: {
                    PopupUtils.close(removeQuestionDialog);
                    removeQuestionDialog.rejected();
                }
            }
        }
    }
}
