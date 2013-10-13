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

#include "accountmodel.h"

#include "account.h"

#include <QSettings>
#include <QStringList>
#include <QDebug>

AccountModel::AccountModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QSettings settings;
    qDebug() << "loading settings file:" << settings.fileName();
    foreach(const QString & group, settings.childGroups()) {
        qDebug() << "found group" << group;
        settings.beginGroup(group);
        Account *account = new Account(this);
        account->setName(settings.value("account").toString());
        account->setSecret(settings.value("secret").toString());
        account->setCounter(settings.value("counter").toInt());
        account->setPinLength(settings.value("pinLength").toInt());
        m_accounts.append(account);
        settings.endGroup();
    }
}

int AccountModel::rowCount(const QModelIndex &parent) const
{
    return m_accounts.count();
}

QVariant AccountModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_accounts.at(index.row())->name();
    case RoleSecret:
        return m_accounts.at(index.row())->secret();
    case RoleCounter:
        return m_accounts.at(index.row())->counter();
    case RolePinLength:
        return m_accounts.at(index.row())->pinLength();
    case RoleTotp:
        return m_accounts.at(index.row())->totp();
    }

    return QVariant();
}

Account *AccountModel::get(int index) const
{
    return m_accounts.at(index);
}

Account *AccountModel::createAccount()
{
    Account *account = new Account(this);
    beginInsertRows(QModelIndex(), m_accounts.count(), m_accounts.count());
    m_accounts.append(account);
    connect(account, SIGNAL(nameChanged()), SLOT(accountChanged()));
    connect(account, SIGNAL(secretChanged()), SLOT(accountChanged()));
    connect(account, SIGNAL(counterChanged()), SLOT(accountChanged()));
    connect(account, SIGNAL(pinLengthChanged()), SLOT(accountChanged()));
    connect(account, SIGNAL(totpChanged()), SLOT(accountChanged()));

    storeAccount(account);

    endInsertRows();
    return account;
}

void AccountModel::deleteAccount(int index)
{
    beginRemoveRows(QModelIndex(), index, index);

    QSettings settings;
    settings.beginGroup(QString::number(index));
    settings.remove("");
    settings.endGroup();

    m_accounts.takeAt(index)->deleteLater();

    endRemoveRows();
}

void AccountModel::deleteAccount(Account *account)
{
    int index = m_accounts.indexOf(account);
    deleteAccount(index);
}

QHash<int, QByteArray> AccountModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    roles.insert(RoleSecret, "secret");
    roles.insert(RoleCounter, "counter");
    roles.insert(RolePinLength, "pinLength");
    roles.insert(RoleTotp, "totp");
    return roles;
}

void AccountModel::generateNext(int account)
{
    m_accounts.at(account)->next();
    emit dataChanged(index(account), index(account), QVector<int>() << RoleCounter << RoleTotp);
}

void AccountModel::accountChanged()
{
    Account *account = qobject_cast<Account*>(sender());
    storeAccount(account);

    qDebug() << "account changed";
    int accountIndex = m_accounts.indexOf(account);
    emit dataChanged(index(accountIndex), index(accountIndex));
}

void AccountModel::storeAccount(Account *account)
{
    QSettings settings;
    settings.beginGroup(QString::number(m_accounts.indexOf(account)));
    settings.setValue("account", account->name());
    settings.setValue("secret", account->secret());
    settings.setValue("counter", account->counter());
    settings.setValue("pinLength", account->pinLength());
    settings.endGroup();
    qDebug() << "saved to" << settings.fileName();

}
