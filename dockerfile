FROM almalinux:10.2


COPY src/* /usr/local/bin/

COPY entrypoint.sh /entrypoint.sh

RUN chmod -R +x /usr/local/bin/*.sh /usr/local/bin/*.py /entrypoint.sh; \
    \
    dnf install -y epel-release; \
    /usr/bin/crb enable; \
    \
    dnf -y update; \
    \
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
        mock; \
    dnf clean all; \
    \
    rm -f /etc/httpd/conf.d/welcome.conf; \
    sed -i "s/User apache/User spotify/" /etc/httpd/conf/httpd.conf; \
    sed -i "s/Group apache/Group spotify/" /etc/httpd/conf/httpd.conf; \
    sed -i 's|/var/www/html|/data|' /etc/httpd/conf/httpd.conf


VOLUME [ "/data" ]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["run.sh"]
