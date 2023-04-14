#!/bin/bash

# Cette fonction prend un fichier en argument et écrit un autre script contenant
# le contenu du fichier pour recréer le fichier plus tard.
function ajouter_archive() {
  local fichier="$1"
  # Vérifier que le fichier existe et est lisible.
  if [ -r "$fichier" ]
  then
    cat << EOF1 >> my-ball.sh
cat << EOF > "$fichier"
$(cat "$fichier")
EOF

EOF1
  else
    echo "Erreur : impossible de lire le fichier $fichier."
  fi
}

# Vérifier qu'un seul argument (nom de dossier) a été passé.
if [ $# -ne 1 ]; then
    echo "Erreur : un seul argument (nom de dossier) doit être passé."
    exit 1
fi

# Vérifier que le dossier existe et est un dossier.
if [ ! -d "$1" ]; then
    echo "Erreur : le paramètre doit être un dossier existant."
    exit 1
fi

# Créer le script "my-ball.sh".
cat << EOF > my-ball.sh
#!/bin/bash
EOF

# Itérer sur tous les fichiers et dossiers dans le dossier passé en paramètre.
for fichier in "$1"/*
do
  # Vérifier si le chemin est un dossier.
  if [ -d "$fichier" ]
  then
      echo "$fichier est un dossier"
  fi
  # Vérifier si le chemin est un fichier.
  if [ -f "$fichier" ]
  then       
      echo "$fichier est un fichier"
      ajouter_archive "$fichier"
  fi
done
