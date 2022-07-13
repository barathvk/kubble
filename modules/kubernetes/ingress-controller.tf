resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  wait             = true
  values = [
    <<EOF
    defaultBackend:
      enabled: true
      image:
        registry: docker.io
        image: lennonsaves/nuri-default-backend
        tag: latest
        pullPolicy: Always
    controller:
      config:
        force-ssl-redirect: "true"
        use-forwarded-headers: "true"
        use-proxy-protocol: "false"
      updateStrategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1
      hostPort:
        enabled: true
      terminationGracePeriodSeconds: 0
      service:
        type: NodePort
      watchIngressWithoutClass: true
      nodeSelector:
        ingress-ready: "true"
      tolerations:
        - key: node-role.kubernetes.io/master
          operator: Equal
          effect: NoSchedule
      publishService:
        enabled: false
      extraArgs:
        publish-status-address: localhost
    EOF
  ]
}