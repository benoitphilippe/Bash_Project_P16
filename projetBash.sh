#!/bin/bash
clear

echo Bienvenue sur le projet LO14 de Benoit Philippe et Victor Bouillot
echo Le synchroniseur de fichier
echo

#test if .synchro exists
#1ere Partie
#si le journal existe OK
#s'il n'existe pas on en crée un avec toutes les métadonnées d'un répertoire A dont le chemin est demandé à l'utilsateur



if test -f $HOME/Programmes/.synchro
then
	echo "le journal entre les deux répertoires existe"
	repertoireA= readlink $( head -n -1 $HOME/Programmes/.synchro) 
	#echo $( head -n 1 $HOME/Programmes/.synchro )
	echo $repertoireA
	repertoireA= $(sed -n '1p' $HOME/Programmes/.synchro)
	repertoireB= $( sed -n '2p' $HOME/Programmes/.synchro)
	echo "$repertoireA $repertoireB sont les meilleurs"
	
else
	echo "le journal entre les deux répertoires n'existe pas"
	echo "le journal vient d'être créé"
	echo "Veuillez donner le premier répertoire à synchroniser:"
	read repertoireA

	while [ ! -d $repertoireA ]
	do
		echo "$repertoireA n'est pas un répertoire"
		echo "Veuillez donner le premier répertoire à synchroniser:"
		read repertoireA
	done

	echo "Veuillez donner le deuxième répertoire à synchroniser:"
	read repertoireB

	while [ ! -d $repertoireB ]
	do
		echo "$repertoireB n'est pas un répertoire"
		echo "Veuillez donner le deuxième répertoire à synchroniser:"
		read repertoireB
	done
		
	echo "$repertoireA" > $HOME/Programmes/.synchro
	echo "$repertoireB" >> $HOME/Programmes/.synchro

	#test pour voir ce qu'il y a dans le journal
	echo
	cat $HOME/Programmes/.synchro
	

	#on demandera à l'utilisateur 2 répertoires
	#ensuite on créera un journal entre les deux avec toutes les données et tout et tout
fi



repertoireA=/home/victor/DossierA
repertoireB=/home/victor/DossierB

echo "Vérification des dossiers"
for fichier1 in $repertoireA/*
do
	fichier2=`echo $repertoireB/$( basename $fichier1 )` #on place dans la variable le chemin absolu vers le potentiel fichier2 
	#echo $fichier1 $fichier2
	
	if test -e $fichier2 #on vérifie s'il y a bien un fichier de ce nom là dans le repertoireB
	then
		echo "le fichier $fichier2 existe"
		
		if [[ -f $fichier1 && -f $fichier2 ]] #on verifie que les 2 fichiers sont du même type
		then
		
			#on vérifie les métadonnées des deux fichiers		
			taille1=$(stat -c %s $fichier1)
			taille2=$(stat -c %s $fichier2)
			echo $taille1 $taille2

			acces1=$(stat -c %A $fichier1)
			acces2=$(stat -c %A $fichier2)
			echo $acces1 $acces2
		
			datem1=$(stat -c %z $fichier1)
			datem2=$(stat -c %z $fichier2)
			echo $datem1 $datem2
			
			type1=$(file $fichier1)
			type2=$(file $fichier2)
			echo $type1 $type2
		fi

			if test $taille1 -eq $taille2 && $acces1 -eq $acces2 && $datem1 -eq $datem2
			then
				echo "les fichiers sont identiques, il ne faut pas les modifier"
			else
				echo "erreur: Fichiers différents"
				echo "lequel modifier?"  
			fi

		
		
	else
		echo "le fichier $fichier2 n'existe pas"
	fi

done





#2eme Partie
#cette Partie consiste à synchroniser les deux répertoires, le tout en modifiant le journal





#rm $HOME/Programmes/.synchro






