#   Description:
# This script removes unwanted Apps that come with Windows. If you  do not want
# to remove certain Apps comment out the corresponding lines below.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1

echo "Elevating privileges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

echo "Uninstalling default apps"
$apps = @(
    # default Windows 10 apps
    "Microsoft.3DBuilder"
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingWeather"
    "Microsoft.FreshPaint"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.Office.OneNote"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    "Microsoft.Windows.Photos"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsCalculator"
    "Microsoft.WindowsCamera"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.WindowsStore"
    "Microsoft.XboxApp"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "microsoft.windowscommunicationsapps"
    "Microsoft.MinecraftUWP"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.NetworkSpeedTest"
    
    # Threshold 2 apps
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.WindowsFeedbackHub"

    # non-Microsoft
    "9E2F88E3.Twitter"
    "Drawboard.DrawboardPDF"
    "Flipboard.Flipboard"
    "ShazamEntertainmentLtd.Shazam"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.*"
    "ClearChannelRadioDigital.iHeartRadio"
    #"TheNewYorkTimes.NYTCrossword"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "Facebook.Facebook"
    "flaregamesGmbH.RoyalRevolt2"
    "Playtika.CaesarsSlotsFreeCasino"
    "A278AB0D.MarchofEmpires"
    "KeeperSecurityInc.Keeper"
    "ThumbmunkeysLtd.PhototasticCollage"
    "XINGAG.XING"
    "89006A2E.AutodeskSketchBook"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "46928bounde.EclipseManager"
    "ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC


    # apps which cannot be removed using Remove-AppxPackage
    #"Microsoft.BioEnrollment"
    #"Microsoft.MicrosoftEdge"
    #"Microsoft.Windows.Cortana"
    #"Microsoft.WindowsFeedback"
    #"Windows.ContactSupport"
)

$dism_apps = @(
    # apps which can be removed by dism see http://bit.ly/2ax33MM
    "Microsoft.XboxGameCallableUI"
    "Microsoft.XboxIdentityProvider"
)

foreach ($app in $apps) {
    echo "Trying to remove $app"

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

    Get-AppXProvisionedPackage -Online |
        where DisplayName -EQ $app |
        Remove-AppxProvisionedPackage -Online
}

foreach ($app in $dism_apps)
{
    echo "Trying to remove $app"

    $dism_app = dism /Online /Get-ProvisionedAppxpackages  | select-string $app | select-string "PackageName"
    if ($dism_app)
    {
        Write-Verbose $dism_app
        $package = $dism_app -split " : " | Select-String -NotMatch "PackageName"
        $package = $package.ToString().Trim()
        Write-Verbose $package
        dism /Online /Remove-ProvisionedAppxPackage /PackageName:$package
    }
}

# Prevents "Suggested Applications" returning
force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content"
sp "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content" "DisableWindowsConsumerFeatures" 1
