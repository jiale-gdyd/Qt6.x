#include "../rockchip/rga.h"
#include "../rockchip/RgaApi.h"

static inline RgaSURF_FORMAT
rga_get_format(QImage::Format format)
{
    switch (format) {
    case QImage::Format_ARGB32:
    case QImage::Format_ARGB32_Premultiplied:
        return RK_FORMAT_BGRA_8888;
    case QImage::Format_RGB16:
        return RK_FORMAT_RGB_565;
    default:
        return RK_FORMAT_UNKNOWN;
    }
}

static inline RgaSURF_FORMAT
rga_get_reverse_format(QImage::Format format)
{
    switch (format) {
    case QImage::Format_RGB32:
        return RK_FORMAT_RGBX_8888;
    case QImage::Format_ARGB32:
    case QImage::Format_ARGB32_Premultiplied:
        return RK_FORMAT_RGBA_8888;
    default:
        return RK_FORMAT_UNKNOWN;
    }
}

bool rga_fill(const uchar *dst, int dst_stride, int dst_height,
              QImage::Format format, int color,
              int x, int y, int w, int h) {
    if (c_RkRgaInit() < 0)
        return false;

    RgaSURF_FORMAT fmt = rga_get_format(format);
    if (fmt == RK_FORMAT_UNKNOWN) {
        if (format == QImage::Format_RGB32)
            fmt = RK_FORMAT_BGRA_8888;
        else
            return false;
    }

    if (fmt == RK_FORMAT_RGB_565)
        dst_stride /= 2;
    else
        dst_stride /= 4;

    rga_info_t info;
    memset(&info, 0, sizeof(info));
    info.fd = -1;
    info.virAddr = (void *)dst;
    info.mmuFlag = 1;
    rga_set_rect(&info.rect, x, y, w, h, dst_stride, dst_height, fmt);

    info.color = color;

    return c_RkRgaColorFill(&info) >= 0;
}

bool rga_blit(const uchar *src, int src_stride, int src_height,
              const uchar *dst, int dst_stride, int dst_height,
              QImage::Format src_format, QImage::Format dst_format,
              int sx, int sy, int dx, int dy, int width, int height,
              QPainter::CompositionMode mode, int alpha) {
    if (c_RkRgaInit() < 0)
        return false;

    RgaSURF_FORMAT src_fmt = rga_get_format(src_format);
    RgaSURF_FORMAT dst_fmt = rga_get_format(dst_format);
    if (src_fmt == RK_FORMAT_UNKNOWN || dst_fmt == RK_FORMAT_UNKNOWN) {
        src_fmt = rga_get_reverse_format(src_format);
        dst_fmt = rga_get_reverse_format(dst_format);
        if (src_fmt == RK_FORMAT_UNKNOWN || dst_fmt == RK_FORMAT_UNKNOWN)
            return false;
    }

    if (src_fmt == RK_FORMAT_RGB_565)
        src_stride /= 2;
    else
        src_stride /= 4;

    if (dst_fmt == RK_FORMAT_RGB_565)
        dst_stride /= 2;
    else
        dst_stride /= 4;

    int blend = ((alpha * 255) >> 8) << 16;
    if (mode == QPainter::CompositionMode_Source)
        blend |= 0x0100;
    else if (src_format == QImage::Format_ARGB32_Premultiplied)
        blend |= 0x0105;
    else
        blend |= 0x0405;

    rga_info_t src_info;
    memset(&src_info, 0, sizeof(src_info));
    src_info.fd = -1;
    src_info.virAddr = (void *)src;
    src_info.mmuFlag = 1;
    rga_set_rect(&src_info.rect, sx, sy, width, height,
                 src_stride, src_height, src_fmt);

    rga_info_t dst_info;
    memset(&dst_info, 0, sizeof(dst_info));
    dst_info.fd = -1;
    dst_info.virAddr = (void *)dst;
    dst_info.mmuFlag = 1;
    rga_set_rect(&dst_info.rect, dx, dy, width, height,
                 dst_stride, dst_height, dst_fmt);

    src_info.blend = blend;

    return c_RkRgaBlit(&src_info, &dst_info, NULL) >= 0;
}