FROM fedora:43

ENV PYTHONUNBUFFERED=1
ENV INTERVAL=1d
ENV DISABLE_WEB_SERVER=0


WORKDIR /home/spotify/rpmbuild/

RUN mkdir -p /home/spotify/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

COPY scripts/SOURCES/* /home/spotify/rpmbuild/SOURCES/

COPY scripts/download_deb.py \
    scripts/gpg-gen.sh \
    scripts/generate_spec.sh \
    scripts/build_rpm_src.sh \
    scripts/build_mock_rpms.sh \
    scripts/copy_rpm_to_repo.sh \
    scripts/run.sh \
    scripts/cleanup.sh \
    /usr/local/bin/

COPY entrypoint.sh /entrypoint.sh

RUN chmod -R +x /home/spotify/rpmbuild/SOURCES/*.sh /usr/local/bin/* /entrypoint.sh; \
    dnf -y update && \
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
