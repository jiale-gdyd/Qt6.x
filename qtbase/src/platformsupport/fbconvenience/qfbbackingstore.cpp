// Copyright (C) 2016 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

#include "qfbbackingstore_p.h"
#include "qfbwindow_p.h"
#include "qfbscreen_p.h"

#include <qpa/qplatformwindow.h>
#include <QtGui/qscreen.h>
#include <QtGui/qpainter.h>

QT_BEGIN_NAMESPACE

QImage * QFbBackingStore::gScreenImage = NULL;
QImage * QFbBackingStore::gFbImage = NULL;

QFbBackingStore::QFbBackingStore(QWindow *window)
    : QPlatformBackingStore(window)
{
    if (window->handle())
        (static_cast<QFbWindow *>(window->handle()))->setBackingStore(this);
    else
        (static_cast<QFbScreen *>(window->screen()->handle()))->addPendingBackingStore(this);
}

QFbBackingStore::~QFbBackingStore()
{
}

void QFbBackingStore::flush(QWindow *window, const QRegion &region, const QPoint &offset)
{
    Q_UNUSED(window);
    Q_UNUSED(offset);

    (static_cast<QFbWindow *>(window->handle()))->repaint(region);
}

void QFbBackingStore::resize(const QSize &size, const QRegion &staticContents)
{
    Q_UNUSED(staticContents);

    if (mImage.size() != size)
        mImage = QImage(size, window()->screen()->handle()->format());
}

QPaintDevice *QFbBackingStore::paintDevice()
{
    // HACK: gScreenImage available means allowing directly painting
    if (!gScreenImage)
        return &mImage;

    // HACK: Prefer directly painting to fb when it's available
    if (gFbImage)
        return gFbImage;

    return gScreenImage;
}

QImage QFbBackingStore::toImage() const
{
    if (!gScreenImage)
        return mImage;

    if (gFbImage)
        return *gFbImage;

    return *gScreenImage;
}

const QImage QFbBackingStore::image()
{
    return toImage();
}

void QFbBackingStore::lock()
{
    mImageMutex.lock();
}

void QFbBackingStore::unlock()
{
    mImageMutex.unlock();
}

void QFbBackingStore::beginPaint(const QRegion &region)
{
    lock();

    if (mImage.hasAlphaChannel()) {
        QPainter p(&mImage);
        p.setCompositionMode(QPainter::CompositionMode_Source);
        for (const QRect &r : region)
            p.fillRect(r, Qt::transparent);
    }
}

void QFbBackingStore::endPaint()
{
    unlock();
}

QT_END_NAMESPACE
