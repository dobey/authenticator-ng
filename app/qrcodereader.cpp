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

#include "qrcodereader.h"

#include <../3rdParty/QZBarImage.h>
#include <ImageScanner.h>

#include <QGuiApplication>
#include <QWindow>
#include <QDebug>
#include <QUrlQuery>

QRCodeReader::QRCodeReader(QObject *parent) :
    QObject(parent),
    m_mainWindow(0),
    m_counter(0)
{
    QGuiApplication *app = qobject_cast<QGuiApplication*>(qApp);

    foreach (QWindow *win, app->allWindows()) {
        QQuickWindow *quickWin = qobject_cast<QQuickWindow*>(win);
        if (quickWin) {
            m_mainWindow = quickWin;
        }
    }
}

bool QRCodeReader::valid() const
{
    return !m_accountName.isEmpty() && !m_secret.isEmpty();
}

QString QRCodeReader::accountName() const
{
    return m_accountName;
}

QString QRCodeReader::secret() const
{
    return m_secret;
}

quint64 QRCodeReader::counter() const
{
    return m_counter;
}

void QRCodeReader::grab()
{
    if (!m_mainWindow) {
        return;
    }

    m_accountName.clear();
    m_secret.clear();
    m_counter = 0;
    emit validChanged();

    QImage img = m_mainWindow->grabWindow();

    qDebug() << "got image" << img.size();

    Reader *reader = new Reader;
    reader->moveToThread(&m_readerThread);
    connect(&m_readerThread, SIGNAL(finished()), reader, SLOT(deleteLater()));
    connect(reader, SIGNAL(resultReady(QString, QString)), this, SLOT(handleResults(QString, QString)));
    m_readerThread.start();

    QMetaObject::invokeMethod(reader, "doWork", Q_ARG(QImage, img));
}

void QRCodeReader::handleResults(const QString &type, const QString &text)
{
    qDebug() << "parsed:" << type << text;

    if (type == "QR-Code" && text.startsWith(QStringLiteral("otpauth://hotp/"))) {
        QUrl url(text);

        qDebug() << url.host() << url.path() << url.query();

        m_accountName = url.path();
        if (m_accountName.startsWith('/')) {
            m_accountName.remove(0, 1);
        }

        QUrlQuery query(url.query());

        for (int i = 0; i < query.queryItems().count(); ++i) {
            if (query.queryItems().at(i).first == "secret") {
                m_secret = query.queryItems().at(i).second;
            }
            if (query.queryItems().at(i).first == "counter") {
                m_counter = query.queryItems().at(i).second.toULong();
            }
        }

        qDebug() << "Account:" << m_accountName;
        qDebug() << "Secret:" << m_secret;
        qDebug() << "Counter:" << m_counter;

        emit validChanged();

    }

}

void Reader::doWork(const QImage &image)
{

    zbar::QZBarImage img(image);
    zbar::Image tmp = img.convert(*(long*)"Y800");

    // create a reader
    zbar::ImageScanner scanner;

    // configure the reader
    scanner.set_config(zbar::ZBAR_QRCODE, zbar::ZBAR_CFG_ENABLE, 1);

    // scan the image for barcodes
    int n = scanner.scan(tmp);
    qDebug() << "scanner ret" << n;

    img.set_symbols(tmp.get_symbols());

    // extract results
    for(zbar::Image::SymbolIterator symbol = img.symbol_begin();
        symbol != img.symbol_end();
        ++symbol) {

        QString typeName = QString::fromStdString(symbol->get_type_name());
        QString symbolString = QString::fromStdString(symbol->get_data());

        qDebug() << "Code recognized:" << typeName << ", Text:" << symbolString;

        emit resultReady(typeName, symbolString);
    }

    tmp.set_data(NULL, 0);
    img.set_data(NULL, 0);

}
