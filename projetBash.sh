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
	repertoireA= head -1 $HOME/Programmes/.synchro
	
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


#2eme Partie
#cette Partie consiste à synchroniser les deux répertoires, le tout en modifiant le journal



#rm $HOME/Programmes/.synchro






