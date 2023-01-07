# Qt gui library, libdrm/rga module

HEADERS += \
        rockchip/im2d.h \
        rockchip/NormalRga.h \
        rockchip/NormalRgaContext.h \
        rockchip/rga.h \
        rockchip/RgaApi.h \
        rockchip/rgadbg.h \
        rockchip/drmrga.h \
        rockchip/RgaMutex.h \
        rockchip/RgaSingleton.h \
        rockchip/RgaUtils.h \
        rockchip/RockchipRga.h \
        rockchip/libdrm_lists.h \
        rockchip/libdrm_macros.h \
        rockchip/drm.h \
        rockchip/drm_fourcc.h \
        rockchip/drm_mode.h \
        rockchip/util_double_list.h \
        rockchip/util_math.h \
        rockchip/version.h \
        rockchip/xf86atomic.h \
        rockchip/xf86drm.h \
        rockchip/xf86drmHash.h \
        rockchip/xf86drmMode.h \
        rockchip/xf86drmRandom.h


SOURCES += \
        rockchip/im2d.cpp \
        rockchip/NormalRga.cpp \
        rockchip/NormalRgaApi.cpp \
        rockchip/RgaApi.cpp \
        rockchip/RgaUtils.cpp \
        rockchip/RockchipRga.cpp \
        rockchip/xf86drm.c \
        rockchip/xf86drmHash.c \
        rockchip/xf86drmMode.c \
        rockchip/xf86drmRandom.c \
        rockchip/xf86drmSL.c

