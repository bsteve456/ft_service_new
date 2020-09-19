#! bin/bash

FILE=srcs/install_dir/one_time_file
if [ $1 -eq 1 ]
then
	minikube delete
	echo "create one time file."
	touch $FILE
fi
minikube config set vm-driver virtualbox
minikube start --memory 3000 --bootstrapper=kubeadm
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
kubectl apply -f ./srcs/install_dir/config.yaml
docker build -t nginx-alpine ./srcs/nginx/
docker build -t ftps_alpine ./srcs/ftps/
docker build -t mysql_alpine ./srcs/mysql/
docker build -t wordpress_alpine ./srcs/wordpress/
docker build -t phpmyadmin_alpine ./srcs/phpmyadmin/


kubectl apply -k ./srcs/
minikube dashboard
