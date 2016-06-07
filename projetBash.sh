#!/bin/bash
clear

# ------------------------- affiche l'aide pour les options du script --------------------------------------------



function print_help {
	# print on the screen how to use it
	echo ""
	echo -e "bash $0 [\e[4moptions\e[0m ...]"
	echo "|---------------------------------------------------------------------------------------------|"
	echo -e " -c 			: création d'un nouveau système de synchronisation"
	echo -e " -s \e[36mDIRECTORY\e[0m		: dans quel dossier se situe le .synchro (~/ par default)"
	echo -e " -A \e[36mDIRECTORY\e[0m		: où se situe le répertoire A (à utiliser avec l'option -c)"
	echo -e " -B \e[36mDIRECTORY\e[0m		: où se situe le répertoire B (à utiliser avec l'option -c)"
	echo "|---------------------------------------------------------------------------------------------|"
}

# ---------------------------------------- Création du Journal ----------------------------------------------------

creerJournal(){
dossier=$1
PATHSYNCHRO=$2

echo "Rentrée des données Journal"
for fichier in "$dossier"*
do
	if [[ -f "$fichier" ]]; then
		taille=$(stat -c %s "$fichier")
		acces=$(stat -c %A "$fichier")
		datem=$(stat -c %z "$fichier")
		type=$(file "$fichier")
		echo "$fichier>$taille>$acces>$datem>$type" >> "$PATHSYNCHRO/.synchro"
	else
		echo "$fichier n'est pas un fichier"
	fi
	#if [[ -d $fichier ]]
	#then
	#	creerJournal $fichier $PATHSYNCHRO
	#fi  
 
done
}

# ------------------------------------- variables pour le script -----------------------------------------------



PATHSYNCHRO="$HOME"
repertoireA=""
repertoireB=""
NEW='OFF'	#indique si l'on doit créer un nouveau système de sauvegarde




# ---------------------------------------- gestion des paramètre pour le script ----------------------------------------------------



while [[ $# > 0 ]]
do
key="$1"

case $key in
	#check the method asked
    -c|-create)
		NEW='ON' # l'utilisateur veut que l'on créer un nouveau système de synchronisation
    	;;
	-s)
		PATHSYNCHRO="$2"
		shift
		;;
	-A)
		repertoireA="$2"
		shift
		;;
	-B)
		repertoireB="$2"
		shift
		;;
    -h|-help|help|Help|HELP) # print help and exit the script
		print_help
		exit 0
		;;
    *) # unknow option
     	echo "$key : option inconnu"
     	print_help
     	exit 1
    	;;
	esac
	shift # past argument or value
done



# ------------------------------------------------ message d'introduction -------------------------------------------------------------



echo Bienvenue sur le projet LO14 de Benoit Philippe et Victor Bouillot
echo Le synchroniseur de fichier
echo ___________________________________________________________________
echo
echo




# ---------------------------------------- gestion du paramètre -c dans la ligne de commande ------------------------------------------



