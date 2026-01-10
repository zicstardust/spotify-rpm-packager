FROM fedora:43


COPY src/RPM_SOURCES/* /SOURCES/


COPY src/download_deb.sh \
    src/remove_old_rpms.sh \
    src/parser_debian_control_file.py \
    src/set_rpmmacros.sh \
    src/generate_gpg.sh \
    src/generate_spec.sh \
    src/build_SRPMS.sh \
    src/build_RPMS_mock.sh \
    src/run.sh \
    src/cleanup.sh \
    /usr/local/bin/

COPY entrypoint.sh /entrypoint.sh

RUN chmod -R +x /SOURCES/*.sh /usr/local/bin/* /entrypoint.sh; \
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
    && sed -i 's|/var/www/html|/data|' /etc/httpd/conf/httpd.conf


VOLUME [ "/data" ]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["run.sh"]
