/*
 * Copyright (C) by Roeland Jago Douma <roeland@famdouma.nl>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 */

#ifndef STOWPAL_THEME_H
#define STOWPAL_THEME_H

#include "theme.h"

#include <QString>
#include <QPixmap>
#include <QIcon>
#include <QApplication>

#include "version.h"
#include "config.h"


namespace OCC {

/**
 * @brief The StowpalTheme class
 * @ingroup libsync
 */
class StowpalTheme : public Theme
{

public:
    StowpalTheme() {};

    QString configFileName() const  {
        return QLatin1String("stowpal.cfg");
    }

    QIcon trayFolderIcon( const QString& ) const  {
        return themeIcon( QLatin1String("Stowpal-icon") );
    }
    QIcon applicationIcon() const  {
        return themeIcon( QLatin1String("Stowpal-icon") );
    }

    QString updateCheckUrl() const {
        return QLatin1String("https://stowpal.com/updates/client/");
    }

    QString helpUrl() const {
        return QString::fromLatin1("https://docs.nextcloud.com/desktop/2.2/").arg(MIRALL_VERSION_MAJOR).arg(MIRALL_VERSION_MINOR);
    }

#ifndef TOKEN_AUTH_ONLY
    QColor wizardHeaderBackgroundColor() const {
        return QColor("#0082c9");
    }

    QColor wizardHeaderTitleColor() const {
        return QColor("#ffffff");
    }

    QPixmap wizardHeaderLogo() const {
        return QPixmap(hidpiFileName(":/client/theme/colored/wizard_logo.png"));
    }
#endif

    QString about() const {
        QString re;
        re = tr("<p>Version %1. For more information please visit <a href='%2'>%3</a>.</p>")
                .arg(MIRALL_VERSION_STRING).arg("http://" MIRALL_STRINGIFY(APPLICATION_DOMAIN))
                .arg(MIRALL_STRINGIFY(APPLICATION_DOMAIN));

        re += trUtf8("<p><small>By Klaas Freitag, Daniel Molkentin, Jan-Christoph Borchardt, "
                     "Olivier Goffart, Markus Götz and others.</small></p>");

        re += tr("<p>Distributed by %1 and licensed under the GNU General Public License (GPL) Version 2.0.<br/>"
             "%2 and the %2 Logo are registered trademarks of %1 in the "
             "European Union, other countries, or both.</p>")
            .arg(APPLICATION_VENDOR).arg(APPLICATION_NAME);

        re += gitSHA1();
        return re;
}

};

}
#endif // STOWPAL_THEME_H
