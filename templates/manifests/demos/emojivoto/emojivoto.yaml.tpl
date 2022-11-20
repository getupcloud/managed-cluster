# Source https://run.linkerd.io/emojivoto.yml
#
# Changelog:
#
# 2022-11-19
#    Added annotation linkerd.io/inject=enabled
#    Created Ingress
#
%{~ if modules.linkerd.emojivoto.enabled }
apiVersion: v1
kind: Namespace
metadata:
  name: emojivoto
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: emoji
  namespace: emojivoto
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: voting
  namespace: emojivoto
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: web
  namespace: emojivoto
---
apiVersion: v1
kind: Service
metadata:
  name: emoji-svc
  namespace: emojivoto
spec:
  ports:
  - name: grpc
    port: 8080
    targetPort: 8080
  - name: prom
    port: 8801
    targetPort: 8801
  selector:
    app: emoji-svc
---
apiVersion: v1
kind: Service
metadata:
  name: voting-svc
  namespace: emojivoto
spec:
  ports:
  - name: grpc
    port: 8080
    targetPort: 8080
  - name: prom
    port: 8801
    targetPort: 8801
  selector:
    app: voting-svc
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: emojivoto
spec:
  ports:
  - name: http
    port: 80
    targetPort: 8080
  selector:
    app: web-svc
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: emoji
    app.kubernetes.io/part-of: emojivoto
    app.kubernetes.io/version: v11
  name: emoji
  namespace: emojivoto
spec:
  replicas: 1
  selector:
    matchLabels:
      app: emoji-svc
      version: v11
  template:
    metadata:
      annotations:
        linkerd.io/inject: enabled
      labels:
        app: emoji-svc
        version: v11
    spec:
      containers:
      - env:
        - name: GRPC_PORT
          value: "8080"
        - name: PROM_PORT
          value: "8801"
        image: docker.l5d.io/buoyantio/emojivoto-emoji-svc:v11
        name: emoji-svc
        ports:
        - containerPort: 8080
          name: grpc
        - containerPort: 8801
          name: prom
        resources:
          requests:
            cpu: 100m
      serviceAccountName: emoji
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: vote-bot
    app.kubernetes.io/part-of: emojivoto
    app.kubernetes.io/version: v11
  name: vote-bot
  namespace: emojivoto
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vote-bot
      version: v11
  template:
    metadata:
      annotations:
        linkerd.io/inject: enabled
      labels:
        app: vote-bot
        version: v11
    spec:
      containers:
      - command:
        - emojivoto-vote-bot
        env:
        - name: WEB_HOST
          value: web-svc.emojivoto:80
        image: docker.l5d.io/buoyantio/emojivoto-web:v11
        name: vote-bot
        resources:
          requests:
            cpu: 10m
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: voting
    app.kubernetes.io/part-of: emojivoto
    app.kubernetes.io/version: v11
  name: voting
  namespace: emojivoto
spec:
  replicas: 1
  selector:
    matchLabels:
      app: voting-svc
      version: v11
  template:
    metadata:
      annotations:
        linkerd.io/inject: enabled
      labels:
        app: voting-svc
        version: v11
    spec:
      containers:
      - env:
        - name: GRPC_PORT
          value: "8080"
        - name: PROM_PORT
          value: "8801"
        image: docker.l5d.io/buoyantio/emojivoto-voting-svc:v11
        name: voting-svc
        ports:
        - containerPort: 8080
          name: grpc
        - containerPort: 8801
          name: prom
        resources:
          requests:
            cpu: 100m
      serviceAccountName: voting
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: web
    app.kubernetes.io/part-of: emojivoto
    app.kubernetes.io/version: v11
  name: web
  namespace: emojivoto
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-svc
      version: v11
  template:
    metadata:
      annotations:
        linkerd.io/inject: enabled
      labels:
        app: web-svc
        version: v11
    spec:
      containers:
      - env:
        - name: WEB_PORT
          value: "8080"
        - name: EMOJISVC_HOST
          value: emoji-svc.emojivoto:8080
        - name: VOTINGSVC_HOST
          value: voting-svc.emojivoto:8080
        - name: INDEX_BUNDLE
          value: dist/index_bundle.js
        image: docker.l5d.io/buoyantio/emojivoto-web:v11
        name: web-svc
        ports:
        - containerPort: 8080
          name: http
        resources:
          requests:
            cpu: 100m
      serviceAccountName: web
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
%{~ if modules.cert-manager.enabled }
    cert-manager.io/cluster-issuer: letsencrypt-production-http01
%{~ endif }
  name: web-ing
  namespace: emojivoto
spec:
  ingressClassName: nginx
  rules:
  - host: ${ modules.linkerd.emojivoto.hostname }
    http:
      paths:
      - backend:
          service:
            name: web-svc
            port:
              number: 8080
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - ${ modules.linkerd.emojivoto.hostname }
    secretName: emojivoto-tls
%{ endif }
