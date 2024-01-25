Write-Output "

#############################################################
                                                            #
@author : Loulax                                            #
@version : 1.0                                              #
@date : 10-03-2022                                          #
@description : Script de listing des membres d'un groupe    #
                                                            #
#############################################################

"
#Initialisation des variables
$logpath = "E:\log\"
$date = get-date -format "dd/MM/yyyy H:m:ss"
$groupname = read-host "Renseigner le nom du groupe "
$exportfile = "C:\Users\Administrateur\Documents\scripts\script_rendu\Bouttier_Louis_Export_Script_02_042022.txt"

#Check if group exist
if (Get-ADGroup -Filter{SamAccountName -eq $groupname}){

    #Getting informations of a specific group
    $result = Get-ADGroupMember -Identity $groupname | Select-Object Name, SamAccountName, distinguishedName

    #Write out the result
    Write-Host "--------------- Les membres du groupe $groupname ----------------------"
    Write-Output $result
    $result | Out-File -FilePath $exportfile

} else {

    #Logging error
    Write-Warning "$date - Le groupe n'existe pas."
    write-output "$date - Le groupe $groupname n'existe pas" >> "$logpath\groupmember.log"

}