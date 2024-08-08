%{ if modules.monitoring.enabled ~}
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-main
  namespace: openshift-monitoring
type: Opaque
data:
  alertmanager.yaml: ${base64encode(<<EOL
config:
  global:
    resolve_timeout: 10m

  #################################################################
  ## Receivers
  #################################################################

  receivers:
  # Keep compatible with OKD default
  - name: Watchdog

  # does nothing
  - name: blackhole

  #############################
  # Cronitor
  #############################
%{~ if alertmanager_cronitor_id != "" }
  - name: cronitor
    webhook_configs:
    - url: https://cronitor.link/${alertmanager_cronitor_id}/complete
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
  - equal:
    - namespace
    - alertname
    source_matchers:
    - "severity = critical"
    target_matchers:
    - "severity =~ warning|info"
  - equal:
    - namespace
    - alertname
    source_matchers:
    - "severity = warning"
    target_matchers:
    - "severity = info"

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
EOL
)}
%{~ endif }
