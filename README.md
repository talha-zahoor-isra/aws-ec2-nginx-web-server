# AWS EC2 Nginx Web Server with Bastion Host and Application Load Balancer

A hands-on AWS deployment project demonstrating a secure, layered web-server architecture using **two EC2 instances**, a **Bastion Host**, an **Ubuntu/Nginx Web Server**, an **Application Load Balancer (ALB)**, DNS, HTTPS, and GitHub documentation.

---

## Project Overview

The final architecture separates **administrative access** from **public web traffic**.

Two EC2 instances are used:

1. **Bastion Host** — the administrative/jump server used to access the Web Server.
2. **Web Server** — the Ubuntu EC2 instance running Nginx and hosting the static website.

An **Application Load Balancer** is placed in front of the Web Server. The project domains point to the **Load Balancer**, rather than directly to the Web Server.

### Main Traffic Flow

```text
                         Internet
                            |
                            v
                       DNS / Domain
                            |
                            v
              +-------------------------+
              | Application Load        |
              | Balancer (ALB)          |
              +------------+------------+
                           |
                           v
              +-------------------------+
              | Web Server EC2          |
              | Ubuntu + Nginx          |
              | Static Website           |
              +-------------------------+
```

### Administrative Access Flow

```text
Administrator
      |
      | SSH
      v
+------------------+
| Bastion Host EC2 |
+--------+---------+
         |
         | SSH
         v
+------------------+
| Web Server EC2   |
| Ubuntu + Nginx   |
+------------------+
```

The Bastion Host is therefore used for server administration, while the Application Load Balancer is used as the public entry point for website traffic.

---

## Architecture Components

| Component | Role |
|---|---|
| AWS VPC | Provides the isolated network environment |
| Bastion Host EC2 | Secure administrative/jump host |
| Web Server EC2 | Hosts the static website using Nginx |
| Application Load Balancer | Public entry point and traffic forwarding layer |
| Target Group | Connects the Load Balancer to the Web Server |
| Security Groups | Control traffic between AWS resources |
| DNS | Directs the domains to the Load Balancer |
| Ubuntu | Operating system for the EC2 servers |
| Nginx | Web server for the static website |
| Let's Encrypt | Provides the SSL/TLS certificate |
| Certbot | Automates SSL configuration |
| Git/GitHub | Version control and project documentation |

---

## AWS Environment

The original EC2/Nginx deployment was created in the following AWS environment:

| Item | Configuration |
|---|---|
| AWS Region | `us-east-1` (N. Virginia) |
| Availability Zone | `us-east-1c` |
| VPC | `Talha-Web-VPC` |
| Public Subnet | `Talha-Public-Subnet` |
| Web Server Instance Type | `t3.micro` |
| Operating System | Ubuntu 26.04 LTS |
| Web Server | Nginx |
| Domain | `talhaweb.redirectme.net` |

The deployment was originally documented with a custom VPC, public subnet, Internet Gateway/routing, EC2, Security Group, DNS, and HTTPS configuration.

---

## VPC and Networking

A custom VPC was created for the AWS environment.

The network included:

- Custom VPC
- Subnets for the AWS resources
- Internet Gateway
- Route-table configuration
- Security Groups
- Bastion Host
- Web Server
- Application Load Balancer

The architecture separates the **administration path** from the **public website traffic path**.

### Public Website Path

```text
User
 ↓
DNS
 ↓
Application Load Balancer
 ↓
Target Group
 ↓
Web Server
 ↓
Nginx
 ↓
Static HTML
```

### Administration Path

```text
Administrator
 ↓
Bastion Host
 ↓
SSH
 ↓
Web Server
```

---

## Bastion Host

The Bastion Host is a separate EC2 instance used as a controlled administration point.

Instead of using the Web Server as the direct SSH entry point, administrative access follows:

```text
Local Administrator
        ↓
   Bastion Host
        ↓
     SSH
        ↓
    Web Server
```

This separates server administration from the public web-service path.

The Bastion Host does **not** host the website. The website is hosted on the separate Web Server EC2 instance.

---

## Web Server

The Web Server is the EC2 machine responsible for running the website.

It runs:

- Ubuntu
- Nginx
- Static HTML website
- Nginx site configuration
- HTTPS configuration

The static website is stored at:

```text
/var/www/html/index.html
```

No PHP or database is required because the project is a static website.

---

## Application Load Balancer

The **Application Load Balancer (ALB)** is the public entry point for the website.

Instead of configuring the domains to point directly to the Web Server, the domains are directed toward the Load Balancer.

