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

#ifndef NEXTCLOUD_THEME_H
#define NEXTCLOUD_THEME_H

#include "theme.h"

#include <QString>
#include <QPixmap>
#include <QIcon>
#include <QApplication>

#include "version.h"
#include "config.h"


namespace OCC {

/**
 * @brief The NextcloudTheme class
 * @ingroup libsync
 */
class NextcloudTheme : public Theme
{

public:
    NextcloudTheme() {};

    QString configFileName() const  {
        return QLatin1String("nextcloud.cfg");
    }

    QIcon trayFolderIcon( const QString& ) const  {
        return themeIcon( QLatin1String("nextcloud-icon") );
    }
    QIcon applicationIcon() const  {
        return themeIcon( QLatin1String("nextcloud-icon") );
    }

};

}
#endif // NEXTCLOUD_THEME_H
