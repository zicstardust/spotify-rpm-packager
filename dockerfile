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
        nginx \
        createrepo_c \
        gpg \
        python3-dnf \
        rpm-sign \
        mock; \
    dnf clean all; \
    \
    rm -f /etc/nginx/nginx.conf;

COPY nginx.conf /etc/nginx/nginx.conf


VOLUME [ "/data" ]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["run.sh"]
