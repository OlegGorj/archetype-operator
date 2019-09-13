FROM quay.io/operator-framework/ansible-operator:v0.10.0
USER root

RUN yum -y install git && pip install jmespath yq

USER ${USER_UID}

COPY roles/ ${HOME}/roles/
COPY watches.yaml ${HOME}/watches.yaml
