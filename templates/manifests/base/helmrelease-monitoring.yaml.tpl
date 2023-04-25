apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: monitoring
  namespace: flux-system
spec:
  chart:
    spec:
      chart: kube-prometheus-stack
      sourceRef:
        kind: HelmRepository
        name: prometheus-community
      version: "~> 33.1"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  releaseName: monitoring
  storageNamespace: monitoring
  targetNamespace: monitoring
  values:
    prometheusOperator:
      admissionWebhooks:
        enabled: false
        patch:
          enabled: false
      tls:
        enabled: false

      resources:
        limits:
          cpu: 150m
          memory: 256Mi
        requests:
          cpu: 50m
          memory: 128Mi

      tolerations:
      - operator: Exists
        effect: NoSchedule

      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: node-role.kubernetes.io/infra
                operator: Exists
          - weight: 100
            preference:
              matchExpressions:
              - key: role
                operator: In
                values:
                - infra

    prometheus:
      service:
        type: ClusterIP
        loadBalancerIP: null
        sessionAffinity: ClientIP

      ingress:
        enabled: ${ modules.monitoring.prometheus.ingress.enabled }
        ingressClassName: ${ modules.monitoring.prometheus.ingress.className }
        annotations:
        %{~ if modules.monitoring.prometheus.ingress.clusterIssuer != "" }
          cert-manager.io/cluster-issuer: ${ modules.monitoring.prometheus.ingress.clusterIssuer }
        %{~ endif }
    #      nginx.ingress.kubernetes.io/auth-realm: Authentication Required - Monitoring
    #      nginx.ingress.kubernetes.io/auth-secret: monitoring-basic-auth
    #      nginx.ingress.kubernetes.io/auth-type: basic
        hosts:
          - ${ modules.monitoring.prometheus.ingress.host }
        %{~ if modules.monitoring.prometheus.ingress.scheme == "https" }
        tls:
        - hosts:
          - ${ modules.monitoring.prometheus.ingress.host }
          secretName: prometheus-ingress-tls
        %{~ endif }

      prometheusSpec:
        replicas: 1
        retention: 7d
        scrapeInterval: 30s
        enableAdminAPI: true

        enableFeatures:
        - exemplar-storage

        resources:
          limits:
            cpu: 1
            memory: 2Gi
          requests:
            cpu: 100m
            memory: 1Gi

        externalLabels:
          cluster: ${customer_name}/${cluster_name}
        prometheusExternalLabelName: cluster

        ruleSelectorNilUsesHelmValues: false
        ruleSelector: {}
        ruleNamespaceSelector: {}

        serviceMonitorSelectorNilUsesHelmValues: false
        serviceMonitorSelector: {}
        serviceMonitorNamespaceSelector: {}

        podMonitorSelectorNilUsesHelmValues: false
        podMonitorSelector: {}
        podMonitorNamespaceSelector: {}

        probeSelectorNilUsesHelmValues: false
        probeSelector: {}
        probeNamespaceSelector: {}

        tolerations:
        - operator: Exists
          effect: NoSchedule

        affinity:
          nodeAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              preference:
                matchExpressions:
                - key: node-role.kubernetes.io/infra
                  operator: Exists
            - weight: 100
              preference:
                matchExpressions:
                - key: role
                  operator: In
                  values:
                  - infra

        storageSpec:
          volumeClaimTemplate:
            metadata:
              labels:
                velero.io/exclude-from-backup: "true"
            spec:
              resources:
                requests:
                  storage: 100Gi

%{~ if modules.monitoring.tempo.enabled }
        enableRemoteWriteReceiver: true
%{~ endif }

