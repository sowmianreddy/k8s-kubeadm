echo "[TASK 1] Update machine."
yum update -y >/dev/null 2>&1

echo "[TASK 2] Install dependency Packages."
yum install vim wget yum-utils device-mapper-persistent-data lvm2 -y

echo "[TASK 3] Add Docker repository."
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "[TASK 4] Install Docker"
yum install docker-ce-18.06.2.ce -y

echo "[TASK 5] Enable, Start & Check Docker service Status."
systemctl enable docker
systemctl start docker
systemctl status docker

echo "[TASK 6] Disable SELinux."
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

echo "[TASK 7] Disable firewalld."
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld >/dev/null 2>&1

echo "[TASK 8] k8s configure ip6tables."
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1

echo "[TASK 9] off SWAP"
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

echo "[TASK 10] "
cat >>/etc/containerd/config.toml<<EOF
plugins.cri.systemd_cgroup = true
EOF

echo "[TASK 11] Add kubernetes Repository."
#Add yum repo file for kubernetes
cat >>/etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum repolist -y

echo "[TASK 12] Install kubeadm, kubelet & kubectl version 1.15.3"
yum install -y -q kubeadm-1.15.3 kubelet-1.15.3 kubectl-1.15.3

echo "[TASK 13] enable & start kubelet."
systemctl enable kubelet >/dev/null 2>&1
systemctl start kubelet >/dev/null 2>&1
systemctl status kubelet

