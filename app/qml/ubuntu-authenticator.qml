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
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0
import OAth 1.0
import QtMultimedia 5.0
import QtQuick.Window 2.0

MainView {

    applicationName: "com.ubuntu.developer.mzanetti.ubuntu-authenticator"

    width: units.gu(40)
    height: units.gu(68)

    useDeprecatedToolbar: false

    Component.onCompleted: {
        Theme.name = "Ubuntu.Components.Themes.SuruDark"
        i18n.domain = "authenticator"
    }

    PageStack {
        id: pageStack

        Component.onCompleted: pageStack.push(mainPage)
    }

    Page {
        id: mainPage
        title: "Authenticator"
        visible: false

        head {
            actions: [
                Action {
                    text: i18n.tr("Add account")
                    iconName: "add"
                    onTriggered: {
                        pageStack.push(editSheetComponent)
                    }
                },
                Action {
                    text: i18n.tr("Scan QR code")
                    iconName: "camera-symbolic"
                    onTriggered: {
                        pageStack.push(grabCodeComponent)
                    }
                }
            ]
        }

        Label {
            anchors.centerIn: parent
            width: parent.width - units.gu(4)
            text: i18n.tr("No account set up. Use the buttons in the toolbar to add accounts.")
            wrapMode: Text.WordWrap
            fontSize: "large"
            horizontalAlignment: Text.AlignHCenter
            visible: accountsListView.count == 0 && pageStack.depth == 1
        }

        Icon {
            id: addHintIcon
            anchors {
                right: parent.right
                top: parent.top
                rightMargin: units.gu(4)
            }

            width: units.gu(6)
            height: width
            name: "keyboard-caps-enabled"
            visible: accountsListView.count == 0 && pageStack.depth == 1

            SequentialAnimation {
                running: addHintIcon.visible
                loops: Animation.Infinite
                UbuntuNumberAnimation { target: addHintIcon; property: "anchors.topMargin"; from: units.gu(10); to: units.gu(14); duration: UbuntuAnimation.SleepyDuration }
                UbuntuNumberAnimation { target: addHintIcon; property: "anchors.topMargin"; from: units.gu(14); to: units.gu(10); duration: UbuntuAnimation.SleepyDuration }
            }
        }

        ListView {
            id: accountsListView
            anchors.fill: parent
            model: accounts
            interactive: contentHeight > height - units.gu(6) //FIXME: -6gu because of the panel being locked to open

            delegate: ListItemWithActions {
                id: accountDelegate
                height: delegateColumn.height + units.gu(4)
                width: parent.width

                property bool activated: false

                leftSideAction: Action {
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    onTriggered: {
                        var popup = PopupUtils.open(removeQuestionComponent, accountsListView, {account: accounts.get(index)})
                        popup.accepted.connect(function() { accounts.deleteAccount(index); });
                        popup.rejected.connect(function() { accounts.refresh(); });
                    }
                }

                rightSideActions: [
                    Action {
                        iconName: "edit"
                        text: i18n.tr("Edit")
                        onTriggered: {
                            pageStack.push(editSheetComponent, {account: accounts.get(index)})
                        }
                    }
                ]

                contents: Column {
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
                        text: accountDelegate.activated || type === Account.TypeTOTP ? otp : ""
                        Button {
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                            // TRANSLATORS: Text on a button
                            text: i18n.tr("Generate PIN")
                            visible: !accountDelegate.activated && type === Account.TypeHOTP
                            color: UbuntuColors.green
                            onClicked: {
                                accounts.get(index).next()
                                accountDelegate.activated = true
                            }
                        }
                    }
                    UbuntuShape {
                        id: totpProgressBar
                        width: parent.width
                        height: units.gu(.5)
                        color: "#000000"
                        onWidthChanged: totpAnimation.startCountdown();
                        visible: type === Account.TypeTOTP

                        UbuntuShape {
                            id: totpProgressBarFill
                            anchors.fill: parent
                            color: UbuntuColors.green

                            NumberAnimation {
                                id: totpAnimation
                                duration: timeStep * 1000
                                target: totpProgressBarFill
                                property: "anchors.leftMargin"
                                function startCountdown() {
                                    stop();
                                    duration = accounts.get(index).msecsToNext();
                                    var progress = ((timeStep * 1000) - duration) / (timeStep * 1000)
                                    to = totpProgressBar.width;
                                    from = totpProgressBar.width * progress;
                                    start();
                                }
                            }
                        }
                    }
                    Component.onCompleted: {
                        if (type === Account.TypeTOTP) {
                            totpAnimation.startCountdown()
                        }
                    }

                    Connections {
                        target: accounts.get(index)
                        onOtpChanged: {
                            if (type === Account.TypeTOTP) {
                                totpAnimation.startCountdown()
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
                    width: type === Account.TypeHOTP && accountDelegate.activated ? units.gu(6) : 0
                    height: units.gu(6)
                    name: "reload"
                    visible: accountDelegate.activated && type === Account.TypeHOTP
                    color: UbuntuColors.green
                    MouseArea {
                        anchors.fill: parent
                        onClicked: accounts.generateNext(index)
                    }
                }
            }
        }
    }

    Component {
        id: editSheetComponent
        Page {
            title: account == null ? i18n.tr("Add account") : i18n.tr("Edit account")

            property QtObject account: null

            tools: ToolbarItems {
                ToolbarButton {
                    action: Action {
                        iconName: "tick"
                        enabled: nameField.text.length > 0 && secretField.text.length >= 16
                        onTriggered: {
                            var newAccount = account;
                            if (newAccount == null) {
                                newAccount = accounts.createAccount()
                            }

                            newAccount.name = nameField.text
                            newAccount.type = typeSelector.selectedIndex == 1 ? Account.TypeTOTP : Account.TypeHOTP
                            newAccount.secret = secretField.text
                            newAccount.counter = parseInt(counterField.text)
                            newAccount.timeStep = parseInt(timeStepField.text)
                            newAccount.pinLength = parseInt(pinLengthField.text)
                            print("account is", newAccount, newAccount.name, newAccount.secret, newAccount.counter, newAccount.pinLength, newAccount.timeStep)
                            pageStack.pop();
                        }
                    }
                }
            }

            Flickable {
                id: settingsFlickable
                anchors.fill: parent
                contentHeight: settingsColumn.height + settingsColumn.anchors.margins * 2

                Column {
                    id: settingsColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: units.gu(2)
                    }
                    spacing: units.gu(2)

                    Label {
                        text: i18n.tr("Name")
                    }
                    TextField {
                        id: nameField
                        width: parent.width
                        text: account ? account.name : ""
                        placeholderText: i18n.tr("Enter the account name")
                        inputMethodHints: Qt.ImhNoPredictiveText
                    }

                    Label {
                        text: i18n.tr("Type")
                    }

                    OptionSelector {
                        id: typeSelector
                        width: parent.width
                        model: [i18n.tr("Counter based"), i18n.tr("Time based")]
                        selectedIndex: account && account.type === Account.TypeTOTP ? 1 : 0
                    }

                    Label {
                        text: i18n.tr("Key")
                    }
                    TextArea {
                        id: secretField
                        width: parent.width
                        text: account ? account.secret : ""
                        autoSize: true
                        wrapMode: Text.WrapAnywhere
                        // TRANSLATORS: placeholder text in key textfield
                        placeholderText: i18n.tr("Enter the 16 or 32 digit key")
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                    }
                    Row {
                        width: parent.width
                        spacing: units.gu(1)
                        visible: typeSelector.selectedIndex == 0

                        Label {
                            text: i18n.tr("Counter")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        TextField {
                            id: counterField
                            text: account ? account.counter : 0
                            width: parent.width - x
                            inputMask: "0009"
                            inputMethodHints: Qt.ImhDigitsOnly
                        }
                    }
                    Row {
                        width: parent.width
                        spacing: units.gu(1)
                        visible: typeSelector.selectedIndex == 1

                        Label {
                            text: i18n.tr("Time step")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        TextField {
                            id: timeStepField
                            text: account ? account.timeStep : 30
                            width: parent.width - x
                            inputMask: "0009"
                            inputMethodHints: Qt.ImhDigitsOnly
                        }
                    }
                    Row {
                        width: parent.width
                        spacing: units.gu(1)

                        Label {
                            text: i18n.tr("PIN length")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        TextField {
                            id: pinLengthField
                            text: account ? account.pinLength : 6
                            width: parent.width - x
                            inputMask: "0D"
                            inputMethodHints: Qt.ImhDigitsOnly
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

    AccountModel {
        id: accounts
    }

    Component {
        id: grabCodeComponent
        Page {
            id: grabCodePage
            title: i18n.tr("Scan QR code")

            QRCodeReader {
                id: qrCodeReader

                onValidChanged: {
                    if (valid) {
                        var account = accounts.createAccount();
                        account.name = qrCodeReader.accountName;
                        account.type = qrCodeReader.type;
                        account.secret = qrCodeReader.secret;
                        account.counter = qrCodeReader.counter;
                        account.timeStep = qrCodeReader.timeStep;
                        account.pinLength = qrCodeReader.pinLength;
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
                text: i18n.tr("Scan a QR Code containing account information")
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
        id: removeQuestionComponent
        Dialog {
            id: removeQuestionDialog
            title: i18n.tr("Remove account?")
            text: i18n.tr("Are you sure you want to remove %1?").arg(account.name)

            property QtObject account

            signal accepted()
            signal rejected()

            Button {
                text: i18n.tr("Yes")
                onClicked: {
                    PopupUtils.close(removeQuestionDialog);
                    removeQuestionDialog.accepted();
                }
                color: UbuntuColors.green
            }
            Button {
                text: i18n.tr("Cancel")
                onClicked: {
                    PopupUtils.close(removeQuestionDialog);
                    removeQuestionDialog.rejected();
                }
                color: UbuntuColors.red
            }
        }
    }
}
