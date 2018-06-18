#!/bin/bash

################################################################
# Descripcion:	Script para realizar las diferentes tareas
#				de configuracion de los nodos nuevos
################################################################

################################################################
# Variables
keygen='/usr/bin/ssh-keygen'
copyid='/usr/bin/ssh-copy-id'
spin='\|/'
progreso=1
blue='\e[1;34m';
restore='\e[0m';
################################################################
################################################################
################################################################
##########Funciones
################################################################




################################################################
################################################################
################################################################
####Funcion que comprueba que la operacion anterior haya ido bien
################################################################
function comprobar {
	if [ $? -eq 0] ; then
	
		echo -e $blue 'ok' $restore
	fi ;
}
################################################################
################################################################
################################################################
#####Modifica el etc/hosts con los miembros del cluster
################################################################

function crearhosts {
while [ $a == 's' ] ;
do
echo -e $blue 'Introduzca ip del nodo por favor' $restore

read ip

echo -e $blue 'Introduzca el nombre del nodo por favor' $restore

read nombrenodo

echo $ip $nombrenodo >> /etc/hosts
echo $nombrenodo >> /tmp/listahost.txt

echo -e $blue 'Desea añadir otro nodo? (s/n)' $restore


read a
done
} 
################################################################
################################################################
################################################################
#####Genera la key privada y crea el directorio /root/.ssh
################################################################
function generarkey {

	echo -e $blue 'Se continua con la ejecucion....' $restore
echo -e $blue 'Siga las instrucciones segun se le soliciten' $restore

mkdir /root/.ssh/
#ssh localhost
echo -e $blue 'Generando clave' $restore
$keygen

}
################################################################
################################################################
################################################################
######Actualiza el sistema
################################################################


function actualizacion {

sudo yum update -y
#se ha de comprobar que ha terminado
comprobar

}

################################################################
################################################################
################################################################
####Instala paquetes esenciales del sistema y paquetes para formar el cluster.
################################################################

function instalacion {

echo -e $blue 'Paqueteria actualizada' $restore
echo -e $blue 'Comienza la instalacion de paquetes adicionales.....' $restore
sudo yum install -y wget
comprobar
sudo yum install -y vsftpd
comprobar

echo -e $blue 'Comienza la instalacion de paquetes adicionales de monitorizacion del sistema' $restore
echo -e $blue 'Espere por favor.....' $restore
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -O /tmp/epel-release-latest-7.noarch.rpm
comprobar
rpm -Uvh /tmp/epel-release-latest-7.noarch.rpm
comprobar
sudo yum install -y htop
comprobar
sudo yum install -y nmon
comprobar
sudo yum install -y sysstat
comprobar
sudo yum install -y bzip2
comprobar
sudo yum install -y ntpd
comprobar
sudo yum install -y rdate
comprobar
sudo yum install -y rsync
comprobar
sudo yum install -y traceroute
comprobar

#hay que comprobar la hora del sistema, para ello debemos configurar el ntpd.conf o bien realizar un rdate contra el server que 
#queramos, es decir, rdate servidor


echo -e $blue 'Quiere que el nodo tenga lo necesacion para formar parte de un cluster? (s/n)' $restore
read a

if [ $a == 's' ]; then
 	echo -e $blue 'Comienza la instalacion de paqutes necesarios para el cluster' $restore
		wget  http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-7/network:ha-clustering:Stable.repo -O /etc/yum.repos.d/network:ha-clustering:Stable.repo
		sudo yum install -y pacemaker
		comprobar
		sudo yum install -y corosync
		comprobar
		sudo yum install -y crmsh
		comprobar
 fi ;
	
echo -e $blue 'Espere por favor......' $restore

}

################################################################
################################################################
################################################################
#Primera pregunta del programa para empezar a creandoe el /etc/hosts
echo -e $blue 'Quieres añadir un nodo/s al /etc/hosts? (s/n)' $restore


read a
if [[ $a == 's' ]]; then
touch /tmp/listahost.txt

crearhosts
comprobar

fi



echo -e $blue 'Comienza la instalacion/configuracion del/los nodo/s' $restore
################################################################
################################################################
####Propaga las keys publicas por los miembros del cluster, tomando sus nombres de un fichero creado en el tmp
echo -e $blue '¿Desea continuar con la generacion de las keys? (s/n' $restore
read a
if [[ $a == 's' ]]; then
	#statements
	generarkey
	for i in $(cat /tmp/listahost.txt); do 
		$copyid -i /root/.ssh/id_rsa.pub root@$i ; done
fi
echo -e $blue  '¿Desea continuar con la actualización del sistema? (s/n)' $restore



read b

if [[ $b == 's' ]]; then


	echo -e $blue "Comenzando proceso de instalacion de paquetes, ¿Desea continuar? (s/n)" $restore
	read b
	if [[ $b == 's' ]]; then
		instalacion
	fi
		echo -e $blue 'Comienza la actualizacion del/...Espere por favor.....'  $restore
	actualizacion
fi

echo -e $blue "Fin de la instalación" $restore
echo -e $blue "" $restore
echo -e $blue "" $restore
echo -e $blue "" $restore
echo -e $blue "Bay" $restore









