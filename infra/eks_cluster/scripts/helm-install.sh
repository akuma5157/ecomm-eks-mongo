#!/bin/sh

#if [ -d ./temp ]
#then
#  echo "Cleaning up temp dir"
#  rm -rf ./temp
#fi
#
#mkdir ./temp
#cp -R ./helm ./temp
#
#export CLUSTER_DNS=$CLUSTER_NAME.$CLUSTER_ZONE
#
############### Install Common elements ##############
#kubectl apply -f ./temp/helm/custom-storage-class.yaml
#kubectl apply -f ./temp/helm/kube-dns-autoscaler.yaml


kubectl apply -f ./helm/tiller-rbac.yaml
helm init --service-account tiller --upgrade

sleep 100

########### Install prometheus operator ##########
helm install --values=./helm/values.yaml --name=monitoring stable/prometheus-operator

############## Install nginx-ingress ##############
#sed -i -e "s/CLUSTER_DNS/${CLUSTER_DNS}/g" ./temp/helm/nginx-ingress.yaml
#sed -i -e "s/CLUSTER_DNS/${CLUSTER_DNS}/g" ./temp/helm/nginx-ingress-internal.yaml
#
#helm upgrade --install nginx-ingress -f ./temp/helm/nginx-ingress.yaml stable/nginx-ingress --namespace nginx-ingress
#helm upgrade --install nginx-ingress-internal -f ./temp/helm/nginx-ingress-internal.yaml stable/nginx-ingress --namespace nginx-ingress
#
############### Install external-dns ##############
#sed -i -e "s/CLUSTER_ZONE/${CLUSTER_ZONE}/g" ./temp/helm/external-dns/external-dns-intranet.yaml
#sed -i -e "s/CLUSTER_NAME/${CLUSTER_NAME}/g" ./temp/helm/external-dns/external-dns-intranet.yaml
#
#sed -i -e "s/CLUSTER_ZONE/${CLUSTER_ZONE}/g" ./temp/helm/external-dns/external-dns-internet.yaml
#sed -i -e "s/CLUSTER_NAME/${CLUSTER_NAME}/g" ./temp/helm/external-dns/external-dns-internet.yaml
#
#sed -i -e "s/CLUSTER_ZONE/${CLUSTER_ZONE}/g" ./temp/helm/external-dns/external-dns-istio.yaml
#sed -i -e "s/CLUSTER_NAME/${CLUSTER_NAME}/g" ./temp/helm/external-dns/external-dns-istio.yaml
#
#sed -i -e "s/CLUSTER_ZONE/${CLUSTER_ZONE}/g" ./temp/helm/external-dns/external-dns-nginx.yaml
#sed -i -e "s/CLUSTER_NAME/${CLUSTER_NAME}/g" ./temp/helm/external-dns/external-dns-nginx.yaml
#
#kubectl create secret generic route53-config --from-literal=secret-access-key=$AWS_SECRET_ACCESS_KEY --namespace kube-system --dry-run -o yaml | kubectl apply -f -
#kubectl apply -f ./temp/helm/external-dns/external-dns-rbac.yaml
#
#helm upgrade --install external-dns-intranet -f ./temp/helm/external-dns/external-dns-intranet.yaml stable/external-dns --namespace kube-system
#helm upgrade --install external-dns-internet -f ./temp/helm/external-dns/external-dns-internet.yaml stable/external-dns --namespace kube-system
#helm upgrade --install external-dns-nginx -f ./temp/helm/external-dns/external-dns-nginx.yaml stable/external-dns --namespace kube-system
#helm upgrade --install external-dns-istio -f ./temp/helm/external-dns/external-dns-istio.yaml stable/external-dns --namespace kube-system
#
############### Install cert-manager ##############
#LETSENCRYPT_env=staging
#
#if [ "$LETSENCRYPT_PRODUCTION" == "true" ]
#then
#  LETSENCRYPT_env=prod
#fi
#
#sed -i -e "s/REGION/${REGION}/g" ./temp/helm/cert-manager/letsencrypt-$LETSENCRYPT_env.yaml
#sed -i -e "s/CLUSTER_ZONE_ID/${CLUSTER_ZONE_ID}/g" ./temp/helm/cert-manager/letsencrypt-$LETSENCRYPT_env.yaml
#sed -i -e "s/AWS_ACCESS_KEY_ID/${AWS_ACCESS_KEY_ID}/g" ./temp/helm/cert-manager/letsencrypt-$LETSENCRYPT_env.yaml
#sed -i -e "s/LETSENCRYPT_EMAIL/${LETSENCRYPT_EMAIL}/g" ./temp/helm/cert-manager/letsencrypt-$LETSENCRYPT_env.yaml
#
#sed -i -e "s/LETSENCRYPT_env/${LETSENCRYPT_env}/g" ./temp/helm/cert-manager/cert-manager.yaml
#
#sed -i -e "s/LETSENCRYPT_env/${LETSENCRYPT_env}/g" ./temp/helm/cert-manager/cluster-management-cert.yaml
#sed -i -e "s/CLUSTER_DNS/${CLUSTER_DNS}/g" ./temp/helm/cert-manager/cluster-management-cert.yaml
#
#helm upgrade --install cert-manager -f ./temp/helm/cert-manager/cert-manager.yaml stable/cert-manager --namespace kube-system --version v0.5.1
#
#kubectl apply -f ./temp/helm/cert-manager/letsencrypt-$LETSENCRYPT_env.yaml
#kubectl apply -f ./temp/helm/cert-manager/cluster-management-cert.yaml
#
############### Install kubernetes-dashboard ##############
#sed -i -e "s/CLUSTER_DNS/${CLUSTER_DNS}/g" ./temp/helm/kubernetes-dashboard.yaml
#
#helm upgrade --install kubernetes-dashboard -f ./temp/helm/kubernetes-dashboard.yaml stable/kubernetes-dashboard --namespace kube-system
#
############# Install cluster-autoscaler ##############
#sed -i -e "s/REGION/${REGION}/g"  ./temp/helm/cluster-autoscaler.yaml
#sed -i -e "s/YOUR_CLUSTER_NAME/${CLUSTER_NAME}/g" ./temp/helm/cluster-autoscaler.yaml
#
#helm upgrade --install metrics-server -f ./temp/helm/metrics-server.yaml stable/metrics-server --namespace kube-system
#helm upgrade --install cluster-autoscaler -f ./temp/helm/cluster-autoscaler.yaml stable/cluster-autoscaler --namespace kube-system
#
############# Install logging ##############
#sed -i -e "s/CLUSTER_DNS/${CLUSTER_DNS}/g" ./temp/helm/logging/cerebro.yaml
#sed -i -e "s/CLUSTER_DNS/${CLUSTER_DNS}/g" ./temp/helm/logging/kibana.yaml
#
#helm upgrade --install elasticsearch -f ./temp/helm/logging/elasticsearch.yaml stable/elasticsearch --namespace logging
#helm upgrade --install curator -f ./temp/helm/logging/curator.yaml stable/elasticsearch-curator --namespace logging
#helm upgrade --install fluentd -f ./temp/helm/logging/fluentd.yaml stable/fluentd-elasticsearch --namespace logging
#helm upgrade --install cerebro -f ./temp/helm/logging/cerebro.yaml stable/cerebro --namespace logging
#helm upgrade --install kibana -f ./temp/helm/logging/kibana.yaml stable/kibana --namespace logging
#
############# Install monitoring ##############
#sed -i -e "s/CLUSTER_NAME/${CLUSTER_NAME}/g" ./temp/helm/monitoring/grafana.yaml
#sed -i -e "s/CLUSTER_DNS/${CLUSTER_DNS}/g" ./temp/helm/monitoring/grafana.yaml
#sed -i -e "s/CLUSTER_DNS/${CLUSTER_DNS}/g" ./temp/helm/monitoring/prometheus.yaml
#
#helm upgrade --install prometheus -f ./temp/helm/monitoring/prometheus.yaml stable/prometheus --namespace monitoring
#
#kubectl create configmap default-dashboards --from-file=./temp/helm/monitoring/default-dashboards --namespace monitoring --dry-run -o yaml | kubectl apply -f -
#kubectl create configmap istio-dashboards --from-file=./temp/helm/monitoring/istio-dashboards --namespace monitoring --dry-run -o yaml | kubectl apply -f -
#kubectl create configmap istio-system-dashboards --from-file=./temp/helm/monitoring/istio-system-dashboards --namespace monitoring --dry-run -o yaml | kubectl apply -f -
#
#helm upgrade --install grafana -f ./temp/helm/monitoring/grafana.yaml stable/grafana --namespace monitoring
#
############# Install istio ##############
#helm repo add istio.io "https://gcsweb.istio.io/gcs/istio-prerelease/daily-build/release-1.1-latest-daily/charts/"
#
#sed -i -e "s/CLUSTER_DNS/${CLUSTER_DNS}/g" ./temp/helm/istio/istio.yaml
#sed -i -e "s/CLUSTER_ZONE/${CLUSTER_ZONE}/g" ./temp/helm/istio/istio-gateway-cert.yaml
#sed -i -e "s/LETSENCRYPT_env/${LETSENCRYPT_env}/g" ./temp/helm/istio/istio-gateway-cert.yaml
#
#helm upgrade --install istio-init istio.io/istio-init  --namespace istio-system
#
#KIALI_USER=$(echo -n $CLUSTER_NAME | base64)
#
#sed -i -e "s/KIALI_USER/${KIALI_USER}/g" ./temp/helm/istio/kiali-secret.yaml
#
#kubectl apply -f ./temp/helm/istio/kiali-secret.yaml
#
#sleep 60;
#
#kubectl get crds | grep 'istio.io\|certmanager.k8s.io'
#kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l
#kubectl label namespace default istio-injection=enabled --overwrite=true
#
#helm upgrade  --install istio -f ./temp/helm/istio/istio.yaml istio.io/istio  --namespace istio-system
#
#kubectl apply -f ./temp/helm/istio/fluentd-istio.yaml
#kubectl apply -f ./temp/helm/istio/istio-gateway-cert.yaml
#
#
############# Propaget management certificate secret ##############
#
#sleep 90;
#
#kubectl get secret cluster-management-crt --namespace=kube-system --export -o yaml | kubectl apply --namespace=logging -f -
#kubectl get secret cluster-management-crt --namespace=kube-system --export -o yaml | kubectl apply --namespace=monitoring -f -
#kubectl get secret cluster-management-crt --namespace=kube-system --export -o yaml | kubectl apply --namespace=istio-system -f -