if [[ $NEW = 'ON' ]]; then # l'utilisateur demande la création d'un nouveau système de sauvegarde
	mkdir -p $PATHSYNCHRO # on créé le chemin
	while [[ ! -d $repertoireA ]]
	do
		echo "répertoirA : $repertoireA n'existe pas"
		echo "Veuillez donner le premier répertoire à synchroniser:"
		read repertoireA
		# repertoireA doit exister si l'on veut qu'il n'y ait aucune erreur
		echo
	done
	while [[ ! -d $repertoireB ]]
	do
		echo "répertoireB : $repertoireB n'est pas un répertoire"
		echo "Veuillez donner le deuxième répertoire à synchroniser / créer:"
		read repertoireB
		mkdir -p $repertoireB
		echo
	done
	
	if [[ "$repertoireA" = /* ]]; then
		echo "$repertoireA" > "$PATHSYNCHRO/.synchro"
	else
		echo "$(pwd)/$repertoireA" > "$PATHSYNCHRO/.synchro" # on complète le chemin relatif
	fi

	if [[ "$repertoireB" = /* ]]; then
		echo "$repertoireB" >> "$PATHSYNCHRO/.synchro"
	else
		echo "$(pwd)/$repertoireB" >> "$PATHSYNCHRO/.synchro" # on complète le chemin relatif
	fi
	
	if [[ "$repertoireA" = /* ]]; then
		creerJournal "$repertoireA" "$PATHSYNCHRO"
	else
		creerJournal "$(pwd)/$repertoireA" "$PATHSYNCHRO"
	fi
	echo "le système de sauvegarde a bien été crée"
fi





# ----------------------------script qui utilise l'intéraction avec l'utilisateur -----------------------------------







# ------------------------- on récupère les dossiers A et B à l'intérieur du .synchro --------------------------------





# test si .synchro existe
# 1ere Partie
# si le journal existe OK
# s'il n'existe pas on en crée un avec toutes les métadonnées d'un répertoire A dont le chemin est demandé à l'utilsateur

if test -f "$PATHSYNCHRO/.synchro"
then # pas de problème, le fichier .syncro existe

	echo "le journal entre les deux répertoires existe"
	repertoireA=$(head -1 "$PATHSYNCHRO/.synchro")
	repertoireB=$(head -2 "$PATHSYNCHRO/.synchro" | tail -1)
	if [[ -d $repertoireA && -d $repertoireB ]]; then
		echo "$repertoireA $repertoireB sont valides"
	else
		echo "$repertoireA $repertoireB ne sont pas valides"
	fi





# ---------------------------- le .synchro n'existe pas, il faut le créer --------------------------------------------------




else
	echo "le journal entre les deux répertoires n'existe pas"

	while [[ ! -f "$PATHSYNCHRO/.synchro" ]]; do
		echo "Où voulez-vous positionnez le fichier .synchro ?"
		read PATHSYNCHRO
		mkdir -p $PATHSYNCHRO # on créé le chemin
		touch "$PATHSYNCHRO/.synchro"
		echo 
	done

	while [[ ! -d $repertoireA ]]
	do
		echo "répertoire A : $repertoireA n'est pas un répertoire"
		echo "Veuillez donner le premier répertoire à synchroniser/créer:"
		read repertoireA
		mkdir -p $repertoireA
		echo
	done

	while [[ ! -d $repertoireB ]]
	do
		echo "répertoire B :$repertoireB n'est pas un répertoire"
		echo "Veuillez donner le deuxième répertoire à synchroniser/créer:"
		read repertoireB
		mkdir -p $repertoireB
		echo
	done
	
	if [[ "$repertoireA" = /* ]]; then
		echo "$repertoireA" > "$PATHSYNCHRO/.synchro"
	else
		echo "$(pwd)/$repertoireA" > "$PATHSYNCHRO/.synchro" # on complète le chemin relatif
	fi

	if [[ "$repertoireB" = /* ]]; then
		echo "$repertoireB" >> "$PATHSYNCHRO/.synchro"
	else
		echo "$(pwd)/$repertoireB" >> "$PATHSYNCHRO/.synchro" # on complète le chemin relatif
	fi
	
	if [[ "$repertoireA" = /* ]]; then
		creerJournal "$repertoireA" "$PATHSYNCHRO"
	else
		creerJournal "$(pwd)/$repertoireA" "$PATHSYNCHRO"
	fi
	echo "le système de sauvegarde a bien été crée"
	

	#on demandera à l'utilisateur 2 répertoires
	#ensuite on créera un journal entre les deux avec toutes les données et tout et tout
fi




#------------------------------- fin de la récupération du .synchro ---------------------------------





# -------------------------------on syncronise les deux dossiers ---------------------------------------




Synchronisation(){
dossierA=$1
dossierB=$2


echo "Vérification des dossiers"
for fichier1 in $dossierA/*
do
	fichier2=`echo $dossierB/"$( basename -a $fichier1 )"` #on place dans la variable le chemin absolu vers le potentiel fichier2 
	#echo $fichier1 $fichier2
	#echo $(basename -a $fichier1)
	#remplacer les espaces par un underscore pour le basename

	if [[ -e $fichier2 ]] #on vérifie s'il y a bien un fichier de ce nom là dans le repertoireB
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
		fi

			if [[ $taille1 -eq $taille2 ]] && [[ $acces1 == $acces2 ]] && [[ $datem1 == $datem2 ]]
			then
				echo "les fichiers sont identiques, il ne faut pas les modifier"
			else
				echo "erreur: Fichiers différents"
				echo "lequel modifier?"
			fi
		
		if [[ -d $fichier1 && -d $fichier2 ]]
		then
			echo "rentrée dans le dossier" 		
			Synchronisation $fichier1 $fichier2
		fi
		
		if [[ -f $fichier1 ]] && [[ -d $fichier2 ]] || [[ -d $fichier1 ]] && [[ -f $fichier2 ]]
		then
		echo "Problème de fichier et de répertoire pour $fichier1"
		fi
		
	else
		echo "le fichier $fichier2 n'existe pas"
	fi

done
}

#2eme Partie
#cette Partie consiste à synchroniser les deux répertoires, le tout en modifiant le journal





#rm $HOME/Programmes/.synchro






