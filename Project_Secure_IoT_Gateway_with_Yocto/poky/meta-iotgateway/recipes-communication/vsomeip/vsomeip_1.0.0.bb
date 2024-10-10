SUMMARY = "COVESA vsomeip"
DESCRIPTION = "vsomeip is a middleware for automotive communication based on the SOME/IP protocol."
HOMEPAGE = "https://github.com/COVESA/vsomeip"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "git://github.com/COVESA/vsomeip.git;branch=master;protocol=https"

SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

inherit cmake

# Dependencies
DEPENDS += "boost dlt-daemon"

EXTRA_OECMAKE += "\
    -DENABLE_SIGNAL_HANDLING=1 \
    -DDIAGNOSIS_ADDRESS=0x10 \
    -DUSE_DLT=1 \
"

# Specify the files to be included in the package
FILES:${PN} += "\
    ${libdir}/*.so* \
    ${includedir}/* \
    ${libdir}/cmake/* \
    ${libdir}/pkgconfig/* \
    ${sysconfdir}/vsomeip/* \
"

# Development files
FILES:${PN}-dev = "${includedir} ${libdir}/cmake ${libdir}/pkgconfig ${libdir}/*.so"

# Configuration files
CONFFILES:${PN} += "${sqysconfdir}/vsomeip/*"

do_install:append() {
    if [ -d ${D}/usr/etc ]; then
        install -d ${D}${sysconfdir}
        mv ${D}/usr/etc/vsomeip ${D}${sysconfdir}/
        rm -rf ${D}/usr/etc
    fi
}

BBCLASSEXTEND = "native nativesdk"