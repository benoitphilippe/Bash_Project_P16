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

# ---------------------------------- fonction de synchronisation ---------------------------------------

function Synchronisation(){
dossierA=$1
dossierB=$2
PATHSYNCHRO=$3

# verification des varibles
if [[ ! -d "$dossierA" || ! -d "$dossierB" || ! -f "$PATHSYNCHRO/.synchro" ]]; then
	echo "entrées incorrectes $dossierA $dossierB $PATHSYNCHRO/.synchro"
	exit 1
fi


for fichier1 in "$dossierA"/*
do
	fichier2=`echo $dossierB/$( basename "$fichier1" )` #on place dans la variable le chemin absolu vers le potentiel fichier2 
	
	if [[ -e "$fichier2" ]] #on vérifie s'il y a bien un fichier de ce nom là dans le repertoireB
	then
		if [[ -f "$fichier1" && -f "$fichier2" ]] #on verifie que les 2 fichiers sont du même type
		then
		
			#on vérifie les métadonnées des deux fichiers		
			taille1=$(stat -c %s "$fichier1")
			taille2=$(stat -c %s "$fichier2")

			acces1=$(stat -c %A "$fichier1")
			acces2=$(stat -c %A "$fichier2")
		
			datem1=$(stat -c %y "$fichier1")
			datem2=$(stat -c %y "$fichier2")

			base=$(basename "$fichier1")

			taille3=$(grep "$base" "$PATHSYNCHRO/.synchro" | tail -1 | cut -d'>' -f2)
			acces3=$(grep "$base" "$PATHSYNCHRO/.synchro" | tail -1 | cut -d'>' -f3)
			datem3=$(grep "$base" "$PATHSYNCHRO/.synchro" | tail -1 | cut -d'>' -f4)

			if [[ "$taille1" -eq "$taille2" ]] && [[ "$acces1" == "$acces2" ]] && [[ "$datem1" == "$datem2" ]]
			then
				if [[ "$taille1" -ne "$taille3" ]] || [[ "$acces1" != "$acces3" ]] || [[ "$datem1" != "$datem3" ]]; then
					echo mise à jour du journal pour $(basename "$fichier1")
					type=$(file "$fichier1")
					echo $(basename "$fichier1")">$taille1>$acces1>$datem1>${type#:*}" >> "$PATHSYNCHRO/.synchro"
					echo "----- > "
					echo "fait !"
				fi
			else
				if [[ "$taille1" -eq "$taille3" ]] && [[ "$acces1" == "$acces3" ]] && [[ "$datem1" == "$datem3" ]]; then
					echo "mise à jour : "
					echo "		$fichier2 ----- > $fichier1"
					cp --preserve=mode,ownership,timestamps "$fichier2" "$fichier1"
					type=$(file "$fichier1")
					echo $(basename "$fichier1")">$taille1>$acces1>$datem1>${type#:*}" >> "$PATHSYNCHRO/.synchro"
					echo "fait ! "

				elif [[ "$taille3" -eq "$taille2" ]] && [[ "$acces3" == "$acces2" ]] && [[ "$datem3" == "$datem2" ]]; then
					echo "mise à jour : "
					echo "		$fichier1 ----- > $fichier2"
					cp --preserve=mode,ownership,timestamps "$fichier1" "$fichier2"
					type=$(file "$fichier1")
					echo $(basename "$fichier1")">$taille1>$acces1>$datem1>${type#:*}" >> "$PATHSYNCHRO/.synchro"
					echo "fait ! "
				else
					echo
					echo les fichiers $(basename "$fichier1") ne sont pas conforme au journal
					contenue=$(diff -y "$fichier1" "$fichier2")
					
					if [[ -z "$contenue" ]]; then # si il n'y a aucune différence entre les deux fichier
						echo mise à jour des methadonnées de $(basename "$fichier1")
						cp --preserve=mode,ownership,timestamps "$fichier1" "$fichier2"
						type=$(file "$fichier1")
						echo $(basename "$fichier1")">$taille1>$acces1>$datem1>${type#:*}" >> "$PATHSYNCHRO/.synchro"
						echo "----- > "
						echo "fait !"

					else
						echo "voici la différence entre $fichier1 et $fichier2"
						echo "$contenue" | cat
						echo 
						end='false'
						while [[ $end = 'false' ]]; do
							echo "Que voulez vous faire ?"
							echo "1) Garder $fichier1 "
							echo "2) Garder $fichier2"
							echo "3) supprimer les deux fichiers"
							read -r -p "réponse : " response
							case $response in
				    		1) 
				        		cp --preserve=mode,ownership,timestamps "$fichier1" "$fichier2"
								type=$(file "$fichier1")
								echo "		$fichier1 -----> $fichier2"
								echo $(basename "$fichier1")">$taille1>$acces1>$datem1>${type#:*}" >> "$PATHSYNCHRO/.synchro"
								echo "fait !"
								end='true'
				        		;;
				        	2) 
				        		cp --preserve=mode,ownership,timestamps $fichier2 $fichier1
								type=$(file "$fichier1")
								echo "		$fichier2 -----> $fichier1"
								echo $(basename "$fichier1")">$taille2>$acces2>$datem2>${typSe#:*}" >> "$PATHSYNCHRO/.synchro"
								echo "fait !"
								end='true'
				        		;;
				        	3)
								rm "$fichier1" "$fichier2"
								echo "$fichier1 et $fichier2 ont été supprimé"
								end='true'
								;;
				    		*)
								echo "mauvaise saisie !"
				        		;;
							esac
						done
					fi
				fi
			fi
		elif [[ -d "$fichier1" && -d "$fichier2" ]]
		then
			echo " on rentre dans ---- > 	$(basename "$fichier1")" 		
			Synchronisation "$fichier1" "$fichier2" "$PATHSYNCHRO"
			dossierB="${dossierB%/*}"
			echo "retour dans ----- > $dossierB"
		fi
		
		if [[ -f "$fichier1" ]] && [[ -d "$fichier2" ]] || [[ -d "$fichier1" ]] && [[ -f "$fichier2" ]]
			then
			echo "Problème de fichier et de répertoire pour $fichier1"
		fi
		
	else
		if [[ -f "$fichier1" ]]; then
			end='false'
			echo
			echo  un fichier est absent dans $dossierB : $(basename "$fichier2")
			echo ""
			while [[ $end = 'false' ]]; do
				echo "Que voulez vous faire ?"
				echo "1) Copiez dans $dossierB"
				echo "2) supprimez le fichier $fichier1"
				read -r -p "réponse : " response
				case $response in
	    		1) 
	        		cp --preserve=mode,ownership,timestamps "$fichier1" "$dossierB"
	        		taille=$(stat -c %s "$fichier1")
					acces=$(stat -c %A "$fichier1")
					datem=$(stat -c %y "$fichier1")
					type=$(file "$fichier1")
					echo "		$fichier1 ---- > $fichier2"
					echo $(basename "$fichier1")">$taille>$acces>$datem>${type#:*}" >> "$PATHSYNCHRO/.synchro"
					echo "fait !"
					end='true'
	        		;;
	        	2)
					rm $fichier1
					echo "$fichier1 a été supprimé"
					end='true'
					;;
	    		*)
					echo "mauvaise saisie !"
	        		;;
				esac
			done
		elif [[ -d "$fichier1" ]]; then
			end='false'
			echo
			echo  un dossier est absent dans $dossierB : $(basename "$fichier2")
			echo ""
			while [[ $end = 'false' ]]; do
				echo "Que voulez vous faire ?"
				echo "1) creer le dossier dans $dossierB"
				echo "2) supprimez le dossier $fichier1"
				read -r -p "réponse : " response
				case $response in
	    		1) 

	        		mkdir "$fichier2"
	        		echo
	        		echo  on rentre dans ---- > 	$(basename "$fichier1") 		
					Synchronisation "$fichier1" "$fichier2" "$PATHSYNCHRO"
					# on retourne au dossier d'avant la récursion
					dossierB="${dossierB%/*}"
					echo 
					echo "retour dans ---- > $dossierB"
					end='true'
	        		;;
	        	2)
					rm "$fichier1"
					echo "$fichier1 a été supprimé"
					end='true'
					;;
	    		*)
					echo "mauvaise saisie !"
	        		;;
				esac
			done
		else
			echo "$fichier1 n'est pas un fichier"
		fi
	fi
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

	echo
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
	echo
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
	
fi


#------------------------------- fin de la récupération du .synchro ---------------------------------





# -------------------------------on syncronise les deux dossiers ---------------------------------------

echo
Synchronisation "$repertoireA" "$repertoireB" "$PATHSYNCHRO"
Synchronisation "$repertoireB" "$repertoireA" "$PATHSYNCHRO"


exit 0