```text
Domain
  ↓
Application Load Balancer
  ↓
Target Group
  ↓
Web Server EC2
  ↓
Nginx
  ↓
Website
```

The Web Server is registered as a target behind the Load Balancer.

This architecture provides a separate public traffic layer in front of the web server.

---

## Security Groups

Security Groups control access between the AWS components.

The architecture uses different access requirements for:

### Bastion Host

SSH access is allowed for administration from the authorized administrator source.

### Web Server

The Web Server is accessed administratively through the Bastion Host and receives web traffic through the Load Balancer.

### Load Balancer

The Load Balancer accepts public website traffic and forwards it to the Web Server.

The exact Security Group rules should match the final AWS console configuration used in the deployment.

---

## Connecting to the Infrastructure

The administration workflow starts from the administrator's local machine.

SSH is used to access the Bastion Host, and the Bastion Host is then used to reach the Web Server.

Example SSH syntax:

```bash
ssh -i "<private-key>.pem" ubuntu@<bastion-public-ip>
```

From the Bastion Host:

```bash
ssh -i "<private-key>.pem" ubuntu@<web-server-private-ip>
```

The private `.pem` key must remain protected and must never be committed to GitHub.

---

## Installing Nginx

On the Web Server:

```bash
sudo apt update
sudo apt install nginx -y
```

### Purpose

- `apt update` refreshes the available Ubuntu package information.
- `apt install nginx -y` installs the Nginx web server.

Nginx is the web server responsible for serving the static HTML website.

---

## Starting and Enabling Nginx

```bash
sudo systemctl enable nginx
sudo systemctl start nginx
```

`enable` configures Nginx to start automatically after a system reboot.

`start` starts the service immediately.

Check the service:

```bash
sudo systemctl status nginx
```

The expected result is an active and running Nginx service.

---

## Nginx Configuration Test

Before relying on the configuration, its syntax is checked with:

```bash
sudo nginx -t
```

Successful output confirms that the Nginx configuration syntax is valid.

---

## Static Website Deployment

The static website is deployed to:

```text
/var/www/html/index.html
```

Nginx serves this file to visitors.

The website can be tested locally from the Web Server:

```bash
curl http://localhost
```

A successful HTML response confirms that Nginx can serve the website locally.

---

## Nginx Site Configuration

The active Nginx site configuration is stored on the Web Server at:

```text
/etc/nginx/sites-enabled/talhaweb
```

The configuration can be copied to the local GitHub project for documentation and reproducibility.

Example SCP syntax:

```powershell
scp -i "<private-key>.pem" ubuntu@<server>:/etc/nginx/sites-enabled/talhaweb "<local-project>\nginx\talhaweb"
```

SCP is used to securely transfer files between machines.

---

## DNS Configuration

The important difference in the final architecture is that the website domains are configured to reach the **Application Load Balancer**, not the Web Server's IP address.

```text
Domain
   ↓
Application Load Balancer
   ↓
Web Server
```

This makes the Load Balancer the public entry point for the website.

---

## HTTPS / SSL

Let's Encrypt is used to provide a free SSL/TLS certificate.

Certbot can configure Nginx using:

```bash
sudo certbot --nginx -d talhaweb.redirectme.net
```

The installed certificates can be checked with:

```bash
sudo certbot certificates
```

HTTPS protects communication between users and the website.

---

## Installation Script

The repository includes:

```text
scripts/install-nginx.sh
```

The script automates the basic Nginx installation and verification process:

```bash
#!/bin/bash

# Update Ubuntu packages
sudo apt update

# Install Nginx
sudo apt install nginx -y

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Test Nginx configuration
sudo nginx -t

# Check Nginx status
sudo systemctl status nginx --no-pager
```

### Script Workflow

```text
Update packages
      ↓
Install Nginx
      ↓
Enable Nginx
      ↓
Start Nginx
      ↓
Test configuration
      ↓
Check service status
```

---

## Testing and Verification

The deployment is verified at multiple layers.

### 1. Bastion Host Access

Verify that the administrator can connect to the Bastion Host using SSH.

### 2. Web Server Access

From the Bastion Host, verify SSH access to the Web Server.

### 3. Nginx Service

```bash
sudo systemctl status nginx
```

### 4. Nginx Configuration

```bash
sudo nginx -t
```

### 5. Local Website

```bash
curl http://localhost
```

### 6. Load Balancer

Verify that the Web Server is registered as a healthy target in the Load Balancer's Target Group.

### 7. DNS

Verify that the domain resolves toward the Load Balancer.

### 8. HTTPS

Verify that the public domain loads successfully over HTTPS.

---

## Project Structure

