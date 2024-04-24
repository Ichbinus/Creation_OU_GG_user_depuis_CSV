$listing =Import-Csv -Path 'C:\Users\administrator\Desktop\Listing_rh.csv' -Delimiter ","
$listing
foreach ($user in $listing){
    if ($user.Nom -notlike "" -and $user.Prénom -notlike "" -and $user.Service -notlike ""){
        Write-Host $user
        $IDuser = $user.Prénom.Substring(0,1)+$user.Nom
        $IDuser
        
        #test OU existante?
        $rangementOU = "OU="+$user.Service+",OU=Utilisateurs,OU=Societe,DC=domMT,DC=ad"
        $rangementOU
        $testOU = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$rangementOU'"
        if ($testOU -ne $null) {
            Write-Host "L'unité d'organisation '$rangementOU' existe."
            Write-Host " "

        }else {
            Write-Host "L'unité d'organisation '$rangementOU' n'existe pas."
            Write-Host " "
            New-ADOrganizationalUnit -Name $user.Service -Path "OU=Utilisateurs,OU=Societe,DC=domMT,DC=ad" 
        }

        #test Groupe existant?
        $groupeuser = "G-"+$user.Service
        $testgroupe = Get-ADGroup -Filter "Name -eq '$groupeuser'" 
        if ($testgroupe -ne $null) {
            Write-Host "le groupe '$groupeuser' existe."
            Write-Host " "
        }
        else {
            Write-Host "le groupe '$groupeuser' n'existe pas."
            Write-Host " "
            New-ADGroup -GroupCategory Security -GroupScope Global -Name $groupeuser -Path "OU=Groupes,OU=Societe,DC=domMT,DC=ad"
        }

        #test modèle existant?
        $nonmodele = "Modèle "+$user.Service
        $nonmodele
        $testmodèle = Get-ADUser -Filter "Name -eq '$nonmodele'" 
        write-host = $testmodèle
        if ($testmodèle -ne $null){
            Write-Host "Le modèle d'utilisateur '$nonmodele' existe."
            Write-Host " "
        }else{
            New-ADUser -Path $rangementOU -Enabled:$false -Name $nonmodele 
            Add-ADGroupMember -Identity $groupeuser -Members $nonmodele
        }

        $UserPrincipalName = $IDuser+"@domMT.ad"
        $UserPrincipalName
        $Name = $user.Prénom+" "+$user.Nom
        $modelUser = Get-ADUser -Filter "name -eq '$nonmodele'" -Properties *
        New-ADUser -Path $rangementOU `
                   -Enabled:$true  `
                   -UserPrincipalName $UserPrincipalName  `
                   -GivenName $user.Prénom  `
                   -Surname $user.Nom  `
                   -Name $Name  `
                   -SamAccountName $IDuser  `
                   -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd!" -Force)  `
                   -ChangePasswordAtLogon:$true 
        Add-ADGroupMember -Identity $groupeuser -Members $IDuser

     }   
}


Get-ADUser -Filter *|Select-Object -Property Name
#Get-ADOrganizationalUnit -Filter *
#Get-ADGroup -Filter "Name -like 'G-Interimaire'"