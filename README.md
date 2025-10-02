# kubernates-Cluster-Deployment
Secured Kubernetes Cluster Deployment

This repository documents the full setup and configuration of a highly available, HTTPS-secured Kubernetes cluster using kubeadm, MetalLB (for Load Balancing), NGINX Ingress, and cert-manager with Let's Encrypt.

⚙️ Phase 1: Node and Cluster Initialization (kubeadm)
This is the foundational setup executed on all VMs before deploying applications.

1. Node Preparation (Executed on ALL Nodes)
Disable Swap (Crucial):	sudo swapoff -a sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
Enable Kernel Modules:	sudo modprobe overlay sudo modprobe br_netfilter sudo sysctl --system
Install Containerd:	sudo apt update && sudo apt install -y containerd `sudo containerd config default
Install K8s Tools	(Add K8s Repo first): sudo apt update sudo apt install -y kubelet kubeadm kubectl sudo apt-mark hold kubelet kubeadm kubectl


2. Control Plane and Network Setup (Executed on Master Node)
Initialize Cluster:	sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=<Control_Plane_Internal_IP>
Configure kubectl:	mkdir -p $HOME/.kube sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config sudo chown $(id -u):$(id -g) $HOME/.kube/config
Install CNI (Calico):	kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
Worker Node Joins:	Execute the kubeadm join command from the init output on all worker nodes.
Verification:	kubectl get nodes

Export to Sheets
🔒 Phase 2: Load Balancing and Security Configuration
This is the configuration required to expose applications securely over HTTPS using a domain name.

1. MetalLB and NGINX Ingress
Install Ingress:	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
Verify Ingress IP	kubectl get svc -n ingress-nginx (MetalLB assigns 10.0.11.200 as the External IP)

Export to Sheets
2. cert-manager and Production Issuer

Install cert-manager	kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
Configure Issuer	NOTE: Ensure your cluster-issuer.yaml uses a valid email (not example.com). kubectl apply -f cluster-issuer.yaml
Verification	kubectl get clusterissuer letsencrypt-prod (Must show READY: True)


3. Application and Final HTTPS Setup

Application Deployment	kubectl apply -f nginx-app.yaml
Configure Ingress	NOTE: Set the Ingress annotation to cert-manager.io/cluster-issuer: letsencrypt-prod for your final production certificate.
Apply Ingress	kubectl apply -f nginx-ingress.yaml
Trigger Production Cert	kubectl delete certificate ipfire-xcpng-tls-secret
Final Verification	kubectl get certificate ipfire-xcpng-tls-secret (Must show READY: True)