```text
aws-ec2-nginx-web-server/
│
├── README.md
│
├── nginx/
│   └── talhaweb
│
├── scripts/
│   └── install-nginx.sh
│
├── website/
│   └── index.html
│
├── screenshots/
│   └── ...
│
└── .gitignore
```

### Files and Directories

| Path | Purpose |
|---|---|
| `README.md` | Complete project documentation |
| `nginx/talhaweb` | Nginx site configuration |
| `scripts/install-nginx.sh` | Nginx installation and verification script |
| `website/index.html` | Static website source |
| `screenshots/` | AWS and deployment screenshots |
| `.gitignore` | Prevents sensitive files from being committed |

---

## Git and GitHub

Git was used to version-control the project and publish the configuration, website source, installation script, screenshots, and documentation.

### Initialize Git

```bash
git init
```

### Configure Git

```bash
git config --global user.name "Muhammad Talha Zahoor"
git config --global user.email "muhammadtalhazahoor06@gmail.com"
```

### Add Project Files

```bash
git add .
```

### Create Commit

```bash
git commit -m "Initial AWS EC2 web server project"
```

### Set Main Branch

```bash
git branch -M main
```

### Add GitHub Remote

```bash
git remote add origin https://github.com/talha-zahoor-isra/aws-ec2-nginx-web-server.git
```

### Push to GitHub

```bash
git push -u origin main
```

Repository:

https://github.com/talha-zahoor-isra/aws-ec2-nginx-web-server

---

## Security Considerations

- The private `.pem` key is kept outside the GitHub repository.
- SSH administration is restricted rather than exposed as unrestricted public access.
- The Bastion Host is used as the administrative entry point to the Web Server.
- The Web Server is placed behind the Application Load Balancer for public website traffic.
- Public web traffic is handled through the Load Balancer.
- Security Groups control communication between the Bastion Host, Load Balancer, and Web Server.
- `.gitignore` is used to help prevent private keys, environment files, and credentials from being committed.

---

## Deployment Flow

```text
Create VPC
   ↓
Configure Subnets
   ↓
Configure Internet Gateway / Routing
   ↓
Create Security Groups
   ↓
Launch Bastion Host EC2
   ↓
Launch Web Server EC2
   ↓
Configure Bastion → Web Server SSH
   ↓
Connect to Web Server
   ↓
Install Nginx
   ↓
Enable and Start Nginx
   ↓
Deploy Static HTML Website
   ↓
Configure Nginx Site
   ↓
Create Application Load Balancer
   ↓
Create Target Group
   ↓
Register Web Server
   ↓
Verify Target Health
   ↓
Configure Domain / DNS → Load Balancer
   ↓
Configure HTTPS / SSL
   ↓
Test Website
   ↓
Document Project in GitHub
```

---

## Final Architecture Summary

The completed project demonstrates a layered AWS web-server deployment:

### Bastion Host

Used for secure administrative access to the Web Server.

### Web Server

A separate Ubuntu EC2 instance running Nginx and serving the static website.

### Application Load Balancer

Acts as the public entry point and forwards website requests to the Web Server.

### DNS

The project domains are directed to the Load Balancer rather than directly to the Web Server.

### HTTPS

The website is secured using Let's Encrypt and Certbot.

### GitHub

The website source, Nginx configuration, installation script, screenshots, and documentation are maintained in the project repository.

---

## Screenshots

The `screenshots/` directory contains evidence of the deployment process.

Recommended screenshots include:

- VPC configuration
- Subnets
- Route tables
- Internet Gateway
- Bastion Host EC2
- Web Server EC2
- Security Groups
- Application Load Balancer
- Target Group
- Healthy Web Server target
- SSH connection through Bastion Host
- Nginx service status
- `nginx -t`
- Static website
- DNS configuration
- HTTPS website
- GitHub repository

---

## Project Outcome

The project demonstrates how to deploy a static website on AWS using a separated administration and web-serving architecture.

The final request flow is:

```text
User
 ↓
Domain
 ↓
Application Load Balancer
 ↓
Web Server EC2
 ↓
Nginx
 ↓
Static Website
```

Administrative access follows a separate path:

```text
Administrator
 ↓
Bastion Host EC2
 ↓
SSH
 ↓
Web Server EC2
```

This architecture clearly separates **public web traffic** from **server administration** while documenting the complete AWS, Nginx, DNS, HTTPS, and GitHub workflow.

---

## Author

**Muhammad Talha Zahoor**

BSCS Graduate | Aspiring DevOps Engineer

GitHub:

https://github.com/talha-zahoor-isra

Project Repository:

https://github.com/talha-zahoor-isra/aws-ec2-nginx-web-server
