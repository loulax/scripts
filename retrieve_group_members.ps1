Write-Output "

#############################################################
                                                            #
@author : Louis Arnau Bouttier                              #
@version : 1.0                                              #
@date : 10-03-2022                                          #
@description : Script de listing des groupes d'un membre    #
                                                            #
#############################################################

"

#Init variables
$logpath = "E:\log\lst_grp_mbr.log"
$date = get-date -format "dd/MM/yyyy H:m:ss"
$user = read-host "Renseigner le nom de l'utilisateur "
$exportfile = "C:\Users\Administrateur\Documents\Scripts\script_rendu\export.txt"
$message = '--------------- Le(s) groupe(s) de l utilisateur $user ----------------------'
#Check if user exist
if (Get-ADUser -Filter{SamAccountName -eq $user}){

    #Export groups of specific member
    $result = get-adprincipalgroupmembership -identity $user | Select-Object name
    Write-Output "--------------- Le(s) groupe(s) de l'utilisateur $user ----------------------"
    Write-Output $result
    $result | Out-File -FilePath $exportfile
    Add-Content -Value $message -Path $exportfile

} else {

    #Logging error
    Write-Warning "L'utilisateur n'existe pas."
    write-output "$date - L'utilisateur $user n'existe pas" >> "$logpath\grp_users.log"

}