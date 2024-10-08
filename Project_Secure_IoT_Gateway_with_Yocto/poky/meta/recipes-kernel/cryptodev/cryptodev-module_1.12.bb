require cryptodev.inc

SUMMARY = "A /dev/crypto device driver kernel module"

inherit module

# Header file provided by a separate package
DEPENDS += "cryptodev-linux"

SRC_URI += "file://0001-Disable-installing-header-file-provided-by-another-p.patch \
            file://0001-Fix-build-for-linux-5.10.220.patch \
           "

EXTRA_OEMAKE='KERNEL_DIR="${STAGING_KERNEL_DIR}" PREFIX="${D}"'

RCONFLICTS:${PN} = "ocf-linux"
RREPLACES:${PN} = "ocf-linux"
