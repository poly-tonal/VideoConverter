#convert h264/aac/srt
#is required ffprobe and ffmpeg

#default formats (based on ffmpeg's encoder terms)
$videoFormat = "h264"
$audioFormat = "aac"
$subtitleFormat = "subrip"

$Host.UI.RawUI.WindowTitle = "File Convert"

#create error file
$logPath = ./Errors.txt
 
function convertAll {
    Get-Childitem | ForEach-Object {
        Write-Host $_
        #check filename
        if ($_.FullName -Like "*_converted.mkv") {
            #skip
            Write-Host "Meets Requirements" -ForegroundColor Green
            Write-Host "Done" (get-date).ToString('g') -ForegroundColor Green
            Write-Host
        }
        else {
            #get codecs 
            $codecs = ffprobe -v error -show_entries stream=codec_name -of default=nokey=1:noprint_wrappers=1 $_
            
            #set default for codecs to need converting
            $video = $false
            $audio = $false
            $sub = $false

            #check if codecs need converting
            for ($codec = 0; $codec -lt $codecs.length; $codec++) {
                switch ($codecs[$codec]) {
                    $videoFormat { $video = $true }
                    $audioFormat { $audio = $true }
                    $subtitleFormat { $sub = $true }
                }
            }

            if ([System.IO.Path]::GetExtension($_) -eq ".mkv") { $format = $true }else { $format = $false }
            
            #check codecs
            if ($video -and $audio -and $sub -and $format) {
                #all correct
                $newname = $_.Name -replace '.mkv', '_converted.mkv'
                Rename-Item -path $_ -Newname $newname
                Write-Host "Renamed" -ForegroundColor Green
                Write-Host "Done" (get-date).ToString('g') -ForegroundColor Green
                Write-Host
            }
            else {
                if ($video) {
                    $vcodec = "copy"
                }
                else {
                    $vcodec = $videoFormat
                }
                if ($audio) {
                    $acodec = "copy"
                }
                else {
                    $acodec = $audioFormat
                }
                if ($sub) {
                    $scodec = "copy"
                }
                else {
                    $scodec = $subtitleFormat
                }
                $out = $_.BaseName
                $out += "_converted.mkv"
 
                try {
                    ffmpeg.exe -y -i $_ -vcodec $vcodec -acodec $acodec -scodec $scodec -ac 2 $out
                    Write-Host "Done" (get-date).ToString('g') -ForegroundColor Green
                    Write-Host
                }
                catch {
                    $_ | Out-File $logPath -Append
                    return
                }
                remove-Item $_
            }
        }
    }
}
 
Write-Host "Press 1 for Films (or a single TV series), Press 2 for TV, Press 3 for a single season:" -ForegroundColor Green
$sel = Read-Host
 
Read-Host -Prompt "Press Enter to select File Location:"
 
Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
[void]$FolderBrowser.ShowDialog()
 
 
#select directory structure
switch ($sel) {
    1 {
        Get-ChildItem $FolderBrowser.SelectedPath | ForEach-Object {
            $path = $FolderBrowser.SelectedPath + "\" + $_.Name
            Set-Location $path
            convertAll
        }
    }
    2 {
        Get-ChildItem $FolderBrowser.SelectedPath | ForEach-Object {
            $path = $FolderBrowser.SelectedPath + "\" + $_.Name
            Set-Location $path
            Get-ChildItem $path | ForEach-Object {
                $childPath = $path + "\" + $_.Name
                Set-Location $childPath
                convertAll
            }
        } 
    }
    3 {
        $path = $FolderBrowser.SelectedPath
        Set-Location $path
        convertAll
    }
    Default { write-host "unknown input"; exit }
}
 
Write-Host "Completed all!" (get-date).ToString('g') -ForegroundColor Green