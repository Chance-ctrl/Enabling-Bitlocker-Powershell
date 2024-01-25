#FileName: EnableBitlocker.ps1
#Version: 1.0
#Author: Chance Manning
#Date: May 17th, 2023
#Description: Check if Bitlock is enabled, if not enable it. Also create logs in eventviewer
#
###################################################################################################



$source = "BitLocker"
$eventLogName = "Application"

# Check if the Bitlocker source is already registered as a known source
if (-not (Get-EventLog -LogName $eventLogName -Source $source -ErrorAction SilentlyContinue)) {
    # Register bitlocker source to allow events to be created if fails
    New-EventLog -LogName $eventLogName -Source $source
}


try{
    $systemDrive = "C:"
    $encryptionStatus = Get-BitLockerVolume -MountPoint $systemDrive | Select-Object -ExpandProperty EncryptionPercentage 
    }catch{
     Write-EventLog -LogName "Application" -Source "BitLocker" -EventId 1000 -EntryType Error -Message $_
     exit
    }



 if ($encryptionStatus -eq $null -Or $encryptionStatus -eq 0) {
        #Write-Output "BitLocker is not enabled on the system drive ($systemDrive)."
        # Enable BitLocker using Aes256 encryption.
        $encryptionMethod = "Aes256"
        $recoveryPasswordProtector = $true


        #double check to see if the encryption process has started, if so log and wait for user to reboot.
        #Encryption process could show 0, however if keyprotectors show TPM, RecoveryPassword then it has started so don't attempt to re-enable bitlocker, otherwise more than 1 key will be created.
        #If more than 1 key is created, the most recent key genereated would be used.    
         
         $bitlockerVolumes = Get-BitLockerVolume
            foreach ($volume in $bitlockerVolumes) {
                $keyProtectors = $volume.KeyProtector | Select-Object -ExpandProperty KeyProtectorType

                if (($volume.VolumeStatus -eq 'FullyEncrypted' -and $volume.EncryptionPercentage -lt 100) -or ($keyProtectors -contains 'TPM' -or $keyProtectors -contains 'RecoveryPassword')) {
                    Write-EventLog -LogName "Application" -Source "BitLocker" -EventId 1004 -EntryType Information -Message "BitLocker is enabled but waiting for reboot on volume: $($volume.DeviceID)"
                    #Write-host "BitLocker has started $($volume.DeviceID)"
                    exit
                }
            }




        # Enable BitLocker, added -errorAction Stop to stop execution and to log the rror.
          try {
            Enable-BitLocker -MountPoint "C:" -EncryptionMethod $encryptionMethod -RecoveryPasswordProtector:$recoveryPasswordProtector -ErrorAction Stop
            Write-EventLog -LogName "Application" -Source "BitLocker" -EventId 1001 -EntryType Information -Message "Bitlocker has started the encryption process"
            }
            catch {
                #Whoami | Out-File C:\Data\ScriptUser.txt
                $errorMessage = $_.Exception.Message
                Write-EventLog -LogName "Application" -Source "BitLocker" -EventId 1002 -EntryType Error -Message "An error occurred: $errorMessage"
            }

        


    } else {
        Write-EventLog -LogName "Application" -Source "BitLocker" -EventId 1004 -EntryType Information -Message "Bitlocker Already shows enabled."
    }

