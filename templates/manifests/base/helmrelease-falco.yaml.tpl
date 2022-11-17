%{ if modules.falco.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
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
      version: "~> 2.3"
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
  releaseName: falco
  storageNamespace: falco-system
  targetNamespace: falco-system
  values:
    #auditLog:
    #  enabled: true

    driver:
      enabled: true
      kind: ebpf

    falco:
      grpc:
        enabled: true
      grpcOutput:
        enabled: true

      logSyslog: true

    tolerations:
    - effect: NoSchedule
      operator: Exists
%{~ endif }
%{ if modules.falco.falco-exporter.enabled ~}
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: falco-exporter
  namespace: flux-system
spec:
  chart:
    spec:
      chart: falco-exporter
      sourceRef:
        kind: HelmRepository
        name: falcosecurity
      version: "~> 0.9"
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
  releaseName: falco-exporter
  storageNamespace: falco-system
  targetNamespace: falco-system
  values:
    serviceMonitor:
      enabled: true
      interval: "30s"

    prometheusRules:
      enabled: true

    grafanaDashboard:
      enabled: true
      namespace: monitoring

    tolerations:
    - effect: NoSchedule
      operator: Exists
%{~ endif }
%{ if modules.falco.event-generator.enabled ~}
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
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
      version: "~> 0.2"
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
      - effect: NoSchedule
        operator: Exists
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
