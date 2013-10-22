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

Account::Account(const QUuid &id, QObject *parent) :
    QObject(parent),
    m_id(id),
    m_counter(0),
    m_pinLength(6)
{
}

QUuid Account::id() const
{
    return m_id;
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

QString Account::otp() const
{
    return m_otp;
}

void Account::next()
{
    m_counter++;
    qDebug() << "emitting changed";
    emit counterChanged();
    generate();
}

void Account::generate()
{
    if (m_secret.isEmpty()) {
        qWarning() << "No secret set. Cannot generate otp.";
        return;
    }

    if (m_pinLength <= 0) {
        qWarning() << "Pin length is" << m_pinLength << ". Cannot generate otp.";
        return;
    }

    QByteArray hexSecret = fromBase32(m_secret.toLatin1());
    qDebug() << "hexSecret" << hexSecret;
    char code[6];
    oath_hotp_generate(hexSecret.data(), hexSecret.length(), m_counter, m_pinLength, false, OATH_HOTP_DYNAMIC_TRUNCATION, code);

    m_otp = QLatin1String(code);
    //    qDebug() << "Generating secret" << m_name << m_secret << m_counter << m_pinLength << m_otp;
    emit otpChanged();

}

QByteArray Account::fromBase32(const QByteArray &input)
{
    int buffer = 0;
    int bitsLeft = 0;
    int count = 0;

    QByteArray result;

    for (int i = 0; i < input.length(); ++i) {

        char ch = input.at(i);

        if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n' || ch == '-') {
            continue;
        }
        buffer <<= 5;

        if (ch == '0') {
            ch = 'O';
        } else if (ch == '1') {
            ch = 'L';
        } else if (ch == '8') {
            ch = 'B';
        }

        if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z')) {
            ch = (ch & 0x1F) - 1;
        } else if (ch >= '2' && ch <= '7') {
            ch -= '2' - 26;
        } else {
            return QByteArray();
        }

        buffer |= ch;
        bitsLeft += 5;
        if (bitsLeft >= 8) {
            result[count++] = buffer >> (bitsLeft - 8);
            bitsLeft -= 8;
        }

    }

    return result;

}
