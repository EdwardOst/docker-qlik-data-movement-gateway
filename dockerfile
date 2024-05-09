# syntax=docker/dockerfile:1
ARG builder_image=edwardost/ubi8
ARG builder_tag=8.9-1160
ARG base_image=edwardost/ubi8-minimal
ARG base_tag=8.9-1161
ARG dnf_command=dnf
ARG qlik_user=qlik
ARG qlik_tenant=obd

FROM ${builder_image}:${builder_tag} AS gateway_builder

  ARG qlik_package=qlik-data-gateway-data-movement_2023.11-4_x86_64.rpm
  ARG dnf_command
  ARG qlik_user
  ARG qlik_tenant

  ADD --chown=${qlik_user}:${qlik_user} "${qlik_package}" "${qlik_package}"

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


FROM gateway_builder AS gateway

  ARG qlik_user
  ARG qlik_tenant

  ARG qlik_package_version=2023.11-4
  ARG qlik_package_platform=x86_64

  LABEL maintainer="eost@qlik.com"
  LABEL qlik_package_version="${qlik_package_version}"
  LABEL qlik_package_platform="${qlik_package_platform}"
  LABEL qlik_tenant="${qlik_tenant}"

  ENV QLIK_TENANT=${qlik_tenant}
  ENV QLIK_PACKAGE_VERSION=${qlik_package_version}
  ENV QLIK_PACKAGE_PLATFORM=${qlik_package_platform}

  COPY --chmod=740 --chown=${qlik_user}:${qlik_user} repagent-start.sh "./"
#  COPY --from=gateway_builder /opt/qlik/ /opt/qlik/

  # install mysql driver
#  RUN \
#    sudo microdnf install -y libtool-ltdl unixODBC \
#    && curl -LO https://dev.mysql.com/get/Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.32-1.el8.x86_64.rpm \
#    && sudo rpm -ivh mysql-connector-odbc-8.0.32-1.el8.x86_64.rpm

  CMD [ "/home/qlik/repagent-start.sh" ]
