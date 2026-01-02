FROM almalinux:10.1

ENV PYTHONUNBUFFERED=1
ENV INTERVAL=1d
ENV DISABLE_WEB_SERVER=0

RUN dnf install -y epel-release

RUN dnf -y update && \
    dnf -y install \
    desktop-file-utils \
    python3 \
    make \
    rpm-build \
    rpmdevtools \
    binutils \
    gtk-update-icon-cache \
    util-linux \
    httpd \
    createrepo_c \
    gpg \
    python3-dnf \
    rpm-sign \
    mock \
    && dnf clean all \
    && rm -f /etc/httpd/conf.d/welcome.conf \
    && sed -i "s/User apache/User spotify/" /etc/httpd/conf/httpd.conf \
    && sed -i "s/Group apache/Group spotify/" /etc/httpd/conf/httpd.conf \
    && sed -i 's|/var/www/html|/data|' /etc/httpd/conf/httpd.conf \
    && sed -i 's|Listen 80|Listen 8080|' /etc/httpd/conf/httpd.conf

WORKDIR /build

COPY scripts/* .
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /build/start.sh /build/build_rpm.sh /build/copy_rpm_to_repo.sh /entrypoint.sh /build/gpg-gen.sh

VOLUME [ "/data" ]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/build/start.sh"]