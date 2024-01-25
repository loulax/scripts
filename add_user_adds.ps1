Write-Output "

#############################################################
                                                            #
@author : Loulax                                            #
@version : 1.0                                              #
@date : 10-03-2022                                          #
@description : Script de creation utilisateur dans un AD    #
et partage de dossier personnel avec smb                    #
                                                            #
#############################################################

"
#TRAITEMENT D'UN FICHIER CSV
$csvfile = "C:\users\Administrateur\Documents\scripts\users.csv"

#CHECK CSV ACCESS
if (Test-Path -Path $csvfile -PathType Leaf){
    
    $csvdata = import-csv $csvfile -Delimiter ";" -Encoding UTF8 
    $path = "E:\Partages\Utilisateurs"
    $logpath = "E:\log\"
    $date = get-date -format "dd/MM/yyyy H:m:ss"

    #BOUCLE SUR LES DONNEES DU FICHIER
    foreach ($user in $csvdata){

        #CREATION DES VARIABLES
        $hostname = "DC-PRS"
        $prenom = $user.prenom
        $nom = $user.nom
        $login = $user.login
        $email = $user.email
        $fonction = $user.fonction
        $service = $user.service
        $password = $user.password
        $domain = "axeplane"
        $domainext = "loc"

        #CHECK IF USER EXIST
        if (Get-ADUser -Filter {SamAccountName -eq $login}){

            Write-Warning "L'utilisateur $login existe déjà."
            write-output "$date - L'utilisateur $login existe déjà" >> "$logpath\create_user.log"

        } else {


            #CREATE USER IF NOT EXIST
            New-ADUser -Name "$prenom $nom" -GivenName $prenom -SurName $nom -SamAccountName $login -DisplayName "$prenom $nom" -UserPrincipalname $login@$domain.$domainext -Path "OU=$service,DC=$domain,DC=$domainext" -EmailAddress $email -Title $fonction -Department $service -HomeDrive "Z:" -HomeDirectory "\\$hostname\$login$" -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -PasswordNeverExpires $true -CannotChangePassword $true -Enabled $true
            write-host "L'utilisateur $prenom $nom a été créé." -ForegroundColor Blue
            write-output "$date - L'utilisateur $login a bien été ajouté dans le domaine." >> "$logpath\create_user.log"

        }

        #CHECK IF USER FOLDER EXIST
        if (Test-Path -Path $path\$login){

                write-warning "Le dossier de l'utilisateur $login existe déjà"
                write-output "$date - Tentative de création du dossier personnel de $login alors qu'il existe déjà" >> "$logpath\users_dir.log"

        } else {

            #CREATE USER FOLDER IF NOT EXIST
            write-output "Création de son répertoire personnel"
            New-Item -ItemType Directory -Path "$path\" -Name $login
            New-SmbShare -Name $login$ -Path "$path\$login" -FullAccess $login -FolderEnumerationMode AccessBased 
            Add-NTFSAccess -Path "$path\$Login" -Account $login -AccessRights FullControl -AppliesTo ThisFolderSubfoldersAndFiles
            Disable-NTFSAccessInheritance -Path "$path\$Login" -RemoveInheritedAccessRules
            write-output "$date - Le dossier de l'utilisateur $login a bien été créé." >> "$logpath\users_dir.log"
        }
                                                                                                                                                                                                                                                                                                                                                                                                                                                      
    }

} else {

    #Logging error
    Write-Warning "Le fichier de donnée est introuvable."
    Write-Output "$date - Tentative d'un fichier inexistant." >> "$logpath\csv.log"
}