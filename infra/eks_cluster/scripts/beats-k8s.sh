#!/bin/bash

# deploy kube-state-metrics
kubectl apply -f ./monitoring/kube-state-metrics

# deploy filebeat
sed "s/value: elasticsearch/value: ${ELASTICSEARCH_IP}/g" ./monitoring/filebeat-kubernetes.yaml > ./monitoring/filebeat-kubernetes.tmp.yaml
kubectl apply -f ./monitoring/filebeat-kubernetes.tmp.yaml

# deploy metricbeat
sed "s/value: elasticsearch/value: ${ELASTICSEARCH_IP}/g" ./monitoring/metricbeat-kubernetes.yaml > ./monitoring/metricbeat-kubernetes.tmp.yaml
kubectl apply -f ./monitoring/metricbeat-kubernetes.tmp.yaml
