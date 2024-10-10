SUMMARY = "Hello IoT Application"
DESCRIPTION = "A simple application demonstrating secure IoT communication using OpenSSL."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS = "openssl"

SRC_URI = "file://helloiotapp.cpp \
            file://server.crt \
            file://server.key \
            "

S = "${WORKDIR}"

do_compile() {
    ${CXX} ${CXXFLAGS} ${LDFLAGS} -o helloiotapp ${S}/helloiotapp.cpp -lssl -lcrypto
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 helloiotapp ${D}${bindir}/

    install -d ${D}${sysconfdir}/ssl/certs
    install -m 0644 server.crt ${D}${sysconfdir}/ssl/certs/

    install -d ${D}${sysconfdir}/ssl/private
    install -m 0600 server.key ${D}${sysconfdir}/ssl/private/
}

FILES_${PN} += "${sysconfdir}/ssl/certs/server.crt"
FILES_${PN} += "${sysconfdir}/ssl/private/server.key"