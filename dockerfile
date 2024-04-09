# syntax=docker/dockerfile:1
ARG base_image=edwardost/ubuntu
ARG base_tag=22.04
ARG qlik_data_movement_gateway_rpm_version=2023.11.4

FROM ${base_image}:${base_tag} AS dev_base
LABEL maintainer="eost@talend.com"
LABEL qlik_data_movement_gateway_rpm_version="${qlik_data_movement_gateway_rpm_version}"

  ADD --chown=qlik:qlik qlik-data-gateway-data-movement.rpm gateway/qlik-data-movement-gateway-data-movement-${qlik_data_movement_gateway_rpm_version}.rpm
  RUN ln -s gateway/qlik-data-movement-gateway-data-movement-${qlik_data_movement_gateway_rpm_version}.rpm gateway/qlik-data-movement-gateway-data-movement.rpm
  RUN sudo apt-get install -y rpm
