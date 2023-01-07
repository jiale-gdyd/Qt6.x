# Generated from kmsconvenience.pro.

# qt_find_package(Libdrm) # special case

#####################################################################
## KmsSupportPrivate Module:
#####################################################################

# qt_internal_add_module(KmsSupportPrivate
#     CONFIG_MODULE_NAME kms_support
#     STATIC
#     INTERNAL_MODULE
#     SOURCES
#         qkmsdevice.cpp qkmsdevice_p.h
#     DEFINES
#         QT_NO_CAST_FROM_ASCII
#     PUBLIC_LIBRARIES
#         Libdrm::Libdrm
#         Qt::CorePrivate
#         Qt::GuiPrivate
# )

qt_internal_add_module(KmsSupportPrivate
    CONFIG_MODULE_NAME kms_support
    STATIC
    INTERNAL_MODULE
    SOURCES
        qkmsdevice.cpp qkmsdevice_p.h
        xf86drm.c xf86drm.h libdrm_macros.h drm_fourcc.h util_math.h
        xf86drmHash.c libdrm_macros.h xf86drm.h xf86drmHash.h
        xf86drmMode.c libdrm_macros.h xf86drmMode.h xf86drm.h drm.h drm_fourcc.h
        xf86drmRandom.c libdrm_macros.h xf86drm.h xf86drmRandom.h
        xf86drmSL.c libdrm_macros.h xf86drm.h
    DEFINES
        QT_NO_CAST_FROM_ASCII
    PUBLIC_LIBRARIES
        Qt::CorePrivate
        Qt::GuiPrivate
)

#### Keys ignored in scope 1:.:.:kmsconvenience.pro:<TRUE>:
# MODULE = "kms_support"
