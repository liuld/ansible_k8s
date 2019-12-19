#!/usr/bin/env bash
# build k8s certs

CERT_DIR=$1
KUBE_API_IP=$2

touch ~/.rnd
cd ${CERT_DIR}
cat > openssl.cnf <<EOF
[ req ]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[ req_distinguished_name ]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
IP.1 = ${KUBE_API_IP}
EOF

# ca cert
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kubernetes/O=k8s"

# docker cert
openssl genrsa -out docker-key.pem 2048
openssl req -new -key docker-key.pem -out docker.csr -subj "/CN=docker"
openssl x509 -req -in docker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out docker.pem -days 10000

# etcd cert
openssl genrsa -out etcd-key.pem 2048
openssl req -new -key etcd-key.pem -out etcd.csr -subj "/CN=etcd"
openssl x509 -req -in etcd.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out etcd.pem -days 10000

# flannel cert
openssl genrsa -out flanneld-key.pem 2048
openssl req -new -key flanneld-key.pem -out flanneld.csr -subj "/CN=flanneld"
openssl x509 -req -in flanneld.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out flanneld.pem -days 10000

# admin cert
openssl genrsa -out admin-key.pem 2048
openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=admin/O=system:masters"
openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 10000

# kubeapiserver cert
openssl genrsa -out kubernetes-key.pem 2048
openssl req -new -key kubernetes-key.pem -out kubernetes.csr -subj "/CN=kubernetes/O=k8s" -config ${CERT_DIR}openssl.cnf
openssl x509 -req -in kubernetes.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kubernetes.pem -days 10000 -extensions v3_req -extfile ${CERT_DIR}openssl.cnf

# kube-scheduler cert
openssl genrsa -out kube-scheduler-key.pem 2048
openssl req -new -key kube-scheduler-key.pem -out kube-scheduler.csr -subj "/CN=system:kube-scheduler/O=system:kube-scheduler"
openssl x509 -req -in kube-scheduler.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kube-scheduler.pem -days 10000

# kube-controller-manager cert
openssl genrsa -out kube-controller-manager-key.pem 2048
openssl req -new -key kube-controller-manager-key.pem -out kube-controller-manager.csr -subj "/CN=system:kube-controller-manager/O=system:kube-controller-manager"
openssl x509 -req -in kube-controller-managercsr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kube-controller-manager.pem -days 10000

# kube-proxy cert
openssl genrsa -out kube-proxy-key.pem 2048
openssl req -new -key kube-proxy-key.pem -out kube-proxy.csr -subj "/CN=system:kube-proxy/O=k8s"
openssl x509 -req -in kube-proxy.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kube-proxy.pem -days 10000

# kubelet cert
openssl genrsa -out kubelet-key.pem 2048
openssl req -new -key kubelet-key.pem -out kubelet.csr -subj "/CN=system:kubelet/O=k8s"
openssl x509 -req -in kubelet.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out kubelet.pem -days 10000
