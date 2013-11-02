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

#ifndef QRCODEREADER_H
#define QRCODEREADER_H

#include <QObject>
#include <QQuickWindow>
#include <QThread>

class QRCodeReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(QString accountName READ accountName NOTIFY validChanged)
    Q_PROPERTY(QString secret READ secret NOTIFY validChanged)
    Q_PROPERTY(quint64 counter READ counter NOTIFY validChanged)

public:
    explicit QRCodeReader(QObject *parent = 0);

    bool valid() const;
    QString accountName() const;
    QString secret() const;
    quint64 counter() const;

public slots:
    void grab();

signals:
    void validChanged();

private slots:
    void handleResults(const QString &type, const QString &text);

private:
    QQuickWindow *m_mainWindow;

    QString m_accountName;
    QString m_secret;
    quint64 m_counter;

    QThread m_readerThread;
};

class Reader : public QObject
{
    Q_OBJECT

public slots:
    void doWork(const QImage &image);

signals:
    void resultReady(const QString &type, const QString &text);
};

#endif // QRCODEREADER_H
