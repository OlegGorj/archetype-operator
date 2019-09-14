#!/bin/bash

BUILD_TIME=$(date -u '+%Y-%m-%d_%H:%M:%S')
CONFIG_SERVICE_URL=http://localhost:8000

# get list of number of configurations
CONFIGS_NUM=$(curl -X GET ${CONFIG_SERVICE_URL}/api/v2/configmaps/sandbox/@ -H 'Cache-Control: no-cache')
i=0
while [ $i -lt ${CONFIGS_NUM} ]
do
  CONF_JSON=$(curl -X GET ${CONFIG_SERVICE_URL}/api/v2/configmaps/sandbox/${i} -H 'Cache-Control: no-cache')
  #echo $CONF_JSON
  NAMESPACE=$(echo $CONF_JSON | jq '.namespace' | tr -d '"' )
  CONFIGMAP=$(echo $CONF_JSON | jq '.configmap' | sed 's/.json//g' | tr -d '"' )
  CONFIG=$(echo $CONF_JSON | jq '.config' | sed 's/.json//g' | tr -d '"' )
  declare -a list=( $( echo $CONF_JSON | jq -c '.keys | .[].config_service_key' | tr -d '"' ) )

  yq w configmap.template metadata.name ${CONFIGMAP} > configmap_${CONFIGMAP}.yaml
  for element in "${list[@]}"
  do
    URL="${CONFIG_SERVICE_URL}/api/v2/${CONFIG}/sandbox/${element}" ; CONF_VAL=$(curl -X GET ${URL} )
    echo "CONF_VAL: " $(echo $CONF_VAL | base64)
    yq w -i configmap_${CONFIGMAP}.yaml data.${element} $(echo $CONF_VAL | base64)
  done

  echo "---" >> configmap_${CONFIGMAP}.yaml

  ((i++))
done

cat configmap_*.yaml > configmap.yaml
rm -f configmap_*.yaml
