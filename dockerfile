# syntax=docker/dockerfile:1
ARG base_image=redhat/ubi8-minimal
ARG base_tag=8.9-1161

FROM ${base_image}:${base_tag}

  ARG qlik_package=qlik-data-gateway-data-movement_2023.11-4_x86_64.rpm
  ARG qlik_package_version=2023.11-4
  ARG qlik_package_platform=x86_64
  ARG user=qlik
  ARG dnf_command=microdnf
  ARG qlik_tenant=obd

  LABEL maintainer="eost@qlik.com"
  LABEL qlik_package_version="${qlik_package_version}"
  LABEL qlik_package_platform="${qlik_package_platform}"
  LABEL qlik_tenant="${qlik_tenant}"

  ADD --chown=${user}:${user} "${qlik_package}" "${qlik_package}"
  COPY --chmod=740 --chown=${user}:${user} repagent_start.sh "./"

  RUN \
    sudo mkdir -p /opt/qlik \ 
    && sudo chown qlik:qlik /opt/qlik \
    && sudo ${dnf_command} install -y cpio \
    && rpm2cpio "${qlik_package}" | cpio -idmv -D /

  RUN \
    cd /opt/qlik/gateway/movement/bin \
    && ./agentctl qcs set_config --tenant_url ${qlik_tenant}.us.qlikcloud.com \
    && iport=3550 rport=3552 verbose=true systemd_disabled=1 ./arep.sh install repagent

  CMD [ "/home/qlik/repagent_start.sh" ]
