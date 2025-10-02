🚀 Secured Kubernetes Cluster Deployment
This repository documents the full setup and configuration of a highly available, HTTPS-secured Kubernetes cluster using kubeadm, MetalLB (for Load Balancing), NGINX Ingress, and cert-manager with Let's Encrypt.

⚙️ Phase 1: Node and Cluster Initialization (kubeadm)
This is the foundational setup executed on all VMs before deploying applications.

1. Node Preparation (Executed on ALL Nodes)
   <img width="902" height="347" alt="image" src="https://github.com/user-attachments/assets/a0d16190-e2f9-4ec0-bb17-75a8bb37558a" />
2. Control Plane and Network Setup (Executed on Master Node)
   <img width="906" height="397" alt="image" src="https://github.com/user-attachments/assets/f2570d48-d2c5-4cf2-9f24-ca9fdc391ebd" />

🔒 Phase 2: Load Balancing and Security Configuration
This is the configuration required to expose applications securely over HTTPS using a domain name.

1. MetalLB and NGINX Ingress
   <img width="901" height="227" alt="image" src="https://github.com/user-attachments/assets/0e017134-1462-4e63-ad71-e218ac48558c" />
2. cert-manager and Production Issuer
   <img width="902" height="297" alt="image" src="https://github.com/user-attachments/assets/54d9ad14-8dd3-4f12-8ba6-73334474f01d" />
3. Application and Final HTTPS Setup
   <img width="912" height="391" alt="image" src="https://github.com/user-attachments/assets/cc597b01-9d10-4e13-8817-b21c106a40ff" />





   



