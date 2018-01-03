$workinkDir = "C:\Users\lamba\Downloads\Video"
$currentDir = split-path -parent $MyInvocation.MyCommand.Definition
$ffmpeg = $currentDir + "\dependecies\ffmpeg-3.4.1-win64-static\bin\ffmpeg.exe"
$items = Get-ChildItem -Path "C:\Users\lamba\Downloads\Video\*" -Include *.mp4 -File
$album = "Zelda - Breath of the Wild Soundtrack"
$artists = "Manaka Kataoka/Yasuaki Iwata"
$year = "2017"
$genre = "Soundtrack"
$global:jobsQueue = New-Object System.Collections.Concurrent.ConcurrentQueue[String]
$logPath = $currentDir + "\log.txt"
$liveObj = @{data = $global:jobsQueue}
Get-Date | Out-File -FilePath $logPath -Encoding utf8

foreach($rawPath in $items){
    $number = $rawPath.ToString() -replace "(.*(?:\\|/))(\d+)\.(.*?) ?- Zelda.*",'$2'
    $title = $rawPath.ToString() -replace "(.*(?:\\|/))(\d+)\.(.*?) ?- Zelda.*",'$3'
    $output = $title + ".mp3"
    $ffmpegParam = " -i ""$rawPath"" -vn -codec:a libmp3lame -qscale:a 4 -metadata title=""$title""" + 
    " -metadata artist=""$artists"" -metadata album=""$album"" -metadata year=""$year"" " +
    "-metadata track=""$number"" -metadata genre=""$genre"" -y ""$workinkDir\outputs2\$output"""
    
    "N.: " + $number + " | Title: " + $title | Out-File -FilePath $logPath -Encoding utf8 -Append
    "input: " + $rawPath.ToString() | Out-File -FilePath $logPath -Encoding utf8 -Append
    "output path: " + $workinkDir + "\outputs2\" + $output | Out-File -FilePath $logPath -Encoding utf8 -Append
    "ffmpeg params: " + $ffmpegParam | Out-File -FilePath $logPath -Encoding utf8 -Append
    "_____________________"| Out-File -FilePath $logPath -Encoding utf8 -Append
    
    $global:jobsQueue.Enqueue($ffmpegParam)
}
$block = {
    Param($liveObj_, $ffmpegPath, $processLogPath)
    $global:params = "";
    $queueParam = $liveObj_.data
    "" | Out-File -filepath $processLogPath -Encoding utf8 -Append
    "_________________________" | Out-File -filepath $processLogPath -Encoding utf8 -Append
    "queueParam size: " + $queueParam | Out-File -filepath $processLogPath -Encoding utf8
    "ffmpegPath : $ffmpegPath" | Out-File -filepath $processLogPath -Encoding utf8 -Append
    while($true){
        if($queueParam.TryDequeue([ref]$global:params)){
            "l' IF è true" | Out-File -filepath $processLogPath -Encoding utf8 -Append
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo($ffmpegPath, $params) 
            $pinfo| Out-File -filepath $processLogPath -Encoding utf8 -Append
            $pinfo.UseShellExecute = $false
            $pinfo.CreateNoWindow = $true
            $p = New-Object System.Diagnostics.Process
            $p | Out-File -filepath $processLogPath -Encoding utf8 -Append
            $p.StartInfo = $pinfo
            $p.Start()| Out-File -filepath $processLogPath -Encoding utf8 -Append
            $p.WaitForExit()| Out-File -filepath $processLogPath -Encoding utf8 -Append
        } else {
            "FINE CICLO WHILE" | Out-File -filepath $processLogPath -Encoding utf8 -Append
            break
        }
    }
}
for($i = 0; $i -lt 1; $i++){
    $p = [PowerShell]::Create()
    $p.AddScript($block).AddArgument($liveObj).addArgument($ffmpeg).addArgument("$currentDir\$i.txt")
    $job = $p.BeginInvoke();
    $done = $job.AsyncWaitHandle.WaitOne()
    $p.EndInvoke($job);
    $p.Streams.error
}
