# syntax=docker/dockerfile:1
ARG base_image=edwardost/ubi8-minimal
ARG base_tag=8.9-1161

FROM ${base_image}:${base_tag}

ARG qlik_tenant=obd
ARG qlik_package=qlik-data-gateway-data-movement_2023.11-4_x86_64.rpm
ARG qlik_package_version=2023.11-4
ARG qlik_package_platform=x86_64

LABEL maintainer="eost@qlik.com"
LABEL qlik_package_version="${qlik_package_version}"
LABEL qlik_tenant="${qlik_tenant}"

# note that working directory for redhat ubi defaults to / rather than /home/root

#  ADD --chown=qlik:qlik "${qlik_package_version}" "${qlik_package_version}/"
  ADD "${qlik_package_version}" "${qlik_package_version}/"

  RUN \
    cd ~/${qlik_package_version}/opt/qlik/gateway/movement/bin \
    && iport=3550 rport=3552 systemd_disabled=true debug=true verbose=true tenant_url=obd.us.qlikcloud.com ./arep.sh install repagent

#  RUN \
#    sudo mkdir -p /opt/qlik \
#    && sudo chown qlik:qlik /opt/qlik
#    && cd "${qlik_package_version}" \
#    && package_filename=${qlik_package} \
#    && package_ext=${package_filename##*\.} \
#    && ln -s ${qlik_package} qlik-data-movement-gateway-data-movement.${package_ext}
#    && QLIK_CUSTOMER_AGREEMENT_ACCEPT=yes rpm -ivh qlik-data-movement-gateway-data-movement.${package_ext}

#  RUN cd /opt/qlik/gateway/movement/bin \
#    && ./agentctl qcs set_config --tenant_url ${qlik_tenant}.us.qlikcloud.com

#  RUN QLIK_CUSTOMER_AGREEMENT_ACCEPT=yes rpm -ivh ~/gateway/qlik-data-movement-gateway-data-movement.rpm

#  RUN sudo systemctl start repagent
