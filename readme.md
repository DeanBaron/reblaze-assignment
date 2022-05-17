# install nginx-ingress-controller:

```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

# Install prometheus operator:
```
Follow the steps in:

https://grafana.com/docs/grafana-cloud/kubernetes/prometheus/prometheus_operator/
```
# install the prometheus kube-state-metrics helm chart (set .Values.prometheus.monitor.enabled to true ):

https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics

# Install grafana:
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana -n grafana --create-namespace
```

# Connect prometheus to grafana:
url: http://prometheus-operated.monitoring:9090