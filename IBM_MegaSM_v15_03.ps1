<#
.SYNOPSIS
 Powershell script to Download the MegaRAID Storage Manager from IBM
  https://www.ibm.com/support/pages/megaraid-storage-manager-v15030100-microsoft-windows-ibm-systems and install the software

.DESCRIPTION
 A script that downloads and installs the MegaRAID Storage Manager v15.03 from IBM support.

.NOTES
Title:     IBM_MegaSM_v15_03.ps1
Author:    James Arthur
Creation:  Jun 20, 2023
Modified:  Jun 27, 2023

.LINK
 https://www.ibm.com/support/pages/megaraid-storage-manager-v15030100-microsoft-windows-ibm-systems

.EXAMPLE
IBM_MegaSM_v15_03.ps1
#>

#vars
$downloadHost = "https://download2.boulder.ibm.com/sar/CMA/XSA/"
$downloadroot = "C:\installs"
$megaRAIDfilepath = 'C:\installs\ibm_utl_msm_15.03.01.00_windows_32-64.exe'
$megaRAIDFile = Test-Path $megaRAIDfilepath
$expectMD5 = "3D82677A4F5841FEE56B1E1D82D2FC0A"
$logpath = "C:\installs\MegaRAID_download.log"
$msmsetup = 'C:\installs\msm\setup.exe'
$veryfymsminstalledpath = 'C:\Program Files (x86)\MegaRAID Storage Manager\startupui.bat'

# Logging function. 
function Write-Log {
    param($msg)
    "$date : $msg" | Out-file -FilePath $logpath -Append -Force
    Write-Output "$date : $msg"
}
Write-Log "***** Starting Log. *****"

#verify file function
function Verify_File {
    $megaRAIDtestpath = Test-Path -Path $megaRAIDfilepath
    $MD5SUM = Get-FileHash $megaRAIDfilepath -Algorithm MD5
    If ($megaRAIDtestpath -eq $True) {
        Write-Log "The MegaRAID Storage Manager v15.03 exe downloaded: " $megaRAIDtestpath
        # verify MD5SUM
        If ($MD5SUM.Hash -eq $expectMD5) {
            Write-Log "MD5SUM matches (MD5: $expectMD5): $MD5SUM"
            Write-Log "***** starting install *****"
            msm_install
        }
        Else {
            Write-Log "Something is wrong; MD5SUM does not match. Restart this script IBM_MegaSM_v15_03.ps1"
            $error[0]
            Remove-item 'C:\installs\ibm_utl_msm_15.03.01.00_windows_32-64.exe'
            Write-Log "***** End Log. *****"
            Exit 1
        }
    }
    Else {
        Write-Log "The MegaRAID Storage Manager v15.03 exe did not download correctly. Please check MegaRAID_download.log for more information."
        $error[0]
        Write-Log "***** End Log. *****"
        Exit 1
    }
} 

# install function
function msm_install {
    $msmtestpath = Test-Path -Path $msmsetup -IsValid
    $msmcommand = 'C:\installs\ibm_utl_msm_15.03.01.00_windows_32-64.exe -x C:\installs\msm'
    $setupinstallMSM = 'C:\installs\msm\setup.exe /S /v/qn'
    Write-Log "Exstating MegaRAID Storage Manager v15.03"
    Start-Process -FilePath cmd.exe -ArgumentList "/c `"$msmcommand`"" -Wait
    If ($msmtestpath -eq $True) {
        Write-Log "Start Install MegaRAID Storage Manager v15.03: " $msmtestpath
        Start-Process -FilePath cmd.exe -ArgumentList "/c `"$setupinstallMSM`"" -Wait
        verify_MSM
    }
    Else {
        Write-Log "MSM setup not found."
        Write-Log "***** End Log *****"
        $error[0]
        exit 1
    }
}
function verify_MSM {
    $removepath = "C:\installs\*"
    $verifymsmtestpath = Test-Path -Path $veryfymsminstalledpath
    If ($verifymsmtestpath -eq $True) {
        Write-Log "MegaRAID Storage Manager v15.03 install completed."
        Write-Log "***** End Log *****"
        Remove-Item -Path $removepath -Recurse -Force
        exit 
    }
    Else {
        Write-Log "MSM did not install. Please try again."
        Write-Log "***** End Log *****"
        $error[0]
        exit 1
    }
}

#verify and download MegaRAID Storage Manager v15.03 exe file
If ($megaRAIDFile -eq $True) {
    Write-Log "MegaRAID Storage Manager v15.03 already downloaded: $megaRAIDFile"
    Verify_File
}
Else {
    Write-Log "downloading MegaRAID Storage Manager v15.03."
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest "$downloadHost/ibm_utl_msm_15.03.01.00_windows_32-64.exe" -OutFile "$downloadroot\ibm_utl_msm_15.03.01.00_windows_32-64.exe"
    Verify_File
}
