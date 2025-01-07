#!/bin/bash

# Définir le chemin du dossier des charts
CHARTS_DIR="charts"

# Vérifier si le dossier existe
if [ ! -d "$CHARTS_DIR" ]; then
  echo "Le dossier $CHARTS_DIR n'existe pas."
  exit 1
fi

# Naviguer dans chaque sous-dossier de charts
for chart in "$CHARTS_DIR"/*; do
  if [ -d "$chart" ]; then
    echo "\nTraitement du chart : $chart"

    # Générer le README avec helm-docs
    echo "  Génération du README..."
    helm-docs --chart-search-root=$CHARTS_DIR --document-dependency-values --skip-version-footer

    # Générer le fichier schema JSON
    if [ -f "$chart/values.yaml" ]; then
      echo "  Génération du schema JSON..."
      helm schema -input "$chart/values.yaml" -output "$chart/values.schema.json"
    else
      echo "  values.yaml non trouvé, saut de la génération du schema JSON."
    fi

    # Mettre à jour les dépendances
    if [ -f "$chart/Chart.yaml" ]; then
      echo "  Mise à jour des dépendances..."
      helm dependencies update "$chart"
    else
      echo "  Chart.yaml non trouvé, saut de la mise à jour des dépendances."
    fi
  else
    echo "$chart n'est pas un dossier, saut."
  fi
done

echo "\nTraitement terminé. Tous les charts ont été mis à jour."

earthly +template --TEMPLATE_FILE=contributing.tpl --OUTPUT_FILE=CONTRIBUTING.md
earthly +template --TEMPLATE_FILE=readme.tpl --OUTPUT_FILE=README.md