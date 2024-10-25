#!/bin/bash

display_menu() {
    echo "Sélectionnez le type de scan Nmap à effectuer :"
    echo "1) Scan rapide (ports les plus courants)"
    echo "2) Scan complet (tous les ports TCP/UDP)"
    echo "3) Scan personnalisé (spécifier les ports)"
    echo "4) Scan avec détection du système d'exploitation et des services"
    echo "5) Planifier un scan régulier"
    echo "6) Quitter"
}

quick_scan() {
    echo "Entrez l'adresse IP ou l'hôte cible :"
    read target
    echo "Entrez l'adresse email pour recevoir le rapport :"
    read email
    echo "Scan rapide en cours..."
    report_file="quick_scan_report.txt"
    nmap -F "$target" -oN "$report_file"
    echo "Scan rapide terminé. Rapport enregistré dans $report_file"
    # Envoi du rapport par email
    mail -s "Rapport de scan rapide Nmap" "$email" < "$report_file"
    echo "Rapport envoyé par email à $email."
}

full_scan() {
    echo "Entrez l'adresse IP ou l'hôte cible :"
    read target
    echo "Entrez l'adresse email pour recevoir le rapport :"
    read email
    echo "Scan complet en cours..."
    report_file="full_scan_report.txt"
    nmap -p 1-65535 "$target" -oN "$report_file"
    echo "Scan complet terminé. Rapport enregistré dans $report_file"
    # Envoi du rapport par email
    mail -s "Rapport de scan complet Nmap" "$email" < "$report_file"
    echo "Rapport envoyé par email à $email."
}

custom_scan() {
    echo "Entrez l'adresse IP ou l'hôte cible :"
    read target
    echo "Entrez les ports à scanner (ex: 22,80,443 ou une plage ex: 1000-2000) :"
    read ports
    echo "Entrez l'adresse email pour recevoir le rapport :"
    read email
    echo "Scan personnalisé en cours..."
    report_file="custom_scan_report.txt"
    nmap -p "$ports" "$target" -oN "$report_file"
    echo "Scan personnalisé terminé. Rapport enregistré dans $report_file"
    # Envoi du rapport par email
    mail -s "Rapport de scan personnalisé Nmap" "$email" < "$report_file"
    echo "Rapport envoyé par email à $email."
}

# OS et service 
advanced_scan() {
    echo "Entrez l'adresse IP ou l'hôte cible :"
    read target
    echo "Entrez l'adresse email pour recevoir le rapport :"
    read email
    echo "Scan avec détection de l'OS et des services en cours..."
    report_file="advanced_scan_report.txt"
    nmap -O -sV "$target" -oN "$report_file"
    echo "Scan avancé terminé. Rapport enregistré dans $report_file"
    # Envoi du rapport par email
    mail -s "Rapport de scan avancé Nmap" "$email" < "$report_file"
    echo "Rapport envoyé par email à $email."
}

schedule_scan() {
    echo "Entrez l'adresse IP ou l'hôte cible pour le scan planifié :"
    read target
    echo "Choisissez la fréquence des scans :"
    echo "1) Quotidien"
    echo "2) Hebdomadaire"
    echo "3) Mensuel"
    read frequency
    echo "Entrez l'adresse email pour recevoir les rapports :"
    read email

    case $frequency in
        1)
            cron_time="0 0 * * *"  # minuit tous les jours
            ;;
        2)
            cron_time="0 0 * * 0"  # dimanche minuit chaque semaine
            ;;
        3)
            cron_time="0 0 1 * *"  #  minuit le premier de chaque mois
            ;;
        *)
            echo "Option invalide"
            return
            ;;
    esac

    cron_command="nmap -F $target -oN scheduled_scan_report.txt && mail -s 'Rapport de scan Nmap' $email < scheduled_scan_report.txt"
    (crontab -l 2>/dev/null; echo "$cron_time $cron_command") | crontab -
    echo "Scan planifié avec succès."
}

# Main loop
while true; do
    display_menu
    read choice
    case $choice in
        1)
            quick_scan
            ;;
        2)
            full_scan
            ;;
        3)
            custom_scan
            ;;
        4)
            advanced_scan
            ;;
        5)
            schedule_scan
            ;;
        6)
            echo "Au revoir!"
            exit 0
            ;;
        *)
            echo "Option invalide. Veuillez réessayer."
            ;;
    esac
done
