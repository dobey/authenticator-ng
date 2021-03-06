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

#include "accountmodel.h"
#include "account.h"
#include "qrcodereader.h"

#include <QApplication>
#include <QtQuick/QQuickView>
#include <QtQml/QtQml>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    QQuickView view;

    qmlRegisterType<AccountModel>("OAth", 1, 0, "AccountModel");
    qmlRegisterUncreatableType<Account>("OAth", 1, 0, "Account", "Use AccountModel::createAccount() to create a new account");
    qmlRegisterType<QRCodeReader>("OAth", 1, 0, "QRCodeReader");

    view.setTitle("Authenticator");
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl("qrc:///qml/authenticator-ng.qml"));
    view.show();

    return a.exec();
}
