#! bin/bash

FILE=srcs/install_dir/one_time_file
if [ $1 -eq 1 ]
then
	echo "create one time file."
	touch $FILE
fi
#minikube config set vm-driver virtualbox
minikube start --driver=docker --bootstrapper=kubeadm
minikube docker-env
eval $(minikube -p minikube docker-env)
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
if test -f "$FILE"; then
	echo "create secretkey."
	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
	rm $FILE
fi
sed -e "s/mini_ip/$(minikube ip)/" srcs/telegraf/telegraf_sample.conf > srcs/telegraf/telegraf.conf
kubectl apply -f ./srcs/install_dir/config.yaml
docker build -t nginx-alpine ./srcs/nginx/
docker build -t ftps_alpine ./srcs/ftps/
docker build -t mysql_alpine ./srcs/mysql/
docker build -t wordpress_alpine ./srcs/wordpress/
docker build -t phpmyadmin_alpine ./srcs/phpmyadmin/
docker build -t influxdb_alpine ./srcs/influxdb/
docker build -t telegraf_alpine ./srcs/telegraf/
docker build -t grafana_alpine ./srcs/grafana/
kubectl apply -k ./srcs/
rm srcs/telegraf/telegraf.conf

minikube dashboard
