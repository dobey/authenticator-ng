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

#include "account.h"

#include <QDebug>

#define SIZE_MAX UINT_MAX
extern "C" {
#include "oath.h"
}

Account::Account(QObject *parent) :
    QObject(parent),
    m_counter(0),
    m_pinLength(6)
{
}

QString Account::name() const
{
    return m_name;
}

void Account::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

QString Account::secret() const
{
    return m_secret;
}

void Account::setSecret(const QString &secret)
{
    if (m_secret != secret) {
        m_secret = secret;
        emit secretChanged();
        generate();
    }
}

quint64 Account::counter() const
{
    return m_counter;
}

void Account::setCounter(quint64 counter)
{
    if (m_counter != counter) {
        m_counter = counter;
        emit counterChanged();
        generate();
    }
}

int Account::pinLength() const
{
    return m_pinLength;
}

void Account::setPinLength(int pinLength)
{
    if (m_pinLength != pinLength) {
        m_pinLength = pinLength;
        emit pinLengthChanged();
        generate();
    }
}

QString Account::totp() const
{
    return m_totp;
}

void Account::next()
{
    m_counter++;
    emit counterChanged();
    generate();
}

void Account::generate()
{
    if (m_secret.isEmpty()) {
        qWarning() << "No secret set. Cannot generate totp.";
        return;
    }

    if (m_pinLength <= 0) {
        qWarning() << "Pin length is" << m_pinLength << ". Cannot generate totp.";
        return;
    }

    char code[6];
    oath_hotp_generate(m_secret.toLatin1().data(), m_secret.length(), m_counter, m_pinLength, false, OATH_HOTP_DYNAMIC_TRUNCATION, code);

    m_totp = QLatin1String(code);
//    qDebug() << "Generating secret" << m_name << m_secret << m_counter << m_pinLength << m_totp;
    emit totpChanged();

}
