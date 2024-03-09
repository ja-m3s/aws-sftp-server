#!/usr/bin/env bash

#create toolbox with aws/terraform/git environment in Fedora Silverblue (convenience script)

#terraform
toolbox run sudo dnf update -y
toolbox run sudo dnf install -y dnf-plugins-core
toolbox run sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
toolbox run sudo dnf -y install terraform
toolbox run sudo dnf install -y git 
toolbox run sudo dnf install -y awscli2 
toolbox run sudo dnf install -y pass 

//TODO
//Programmatic access setup i.e. aws configure

