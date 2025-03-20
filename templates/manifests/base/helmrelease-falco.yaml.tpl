%{ if modules.falco.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: falco
  namespace: flux-system
spec:
  chart:
    spec:
      chart: falco
      sourceRef:
        kind: HelmRepository
        name: falcosecurity
      version: "~> 4.19"
  install:
    createNamespace: true
    disableWait: true
    remediation:
      retries: -1
  upgrade:
    disableWait: true
    remediation:
      retries: -1
  interval: 5m
  releaseName: falco
  storageNamespace: falco-system
  targetNamespace: falco-system
  values:
    tty: true
    driver:
      enabled: true
      kind: auto
    falco:
      grpc:
        enabled: true
      grpc_output:
        enabled: true
      log_syslog: false
    metrics:
      enabled: false # prometheus-metrics is broken
      outputRule: true
    serviceMonitor:
      create: false # prometheus-metrics is broken
    tolerations:
    - effect: NoSchedule
      operator: Exists

    collectors:
      kubernetes:
        enabled: true
        grafana:
          dashboards:
            enabled: true
        serviceMonitor:
          create: true
          interval: 30s
        nodeSelector:
          node-role.kubernetes.io/infra: ""
        tolerations:
        - key: dedicated
          value: infra
          effect: NoSchedule

    falcosidekick:
      enabled: true
      prometheusRules:
        enabled: true
        alerts:
          warning:
            # -- enable the high rate rule for the warning events
            enabled: true
            # -- rate interval for the high rate rule for the warning events
            rate_interval: "5m"
            # -- threshold for the high rate rule for the warning events
            threshold: 5
          error:
            # -- enable the high rate rule for the error events
            enabled: true
            # -- rate interval for the high rate rule for the error events
            rate_interval: "5m"
            # -- threshold for the high rate rule for the error events
            threshold: 1
          critical:
            # -- enable the high rate rule for the critical events
            enabled: true
            # -- rate interval for the high rate rule for the critical events
            rate_interval: "5m"
            # -- threshold for the high rate rule for the critical events
            threshold: 0
          alert:
            # -- enable the high rate rule for the alert events
            enabled: true
            # -- rate interval for the high rate rule for the alert events
            rate_interval: "5m"
            # -- threshold for the high rate rule for the alert events
            threshold: 1
          emergency:
            # -- enable the high rate rule for the emergency events
            enabled: true
            # -- rate interval for the high rate rule for the emergency events
            rate_interval: "5m"
            # -- threshold for the high rate rule for the emergency events
            threshold: 0
          output:
            # -- enable the high rate rule for the errors with the outputs
            enabled: false
            # -- rate interval for the high rate rule for the errors with the outputs
            rate_interval: "5m" 
            # -- threshold for the high rate rule for the errors with the outputs
            threshold: 5
          additionalAlerts: {}
      webui:
        enabled: true
      grafana:
        dashboards:
          enabled: true
      serviceMonitor:
        enabled: true
      nodeSelector:
        node-role.kubernetes.io/infra: ""
      tolerations:
      - key: dedicated
        value: infra
        effect: NoSchedule

%{ if modules.falco.event-generator.enabled ~}
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: event-generator
  namespace: flux-system
spec:
  chart:
    spec:
      chart: event-generator
      sourceRef:
        kind: HelmRepository
        name: falcosecurity
      version: "~> 0.3"
  install:
    createNamespace: true
    disableWait: true
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  releaseName: event-generator
  storageNamespace: falco-system
  targetNamespace: falco-system
  values:
    config:
      # -- The event-generator accepts two commands (run, test): 
      # run: runs actions.
      # test: runs and tests actions.
      # For more info see: https://github.com/falcosecurity/event-generator
      command: test
      # -- Regular expression used to select the actions to be run.
      actions: "^syscall"
      # -- Runs in a loop the actions.
      # If set to "true" the event-generator is deployed using a k8s deployment otherwise a k8s job.
      loop: true
      # -- The length of time to wait before running an action. Non-zero values should contain 
      # a corresponding time unit (e.g. 1s, 2m, 3h). A value of zero means no sleep. (default 100ms)
      sleep: "5m"
%{~ endif }
%{ if modules.falco.node-setup.enabled ~}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-setup
  namespace: kube-system
spec:
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app.kubernetes.io/instance: node-setup
      app.kubernetes.io/name: node-setup
  template:
    metadata:
      labels:
        app.kubernetes.io/instance: node-setup
        app.kubernetes.io/name: node-setup
      name: node-setup
    spec:
      containers:
      - command:
        - chroot
        - /host
        - /bin/sh
        - -xc
        - |-
%{~ if contains(["aks", "eks", "oke"], cluster_type) }
          yum -y install kernel-devel kernel-headers
%{~ endif }
          sleep inf
        image: alpine
        imagePullPolicy: Always
        name: setup
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /host
          name: host-root
      enableServiceLinks: true
      hostIPC: true
      hostNetwork: true
      hostPID: true
      priority: 0
      restartPolicy: Always
      serviceAccount: default
      serviceAccountName: default
      terminationGracePeriodSeconds: 10
      tolerations:
      - key: dedicated
        value: infra
        effect: NoSchedule
      volumes:
      - hostPath:
          path: /
          type: ""
        name: host-root
  updateStrategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 20%
    type: RollingUpdate
%{~ endif }

%{~ endif }
