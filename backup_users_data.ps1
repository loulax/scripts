write-host "

#############################################################
                                                            #
@author : Loulax                                            #
@version : 1.0                                              #
@date : 10-03-2022                                          #
@description : Script de de backup des données utilisateurs #
                                                            #
#############################################################

"
#TRAITEMENT D'UN FICHIER CSV
$csvfile = "C:\users\Administrateur\Documents\scripts\users.csv"
$OutputEncoding = [ System.Text.Encoding]::UTF8   
$date = get-date -format "dd/MM/yyyy à H:m:ss"
$logpath = "E:\log\"

#Vérification du chemin d'accès du fichier csv
if (Test-Path -Path $csvfile -PathType Leaf){
    
    $csvdata = import-csv $csvfile -Delimiter ";"
    $hostname = (Get-ADComputer -Filter *).name
    
    #Boucle sur les ordinateur du domaine
    foreach ($hst in $hostname){
        #Boucle sur les utilisateurs du fichier csv
        foreach ($user in $csvdata) {
            
            #Initialisation des variables nécessaires pour la sauvegarde
            $login = $user.login
            $source = "\\$hst\C$\Users\$login"
            $destination = "E:\Sauvegarde\$hst\$login"
            $ExcludedContent = @(
                'AppData'
                'OneDrive'
                'Application Data'
                'Cookies'
                'Local Settings'
                'MicrosoftEdgeBackups'
                'ntuser'
                'SendTo'
                'Favorites'
                'Contacts'
                'Searches'
                'Search Menu'
                'Start menu'
                'Recent'
                'Saved Games'
                'Start Menu'
                '3D Objects'
                'Links'
                'NTUSER*'
                'ntuser*'
                'Models'
                'OneDrive\My Documents'
                )
            
            #Test du dossier source pour la sauvegarde
            if (Test-Path -Path $source){
                
                #Initialisation de la sauvegarde
                robocopy $source $destination /e /s /xd $ExcludedContent /log:"C:\backup.log"
                write-host "La sauvegarde a bien était réalisée pour =>" -ForegroundColor Blue -NoNewline
                write-host " $source le $date" -ForegroundColor Green
                Write-Output "$date - La sauvegarde s'est terminé avec succès" >> "$logpath\backup.log"
                
            } else {
                
                #Retour d'erreur si le dossier réseau est incorrecte
                write-host "$date - Le chemin réseau n'a pas était trouvé, source : $source" -ForegroundColor Yellow 
                write-output "$date - Le chemin réseau n'a pas était trouvé, source : $source" >> "$logpath\backup.log"

            }
    
        }
    }


} else {

    #Logging error
    write-host "$date - Le fichier d'import est introuvable." -ForegroundColor Yellow
    write-output "$date - Le fichier d'import est introuvable.">> "$logpath\error_csv.log"
}