%{~if modules.istio.enabled }
        additionalScrapeConfigs:
        - job_name: 'istiod'
          kubernetes_sd_configs:
          - role: endpoints
            namespaces:
              names:
              - istio-system
          relabel_configs:
          - source_labels: [__meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
            action: keep
            regex: istiod;http-monitoring

        - job_name: 'envoy-stats'
          metrics_path: /stats/prometheus
          kubernetes_sd_configs:
          - role: pod

          relabel_configs:
          - source_labels: [__meta_kubernetes_pod_container_port_name]
            action: keep
            regex: '.*-envoy-prom'
%{~ endif }

    alertmanager:
      alertmanagerSpec:
        replicas: 2

        logFormat: logfmt

        tolerations:
        - operator: Exists
          effect: NoSchedule

        affinity:
          nodeAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              preference:
                matchExpressions:
                - key: node-role.kubernetes.io/infra
                  operator: Exists
            - weight: 100
              preference:
                matchExpressions:
                - key: role
                  operator: In
                  values:
                  - infra

        resources:
          limits:
            cpu: 50m
            memory: 256Mi
          requests:
            cpu: 10m
            memory: 128Mi

      service:
        type: ClusterIP
        sessionAffinity: ClientIP

      ingress:
        enabled: ${ modules.monitoring.alertmanager.ingress.enabled }
        ingressClassName: ${ modules.monitoring.alertmanager.ingress.className }
        annotations:
        %{~ if modules.monitoring.alertmanager.ingress.clusterIssuer != "" }
          cert-manager.io/cluster-issuer: ${ modules.monitoring.alertmanager.ingress.clusterIssuer }
        %{~ endif }
    #      nginx.ingress.kubernetes.io/auth-realm: Authentication Required - Monitoring
    #      nginx.ingress.kubernetes.io/auth-secret: monitoring-basic-auth
    #      nginx.ingress.kubernetes.io/auth-type: basic
        hosts:
          - ${ modules.monitoring.alertmanager.ingress.host }
        %{~ if modules.monitoring.alertmanager.ingress.scheme == "https" }
        tls:
        - hosts:
          - ${ modules.monitoring.alertmanager.ingress.host }
          secretName: alertmanager-ingress-tls
        %{~ endif }

      config:
        global:
          resolve_timeout: 6h

        #################################################################
        ## Receivers
        #################################################################

        receivers:
        # does nothing
        - name: blackhole

        #############################
        # Cronitor
        #############################
%{~ if alertmanager_cronitor_id != "" }
        - name: cronitor
          webhook_configs:
          - url: https://cronitor.link/${alertmanager_cronitor_id}/run
            send_resolved: false
%{~ else }
        # Set manifests_template_vars.alertmanager_cronitor_id to configure Cronitor
%{~ endif }

        #############################
        # Slack
        #############################
%{~ if alertmanager_slack_channel != "" && alertmanager_slack_api_url != "" }
        - name: slack
          slack_configs:
          - send_resolved: true
            api_url: ${alertmanager_slack_api_url}
            channel: "#${trimprefix(alertmanager_slack_channel, "#")}"
            color: |-
              {{- if eq .Status "firing" -}}
                {{- if eq (index .Alerts 0).Labels.severity "critical" -}}
                  #FF2222
                {{- end -}}
                {{- if eq (index .Alerts 0).Labels.severity "warning" -}}
                  #FF8800
                {{- end -}}
                {{- if and (ne (index .Alerts 0).Labels.severity "critical") (ne (index .Alerts 0).Labels.severity "warning") -}}
                  #22FF22
                {{- end -}}
              {{- else -}}
                #22FF22
              {{- end -}}
            title: '{{ template "slack.default.title" . }}'
            pretext: '{{ .CommonAnnotations.summary }}'
            fallback: '{{ template "slack.default.fallback" . }}'
            text: |-
              {{ range .Alerts -}}
              *Severity:* `{{ .Labels.severity | title }}` (<{{ .GeneratorURL }}|graph>)
              *Description:* {{ .Annotations.message }}
              *Labels:*{{ range .Labels.SortedPairs }} `{{ .Name }}={{ .Value }}`{{ end }}
              {{ end }}
%{~ else }
        # Set manifests_template_vars.alertmanager_slack_channel and manifests_template_vars.alertmanager_slack_api_url to configure Slack
%{~ endif }

        #############################
        # MSTeams
        #############################
%{~ if alertmanager_msteams_url != "" }
        - name: msteams
          webhook_configs:
          - url: ${ alertmanager_msteams_url }
%{~ else }
        # Set manifests_template_vars.alertmanager_msteams_url to configure MS Teams
        # Example: http://prometheus-msteams:2000/alertmanager
%{~ endif }

        #############################
        # Opsgenie
        #############################
%{~ if alertmanager_opsgenie_integration_api_key != "" }
        - name: opsgenie
          opsgenie_configs:
          - api_key: ${alertmanager_opsgenie_integration_api_key}
            # sla-none (no-ops) sla-low (dev/test) sla-high (prod/hlg)
            tags: ${customer_name}, ${cluster_name}, ${cluster_type}, sla-${cluster_sla}
%{~ if cluster_sla == "high" }
            priority: P2
%{~ else}
%{~   if cluster_sla == "low" }
            priority: P4
%{~   else }
            priority: P5
%{~   endif }
%{~ endif }
%{~ else }
        # Set var.opsgenie_api_key to configure Opsgenie
%{~ endif }

        #############################
        # PagerDuty
        #############################
%{~ if alertmanager_pagerduty_service_key != "" }
        - name: pagerduty
          pagerduty_configs:
          - service_key: ${alertmanager_pagerduty_service_key}
            # sla-none (no-ops) sla-low (dev/test) sla-high (prod/hlg)
            group: sla-${cluster_sla}
%{~ else }
        # Set manifests_template_vars.alertmanager_pagerduty_service_key to configure PagerDuty
%{~ endif }

        inhibit_rules:
        # Inhibit same alert with lower severity of an already firing alert
        - equal: ['alertname']
          source_match:
            severity: critical
          target_match:
            severity: warning

        #################################################################
        ## Routes
        #################################################################

        route:
          receiver: ${ alertmanager_default_receiver }
          group_by: ['alertname', 'cluster_name']
          group_wait: 15s
          group_interval: 5m
          repeat_interval: 3h

          ###
          ### Routes
          ###

          routes:
          # watchdog aims to test the alerting pipeline
          - match:
              alertname: Watchdog
            continue: false

%{~ if alertmanager_ignore_alerts != [] || alertmanager_ignore_namespaces != [] }
          # Ignore alerts and/or namespaces
          - receiver: blackhole
            continue: false
            match_re:
%{~ if alertmanager_ignore_alerts != [] }
              alertname: "^(${ join("|", alertmanager_ignore_alerts) })$"
%{~ endif }
%{~ if alertmanager_ignore_namespaces != [] }
              namespace: "^(${ join("|", alertmanager_ignore_namespaces) })$"
%{~ endif }
%{~ endif }

          #########################
          ## External alert systems
          #########################

          #############################
          # Cronitor
          #############################
%{~ if alertmanager_cronitor_id != "" }
          - receiver: cronitor
            match:
              alertname: CronitorWatchdog
            group_wait: 5s
            group_interval: 1m
            continue: false
%{~ endif }

%{~ if alertmanager_slack_channel != "" }
          #############################
          # Slack
          #############################
          - receiver: slack
            match_re:
              alertname: .*
            continue: true
%{~ endif }

%{~ if alertmanager_msteams_url != "" }
          #############################
          # MS Teams
          #############################
          - receiver: msteams
            match_re:
             alertname: .*
            continue: true
%{~ endif }

%{~ if alertmanager_opsgenie_integration_api_key != "" }
          #############################
          # Opsgenie
          #############################
          - receiver: opsgenie
            match_re:
              alertname: (KubeCronJobRunning|KubeDaemonSetRolloutStuck|KubeDeploymentGenerationMismatch|KubeDeploymentReplicasMismatch|KubePodCrashLooping|KubePodNotReady|KubeStatefulSetGenerationMismatch|KubeStatefulSetReplicasMismatch|KubeCronJobRunning|KubeDaemonSetRolloutStuck|KubeDeploymentGenerationMismatch|KubeDeploymentReplicasMismatch|KubePodCrashLooping|KubePodNotReady|KubeStatefulSetGenerationMismatch|KubeStatefulSetReplicasMismatch|AlertmanagerFailedReload|CertificateAlert|ClockSkewDetected|EndpointDown|HighNumberOfFailedProposals|PrometheusOperatorReconcileErrors|PrometheusConfigReloadFailed|PrometheusNotConnectedToAlertmanagers|PrometheusTSDBReloadsFailing|PrometheusTSDBCompactionsFailing|PrometheusTSDBWALCorruptions|PrometheusNotIngestingSamples|KubeNodeUnreachable|KubeClientCertificateExpiration|KubeNodeNotReady|KubeAPILatencyHigh|HighNumberOfFailedHTTPRequests|KubeStatefulSetUpdateNotRolledOut|KubeJobCompletion|KubeJobFailed)
              namespace: (kube-.*|logging|monitoring|velero|cert-manager|.*-operator|.*-ingress|ingress-.*|.*-provisioner|getup|.*istio.*|.*-controllers)
              severity: warning
            continue: true
          - receiver: opsgenie
            match:
              severity: critical
            continue: true
%{~ endif }

%{~ if alertmanager_pagerduty_service_key != "" }
          #############################
          # PageDuty
          #############################
          - receiver: pagerduty
            match_re:
              alertname: (KubeCronJobRunning|KubeDaemonSetRolloutStuck|KubeDeploymentGenerationMismatch|KubeDeploymentReplicasMismatch|KubePodCrashLooping|KubePodNotReady|KubeStatefulSetGenerationMismatch|KubeStatefulSetReplicasMismatch|KubeCronJobRunning|KubeDaemonSetRolloutStuck|KubeDeploymentGenerationMismatch|KubeDeploymentReplicasMismatch|KubePodCrashLooping|KubePodNotReady|KubeStatefulSetGenerationMismatch|KubeStatefulSetReplicasMismatch|AlertmanagerFailedReload|CertificateAlert|ClockSkewDetected|EndpointDown|HighNumberOfFailedProposals|PrometheusOperatorReconcileErrors|PrometheusConfigReloadFailed|PrometheusNotConnectedToAlertmanagers|PrometheusTSDBReloadsFailing|PrometheusTSDBCompactionsFailing|PrometheusTSDBWALCorruptions|PrometheusNotIngestingSamples|KubeNodeUnreachable|KubeClientCertificateExpiration|KubeNodeNotReady|KubeAPILatencyHigh|HighNumberOfFailedHTTPRequests|KubeStatefulSetUpdateNotRolledOut|KubeJobCompletion|KubeJobFailed)
              namespace: (kube-.*|logging|monitoring|velero|cert-manager|.*-operator|.*-ingress|ingress-.*|.*-provisioner|getup|.*istio.*|.*-controllers)
              severity: warning
            continue: true
          - receiver: pagerduty
            match:
              severity: critical
            continue: true
%{~ endif }

          # ignored all alerts (default)
          - receiver: blackhole
            match_re:
              alertname: .*
            continue: false

    grafana:
      image:
        tag: 8.5.15

      sidecar:
        datasources:
          exemplarTraceIdDestinations:
            datasourceUid: tempo
            traceIdLabelName: traceID

      service:
        type: ClusterIP
        sessionAffinity: ClientIP

      tolerations:
      - operator: Exists
        effect: NoSchedule

      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: node-role.kubernetes.io/infra
                operator: Exists
          - weight: 100
            preference:
              matchExpressions:
              - key: role
                operator: In
                values:
                - infra

      deploymentStrategy:
        type: Recreate

      persistence:
        enabled: true
        accessModes: ["ReadWriteOnce"]
        size: 10Gi

      resources:
        limits:
          cpu: 1
          memory: 256Mi
        requests:
          cpu: 50m
          memory: 128Mi

      env: {}

      datasources:
        datasources.yaml:
          apiVersion: 1
          datasources:
          %{~ if modules.logging.enabled }
          - name: Loki
            type: loki
            uid: loki
            editable: true
            url: http://loki.logging.svc:3100
            basicAuth: false
            access: proxy
            isDefault: false
            jsonData:
              maxLines: 2000
              manageAlerts: false
              timeout: 60
              derivedFields:
              - datasourceUid: tempo
                matcherRegex: "traceID=(\\w+)"
                name: TraceID
                url: "$$${__value.raw}"
          %{~ endif }
          %{~ if modules.monitoring.tempo.enabled }
          - name: Tempo
            type: tempo
            uid: tempo
            editable: true
            url: http://tempo:3100
            basicAuth: false
            access: proxy
            isDefault: false
            jsonData:
              timeout: 60
              httpMethod: GET
              tracesToLogs:
                datasourceUid: loki
                mapTagNamesEnabled: true
                mappedTags:
                - key: host.name
                  value: pod
                spanStartTimeShift: '-15m'
                spanEndTimeShift: '15m'
                filterByTraceID: true
                filterBySpanID: false
              tracesToMetrics:
                datasourceUid: prometheus
                tags:
                - key: host.name
                  value: pod
                spanStartTimeShift: '-15m'
                spanEndTimeShift: '15m'
                queries:
                - name: 'Pod CPU'
                  query: 'sum(node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{$$$__tags, container!="POD"}) by (container)'
                - name: 'Pod Memory'
                  query: 'sum(container_memory_working_set_bytes{$$$__tags, job="kubelet", metrics_path="/metrics/cadvisor", container!="POD", image!=""}) by (container)'
              serviceMap:
                datasourceUid: prometheus
              search:
                hide: false
              nodeGraph:
                enabled: true
              lokiSearch:
                datasourceUid: loki
          %{~ endif }

      dashboardProviders:
        dashboardproviders.yaml:
          apiVersion: 1
          providers:
          - name: 'default'
            orgId: 1
            folder: ''
            type: file
            disableDeletion: false
            editable: true
            options:
              path: /var/lib/grafana/dashboards/default

%{~if modules.istio.enabled }
          - name: istio
            orgId: 1
            folder: "Istio"
            type: file
            disableDeletion: false
            editable: true
            options:
              path: /var/lib/grafana/dashboards/istio
%{~ endif }

      dashboards:
        default:
%{~if modules.linkerd.enabled }
          trivy-image-vulnerability:
            gnetId: 17214
            revision: 1
            datasource: Prometheus
%{~ endif }
%{~if modules.linkerd.enabled }
          # https://github.com/linkerd/linkerd2/blob/main/grafana/values.yaml
          # all these charts are hosted at https://grafana.com/grafana/dashboards/$gnetId
          top-line:
            gnetId: 15474
            revision: 4
            datasource: prometheus
          health:
            gnetId: 15486
            revision: 3
            datasource: prometheus
          kubernetes:
            gnetId: 15479
            revision: 2
            datasource: prometheus
          namespace:
            gnetId: 15478
            revision: 3
            datasource: prometheus
          deployment:
            gnetId: 15475
            revision: 6
            datasource: prometheus
          pod:
            gnetId: 15477
            revision: 3
            datasource: prometheus
          service:
            gnetId: 15480
            revision: 3
            datasource: prometheus
          route:
            gnetId: 15481
            revision: 3
            datasource: prometheus
          authority:
            gnetId: 15482
            revision: 3
            datasource: prometheus
          cronjob:
            gnetId: 15483
            revision: 3
            datasource: prometheus
          job:
            gnetId: 15487
            revision: 3
            datasource: prometheus
          daemonset:
            gnetId: 15484
            revision: 3
            datasource: prometheus
          replicaset:
            gnetId: 15491
            revision: 3
            datasource: prometheus
          statefulset:
            gnetId: 15493
            revision: 3
            datasource: prometheus
          replicationcontroller:
            gnetId: 15492
            revision: 4
            datasource: prometheus
          prometheus:
            gnetId: 15489
            revision: 2
            datasource: prometheus
          prometheus-benchmark:
            gnetId: 15490
            revision: 2
            datasource: prometheus
          multicluster:
            gnetId: 15488
            revision: 3
            datasource: prometheus
%{~ endif }
%{~if modules.istio.enabled }
        istio:
          istio-controle-plane:
            gnetId: 7645
            datasource: prometheus
            revision: 146
          istio-mesh:
            gnetId: 7639
            datasource: prometheus
            revision: 146
          istio-performance:
            gnetId: 11829
            datasource: prometheus
            revision: 146
          istio-service:
            gnetId: 7636
            datasource: prometheus
            revision: 146
          istio-workload:
            gnetId: 7630
            datasource: prometheus
            revision: 146
          istio-wasm:
            gnetId: 13277
            datasource: prometheus
            revision: 103
%{~ endif }

      adminUsername: ${ modules.monitoring.grafana.adminUsername }
      adminPassword: ${ modules.monitoring.grafana.adminPassword }

      grafana.ini:
        alerting:
          enabled: false

        unified_alerting:
          enabled: true

        feature_toggles:
          traceToMetrics: true

        auth.anonymous:
          enabled: false
          org_name: Main Org.
          org_role: Admin

        auth:
          disable_login_form: false
          disable_signout_menu: false

        auth.basic:
          # enabled=true is required by grafana config-reloader
          enabled: true

        # Admin user/pass comes from a secret
        #security:
        #  admin_user: admin
        #  admin_password: admin

      ingress:
        enabled: ${ modules.monitoring.grafana.ingress.enabled }
        ingressClassName: ${ modules.monitoring.grafana.ingress.className }
        annotations:
        %{~ if modules.monitoring.grafana.ingress.clusterIssuer != "" }
          cert-manager.io/cluster-issuer: ${ modules.monitoring.grafana.ingress.clusterIssuer }
        %{~ endif }
    #      nginx.ingress.kubernetes.io/auth-realm: Authentication Required - Monitoring
    #      nginx.ingress.kubernetes.io/auth-secret: monitoring-basic-auth
    #      nginx.ingress.kubernetes.io/auth-type: basic
        hosts:
          - ${ modules.monitoring.grafana.ingress.host }
        %{~ if modules.monitoring.grafana.ingress.scheme == "https" }
        tls:
        - hosts:
          - ${ modules.monitoring.grafana.ingress.host }
          secretName: grafana-ingress-tls
        %{~ endif }

    kubeApiServer:
      enabled: false

    kubelet:
      serviceMonitor:
        https: true
        cAdvisor: true

    # TODO: habilitar o bind do kubeproxy no seu configmap
    # https://github.com/aws/containers-roadmap/issues/657
    kubeProxy:
      enabled: false

    nodeExporter:
      enabled: true

    prometheus-node-exporter:
      #priorityClassName: high-priority

      resources:
        limits:
          cpu: 15m
          memory: 40Mi
        requests:
          cpu: 15m
          memory: 40Mi

      updateStrategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: "20%"

    kube-state-metrics:
      extraArgs:
      - --metric-labels-allowlist=nodes=[eks.amazonaws.com/capacityType]

      tolerations:
      - operator: Exists
        effect: NoSchedule

      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: node-role.kubernetes.io/infra
                operator: Exists
          - weight: 100
            preference:
              matchExpressions:
              - key: role
                operator: In
                values:
                - infra

    kubeScheduler:
      enabled: false

    kubeControllerManager:
      enabled: false

    kubeEtcd:
      enabled: false

    coreDns:
      enabled: true

    kubeDns:
      enabled: false
