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

#ifndef ACCOUNTMODEL_H
#define ACCOUNTMODEL_H

#include <QAbstractListModel>

class Account;

class AccountModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        RoleName,
        RoleSecret,
        RoleCounter,
        RolePinLength,
        RoleTotp
    };

    explicit AccountModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE Account *get(int index) const;
    Q_INVOKABLE Account *createAccount();
    Q_INVOKABLE void deleteAccount(int index);
    Q_INVOKABLE void deleteAccount(Account *account);


public slots:
    void generateNext(int account);

private slots:
    void accountChanged();
    void storeAccount(Account *account);

private:
    QList<Account*> m_accounts;
};

#endif // ACCOUNTMODEL_H
