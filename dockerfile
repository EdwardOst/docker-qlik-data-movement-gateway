# syntax=docker/dockerfile:1

ARG base_image=edwardost/ubi8
ARG base_tag=8.9-1160
ARG qlik_user=qlik
ARG qlik_tenant=obd

FROM ${base_image}:${base_tag} AS gateway_instance

  ARG dnf_command
  ARG qlik_user
  ARG qlik_tenant

  ARG qlik_package=qlik-data-gateway-data-movement_2023.11-4_x86_64.rpm
  ARG qlik_package_version=2023.11-4
  ARG qlik_package_platform=x86_64

  ARG dnf_command=dnf

  LABEL maintainer="eost@qlik.com"
  LABEL qlik_package_version="${qlik_package_version}"
  LABEL qlik_package_platform="${qlik_package_platform}"
  LABEL qlik_tenant="${qlik_tenant}"

  ENV QLIK_TENANT=${qlik_tenant}
  ENV QLIK_PACKAGE_VERSION=${qlik_package_version}
  ENV QLIK_PACKAGE_PLATFORM=${qlik_package_platform}

  EXPOSE 3552/tcp

  ADD --chown=${qlik_user}:${qlik_user} "${qlik_package}" "${qlik_package}"
  COPY --chmod=740 --chown=${qlik_user}:${qlik_user} repagent-start.sh "./"

  RUN \
    sudo ${dnf_command} install -y cpio \
    && sudo ${dnf_command} install -y python3 \
    && sudo mkdir -p /opt/qlik \ 
    && sudo chown "${qlik_user}:${qlik_user}" /opt/qlik \
    && rpm2cpio "${qlik_package}" | cpio -idmv -D / \
    && cd /opt/qlik/gateway/movement/bin \
    && ./agentctl qcs set_config --tenant_url "${qlik_tenant}.us.qlikcloud.com" \
    && echo "# enter site specific settings here" > /opt/qlik/gateway/movement/bin/site_arep_login.sh \
    && iport=3550 rport=3552 verbose=true tenant_url="${tenant_url}" systemd_disabled=1 ./arep.sh install repagent \
    && cd /opt/qlik/gateway/movement/drivers/bin \
    && sudo ./install mysql -a \
    && sudo ./install postgres -a \
    && sudo ./install snowflake -a

  CMD [ "/home/qlik/repagent-start.sh" ]
