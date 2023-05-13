#!/bin/bash

clear

if [[ $EUID -ne 0 ]]; then
	echo "Por favor ejecuta como root/sudo" 1>&2
	exit 1
else
	
	echo "+----------------------------------------------------------------------+"
	echo "Se iniciará el script para traer datos de la siguiente página:"
	echo -e "\e[32mwww.dtpm.cl/index.php/noticias/gtfs-vigente\e[0m"
	echo "+----------------------------------------------------------------------+"
	echo -e "\n"

	echo "Se iniciará la descarga y configuración de los paquetes necesarios.."
	echo -e ""
	echo "+-------------------------------+"
	echo "|     Nombre de los paquetes:   |"
	echo "+-------------------------------+"
	echo "|    cargo     |     htmlq      |"
	echo "+-------------------------------+"
	echo ""
	read -n 1 -s -r -p "Presiona cualquier tecla para continuar..."
	echo -e "\n"

	echo "Iniciando instalación de cargo..."
	echo ""
	sudo apt install -y cargo

	echo ""
	echo "Iniciando instalación de htmlq..."
	echo ""
	sudo cargo install htmlq

	echo ""
	echo "Actualizando variable PATH..."
	echo ""
	export PATH="${PATH}:${HOME}/.cargo/bin"
	. ~/.profile

	echo ""
	echo "Instalando curl en caso que no esté"
	echo ""
	sudo apt install -y curl

	echo ""
	curl --silent https://www.dtpm.cl/index.php/noticias/gtfs-vigente | htmlq a --attribute href -b https://www.dtpm.cl/index.php/noticias/gtfs-vigente >> links.txt
	
	while IFS= read -r line; do
		if [[ $line == *".zip"* ]]; then
			link_descarga=$line
		fi
	done <<< $(cat links.txt)

	echo "Encontrado link de descarga: $link_descarga"
	echo ""
	echo ""

	read -p "Ingresa nombre del bucket: " nombre_bucket

	curl $link_descarga | gsutil cp - gs://$nombre_bucket/gtfs_santiago.zip

	gsutil cat gs://$nombre_bucket/gtfs_santiago.zip | for i in $(jar --list); do gsutil cat gs://$nombre_bucket/gtfs_santiago.zip | jar x $i && cat $i | gsutil cp - gs://$nombre_bucket/unzipped/$i && rm ./$i; done;
fi


