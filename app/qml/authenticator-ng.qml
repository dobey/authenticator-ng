/*****************************************************************************
 * Copyright: 2013 Michael Zanetti <michael_zanetti@gmx.net>                 *
 *                                                                           *
 * This project is free software: you can redistribute it and/or modify       *
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

import QtQuick 2.4
import QtQuick.Layouts 1.1
/*
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Popups 1.3
*/
import OAth 1.0
import QtMultimedia 5.0
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0

Item {
    id: root

    //applicationName: "authenticator-ng.dobey"

    width: 320 // units.gu(40)
    height: 560 // units.gu(70)

    StackView {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: pageStack.push(mainPage)
    }

    Page {
        id: mainPage
        visible: false
        anchors.fill: parent

        header: ToolBar {
            width: parent.width
            height: 48

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4

                RowLayout {
                    anchors.right: parent.right
                    Layout.alignment: Qt.AlignRight

                    ToolButton {
                        //tooltip: "Add account"
                        Image {
                            anchors.margins: 8
                            anchors.fill: parent
                            source: "qrc:///add"
                        }
                        onClicked: {
                            pageStack.push(editSheetComponent)
                        }
                    }
                    ToolButton {
                        //tooltip: "Scan QR code"
                        Image {
                            anchors.margins: 8
                            anchors.fill: parent
                            source: "qrc:///camera"
                        }
                        onClicked: {
                            pageStack.push(grabCodeComponent)
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#ededed"
        }

        Rectangle {
            anchors.top: parent.top
            color: "#333333"
            width: parent.width
            height: 1
        }

        ListView {
            id: accountsListView
            anchors.fill: parent
            model: accounts
            interactive: contentHeight > height - 48 //units.gu(6) //FIXME: -6gu because of the panel being locked to open

            delegate: RowLayout {
                id: accountDelegate
                height: 72 //units.gu(12)
                width: parent.width

                property bool activated: false

/*
                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "delete"
                            text: i18n.tr("Delete")
                            onTriggered: {
                                var popup = PopupUtils.open(removeQuestionComponent, accountsListView, {account: accounts.get(index)})
                                popup.accepted.connect(function() { accounts.deleteAccount(index); });
                                popup.rejected.connect(function() { accounts.refresh(); });
                            }
                        }
                    ]
                }

                trailingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "edit-copy"
                            text: i18n.tr("Copy")
                            visible: accountDelegate.activated || type === Account.TypeTOTP
                            onTriggered: {
                                accountDelegate.copyToClipBoard()
                            }
                        },
                        Action {
                            iconName: "edit"
                            text: i18n.tr("Edit")
                            onTriggered: {
                                pageStack.push(editSheetComponent, {account: accounts.get(index)})
                            }
                        }
                    ]
                }
*/
                function copyToClipBoard() {
                    Clipboard.push(["text/plain", otpLabel.text]);
                    PopupUtils.open(copiedPopover, copy)
                }

/*
                Component {
                    id: copiedPopover

                    Popover {
                        id: popover
                        contentWidth: copy.width - units.gu(4)
                        contentHeight: units.gu(4)

                        Label {
                            anchors {
                                fill: parent
                                margins: units.gu(1)
                            }
                            horizontalAlignment: Text.AlignHCenter
                            text: i18n.tr("Copied")
                            fontSize: "x-small"
                        }

                        Timer {
                            interval: 3000; running: true;
                            onTriggered: popover.hide()
                        }
                    }
                }
*/

                GridLayout {
                    id: delegateColumn
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        leftMargin: 16 //units.gu(2)
                        topMargin: 8 //units.gu(2)
                        rightMargin: refreshButton.width + 16 /*units.gu(2)*/ + (refreshButton.visible ? 8 /*units.gu(1)*/ : 0)
                    }
                    rowSpacing: 2 //units.gu(1)
                    columnSpacing: 2 //units.gu(1)
                    height: parent.height - anchors.topMargin * 2
                    columns: 1

                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: name
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Label {
                        id: otpLabel
                        Layout.fillHeight: true
                        Layout.preferredWidth: delegateColumn.width
                        font.family: "mono"
                        font.pixelSize: 24
                        text: accountDelegate.activated || type === Account.TypeTOTP ? otp : "------"
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            id: copy
                            anchors {
                                left: parent.left
                                bottom: parent.bottom
                            }
                            width: parent.contentWidth
                            height: parent.contentHeight
                            onClicked: {
                                accountDelegate.copyToClipBoard()
                            }
                        }
                    }
                }

                Item {
                    id: refreshButton
                    anchors {
                        right: parent.right
                        rightMargin: 16 //units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                    height: parent.height //units.gu(4)
                    width: height

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:///reload"
                        visible: type === Account.TypeHOTP
                        height: 32
                        width: height
                        //color: otpLabel.color
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                accounts.generateNext(index);
                                accountDelegate.activated = true;
                            }
                        }
                    }

                    Item {
                        id: progressCircle
                        anchors.centerIn: parent
                        anchors.rightMargin: 16 //units.dp(4)
                        height: 32
                        width: height
                        visible: type === Account.TypeTOTP
                        property real progress: 0

                        Timer {
                            interval: 100
                            running: type === Account.TypeTOTP
                            repeat: true
                            onTriggered: {
                                var duration = accounts.get(index).msecsToNext();
                                progressCircle.progress = ((timeStep * 1000) - duration) / (timeStep * 1000)
                            }
                        }

                        Canvas {
                            id: canvas
                            anchors.fill: parent
                            rotation: -90

                            property real progress: progressCircle.progress
                            onProgressChanged: {
                                canvas.requestPaint()
                            }

                            onPaint: {
                                var ctx = canvas.getContext("2d");
                                ctx.save();
                                ctx.reset();
                                var data = [1 - progress, progress];
                                var myTotal = 0;

                                for(var e = 0; e < data.length; e++) {
                                    myTotal += data[e];
                                }

                                ctx.fillStyle = otpLabel.color;

                                ctx.beginPath();
                                ctx.moveTo(canvas.width / 2, canvas.height / 2);
                                //console.log(canvas.width / 2, canvas.height / 2, canvas.height / 2, 0, (Math.PI * 2 * ((1 - progress) / myTotal)), false);
                                ctx.arc(canvas.width / 2, canvas.height / 2,
                                        canvas.height / 2, 0, 
                                        (Math.PI * 2 * ((1 - progress) / myTotal)),
                                        false);
                                ctx.lineTo(canvas.width/2,canvas.height/2);
                                ctx.fill();
                                ctx.closePath();

                                ctx.restore();
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: editSheetComponent
        Page {
            id: editPage
            property QtObject account: null

/*
            header: PageHeader {
                title: account == null ? i18n.tr("Add account") : i18n.tr("Edit account")
                trailingActionBar.actions: [
                    Action {
                        iconName: "tick"
                        enabled: nameField.displayText.length > 0 && secretField.displayText.length >= 16
                        onTriggered: {
                            var newAccount = account;
                            if (newAccount == null) {
                                newAccount = accounts.createAccount()
                            }

                            newAccount.name = nameField.text
                            newAccount.type = typeSelector.currentIndex == 1 ? Account.TypeTOTP : Account.TypeHOTP
                            newAccount.secret = secretField.text
                            newAccount.counter = parseInt(counterField.text)
                            newAccount.timeStep = parseInt(timeStepField.text)
                            newAccount.pinLength = parseInt(pinLengthField.text)
                            print("account is", newAccount, newAccount.name, newAccount.secret, newAccount.counter, newAccount.pinLength, newAccount.timeStep)
                            pageStack.pop();
                        }
                    }
                ]
            }
*/

            Flickable {
                id: settingsFlickable
                anchors.fill: parent
                anchors.topMargin: editPage.header.height
                contentHeight: settingsColumn.height + settingsColumn.anchors.margins * 2

                Column {
                    id: settingsColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 16 //units.gu(2)
                    }
                    spacing: 16 //units.gu(2)

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

                    ComboBox {
                        id: typeSelector
                        width: parent.width
                        editable: false
                        model: [i18n.tr("Counter based"), i18n.tr("Time based")]
                        currentIndex: account && account.type === Account.TypeTOTP ? 1 : 0
                    }

                    Label {
                        text: i18n.tr("Key")
                    }
                    TextArea {
                        id: secretField
                        width: parent.width
                        text: account ? account.secret : ""
                        //autoSize: true
                        wrapMode: Text.WrapAnywhere
                        // TRANSLATORS: placeholder text in key textfield
                        placeholderText: i18n.tr("Enter the 16 or 32 digit key")
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                    }
                    Row {
                        width: parent.width
                        spacing: 4 //units.gu(1)
                        visible: typeSelector.currentIndex == 0

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
                        spacing: 4 //units.gu(1)
                        visible: typeSelector.currentIndex == 1

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
                        spacing: 4 //units.gu(1)

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
            title: "Scan QR code"

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

                focus.focusMode: Camera.FocusContinuous
                focus.focusPointMode: Camera.FocusPointAuto

                /* Use only digital zoom for now as it's what phone cameras mostly use.
                       TODO: if optical zoom is available, maximumZoom should be the combined
                       range of optical and digital zoom and currentZoom should adjust the two
                       transparently based on the value. */
                property alias currentZoom: camera.digitalZoom
                property alias maximumZoom: camera.maximumDigitalZoom

                function startAndConfigure() {
                    start();
                    focus.focusMode = Camera.FocusContinuous
                    focus.focusPointMode = Camera.FocusPointAuto
                }


                Component.onCompleted: {
                    captureTimer.start()
                }
            }
            Connections {
                target: Qt.application
                onActiveChanged: if (Qt.application.active) camera.startAndConfigure()
            }

            Timer {
                id: captureTimer
                interval: 3000
                repeat: true
                onTriggered: {
                    print("capturing");
                    qrCodeReader.grab();
                }
                onRunningChanged: {
                    if (running) {
                        camera.startAndConfigure();
                    } else {
                        camera.stop();
                    }
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
                    margins: 4 //units.gu(1)
                }
                text: ("Scan a QR Code containing account information")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 16
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
            title: ("Remove account?")
            contentItem: Label {
                text: ("Are you sure you want to remove %1?").arg(account.name)
            }

            property QtObject account

            signal accepted()
            signal rejected()

            Button {
                text: ("Yes")
                onClicked: {
                    PopupUtils.close(removeQuestionDialog);
                    removeQuestionDialog.accepted();
                }
                //color: UbuntuColors.green
            }
            Button {
                text: ("Cancel")
                onClicked: {
                    PopupUtils.close(removeQuestionDialog);
                    removeQuestionDialog.rejected();
                }
                //color: UbuntuColors.red
            }
        }
    }
}
