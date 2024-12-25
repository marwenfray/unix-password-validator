#!/bin/bash

# Chemin vers le fichier d'aide
HELP_FILE="password_help.txt"
VERSION="1.37"
AUTHORS="Auteurs : Yasmin Adouani, Marwen Fray"

# Fonction choix utilisation
show_usage() {
    echo "password.sh: [-h] [-v] [-m] [-g] [-t] mot.."
}

# Fonction aide
HELP() {
    if [[ -f "$HELP_FILE" ]]; then
        cat "$HELP_FILE"
    else
        echo "Fichier d'aide introuvable : $HELP_FILE"
        exit 1
    fi
}

# Fonction pour afficher le nom des auteurs et la version
show_version() {
    echo "$AUTHORS"
    echo "Version : $VERSION"
}

# Fonction menu textuel
show_menu() {
    echo "Menu :"
    echo "1. Vérifier un mot de passe (-t)"
    echo "2. Afficher l'aide (-h)"
    echo "3. Afficher la version et les auteurs (-v)"
    echo "4. Quitter"
    read -p "Entrez votre choix : " choice
    case $choice in
        1)  read -s -p "Entrez un mot de passe : " password
            echo 
            validate_password "$password";;
        2)  HELP;;
        3)  show_version;;
        4)  echo "Au revoir !"
            exit 0;;
        *)  echo "Choix invalide.";;
    esac
}

# Fonction de validation du mot de passe
validate_password() {
    local password=$1
    local dictionary="./dictionnaire.txt"
    
    if [[ ${#password} -lt 8 ]]; then
        echo "Le mot de passe doit contenir au moins 8 caractères." 
        return 1
    fi

    if ! [[ $password =~ [0-9] ]]; then
        echo "Le mot de passe doit contenir au moins un chiffre." 
        return 1
    fi

    if ! [[ $password =~ [@#\$%*+=-] ]]; then
        echo "Le mot de passe doit contenir au moins un caractère spécial parmi : @, #, $, %, &, *, +, -, =." 
        return 1
    fi

    if [[ -f "$dictionary" ]]; then
        for ((i = 0; i <= ${#password} - 4; i++)); do
            substring=${password:i:4}
            if grep -qi "^${substring}$" "$dictionary"; then
                echo "Le mot de passe contient une séquence devinable : $substring"
                return 1
            fi
        done
    else
        echo "Attention : fichier dictionnaire introuvable, vérification ignorée."
    fi

    echo "Le mot de passe est valide."
    return 0
}

# Vérification des options
if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

#Fonction affichage YAD
show_graphical_menu() {
    choix=$(yad --title="Menu Graphique" \
                --width=300 --height=200 \
                --center \
                --list \
                --column="Numéro" \
                --column="Option" \
                1 "Vérifier un mot de passe" \
                2 "Afficher l'aide" \
                3 "Afficher la version et les auteurs" \
                4 "Quitter" \
                 --separator="" --print-column=1)



    case $choix in
        1)	password=$(yad --title="Vérification de mot de passe" \
                           --center \
                           --entry --text="Entrez un mot de passe :")
            			[ -n "$password" ] && validate_password "$password" || \
               			 yad --error --title="Erreur" --text="Mot de passe non saisi.";;
        2)	HELP;;
        3)	show_version;;
        4)	yad --info --title="Au revoir" --text="Merci d'avoir utilisé le script !"
        	exit 0;;
 	*)	yad --error --title="Erreur" --text="Aucune option valide sélectionnée.";;

    esac
}

#Options
while getopts ":htvgm" opt; do
    case $opt in
        h)  HELP
            exit 0;;
        t)  read -s -p "Entrez un mot de passe : " password
            echo  # Move to a new line after password input
            validate_password "$password"
            exit $?;;
        v)  show_version
            exit 0;;
        m)  show_menu
            exit 0;;
        g)  show_graphical_menu
            exit 0;;
        \?) echo "Option invalide : -$OPTARG"
            show_usage
            exit 1;;
    esac
done


