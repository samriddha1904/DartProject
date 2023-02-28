ARG VARIANT=2
FROM dart:${VARIANT}
ARG INSTALL_ZSH="${templateOption:installZsh}"
ARG UPGRADE_PACKAGES="${templateOption:upgradePackages}"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
ENV PUB_CACHE="/usr/local/share/pub-cache"
ENV PATH="${PUB_CACHE}/bin:${PATH}"
RUN if ! cat /etc/group | grep -e "^pub-cache:" > /dev/null 2>&1; then groupadd -r pub-cache; fi \
    && usermod -a -G pub-cache ${USERNAME} \
    && umask 0002 \
    && mkdir -p ${PUB_CACHE} \
    && chown :pub-cache ${PUB_CACHE} \
    && sed -i -e "s/export PATH=/export PATH=\/usr\/local\/share\/pub-cache:/" /etc/profile.d/00-restore-env.sh \
    && chmod 755 "$DART_SDK" "$DART_SDK/bin"
