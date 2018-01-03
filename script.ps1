$jobsQueue = New-Object System.Collections.Concurrent.ConcurrentQueue[String]
$workinkDir = "C:\Users\lamba\Downloads\Video"
$ffmpeg = "C:\Users\lamba\Desktop\ffmpeg-3.4.1-win64-static\bin\ffmpeg.exe"
$items = Get-ChildItem -Path "C:\Users\lamba\Downloads\Video\*" -Include *.mp4 -File
$album = "Zelda - Breath of the Wild Soundtrack"
$artists = "Manaka Kataoka/Yasuaki Iwata"
$year = "2017"
$genre = "Soundtrack"

foreach($rawPath in $items){
    $number = $rawPath.ToString() -replace "(.*(?:\\|/))(\d+)\.(.*?) ?- Zelda.*",'$2'
    $title = $rawPath.ToString() -replace "(.*(?:\\|/))(\d+)\.(.*?) ?- Zelda.*",'$3'
    $output = $title + ".mp3"
    $ffmpegParam = " -i ""$rawPath"" -vn -codec:a libmp3lame -qscale:a 4 -metadata title=""$title""" + 
    " -metadata artist=""$artists"" -metadata album=""$album"" -metadata year=""$year"" " +
    "-metadata track=""$number"" -metadata genre=""$genre"" -y ""$workinkDir\outputs2\$output"""
    
    "N.: " + $number + " | Title: " + $title
    "input: " + $rawPath.ToString();
    "output path: " + $workinkDir + "\outputs2\" + $output
    "ffmpeg params: " + $ffmpegParam
    
    $global:jobsQueue.Enqueue($ffmpegParam)
} 
while($true){
    if($queue.TryDequeue($params)){
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo($ffmpeg, $params)
        #$pinfoMap.$rawPath.UseShellExecute = $false
        #$pinfoMap.$rawPath.CreateNoWindow = $true
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start()
        $p.WaitForExit()
    } else {break}
}
    
$block = {
    param($queue, $ffmpeg)
    while($true){
        if($queue.TryDequeue($params)){
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo($ffmpeg, $params)
            $pinfoMap.$rawPath.UseShellExecute = $false
            $pinfoMap.$rawPath.CreateNoWindow = $true
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start()
            $p.WaitForExit()
        } else {break}
    }
}
for($i = 0; $i -lt 1; $i++){
    Start-Job -Name "process $i" $block -ArgumentList $global:jobsQueue,$ffmpeg
}