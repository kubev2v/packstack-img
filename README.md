[![packstack-img Repository on Quay](https://quay.io/repository/kubev2v/packstack/status "packstack Repository on Quay")](https://quay.io/repository/kubev2v/packstack)

This repository is used for testing imports from openstack/packstack using Forklift.
# Requirement
- external NFS server v4.1 (tcp only)

Note: cinder assumes that nfs is running on 127.0.0.1 and the connection is relayed to external NFS using socat.


# Deployment
Deployment example on k8s:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: packstack
  namespace: konveyor-forklift
spec:
  replicas: 1
  selector:
    matchLabels:
      app: packstack
  template:
    metadata:
      labels:
        app: packstack
    spec:
      containers:
      - name: packstack
        image: quay.io/eslutsky/packstack:latest
        securityContext:        
          privileged: true
          runAsUser: 0
          capabilities:
            add:
              - ALL
        ports:
        - containerPort: 5000
        - containerPort: 8774        
        - containerPort: 8775
        - containerPort: 8778
        - containerPort: 9292
        - name: neutron-port
          containerPort: 9696
        volumeMounts:
        - mountPath: /lib/modules
          name: kernel-modules
        startupProbe:
          httpGet:
            path: /
            port: 9696
          failureThreshold: 30
          periodSeconds: 10
        env:
          - name: EXTERNAL_IP
            value: <NFS_SERVER_IP>
          - name: NAMESPACE
            value: konveyor-forklift
          - name: PORT
            value: "30001"
      volumes:
      - name: kernel-modules
        hostPath:
          path: /lib/modules
          # this field is optional
          type: Directory

---
apiVersion: v1
kind: Service
metadata:
  name: packstack
  namespace: konveyor-forklift
spec:
  selector:
    app: packstack
  type: NodePort
  ports:
  - name: keystone-api
    port: 5000
    nodePort: 30050
  - name: nova-api
    port: 8774
  - name: nova-8775
    port: 8775
  - name: placeement-api
    port: 8778
  - name: glance-api
    port: 9292    
  - name: neutron-api
    port: 9696    

```
