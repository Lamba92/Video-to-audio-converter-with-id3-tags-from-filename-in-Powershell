$workinkDir = "C:\Users\lamba\Downloads\Video"
$ffmpeg = "C:\Users\lamba\Desktop\ffmpeg-3.4.1-win64-static\bin\ffmpeg.exe"
$id3 = "C:\Users\lamba\Desktop\id3.exe"
$items = Get-ChildItem -Path "C:\Users\lamba\Downloads\Video\*" -Include *.mp4 -File
$album = "Zelda - Breath of the Wild Soundtrack"
$artists = "Manaka Kataoka/Yasuaki Iwata"
$year = "2017"
$genre = "Soundtrack"
$sem = New-Object System.Threading.Semaphore(1, 1)
$pinfoMap = @{}
$pMap = @{}
$paramsMap = @{}
foreach ($input in $items){
    $number = $input.ToString() -replace "(.*(?:\\|/))(\d+)\.(.*?) ?- Zelda.*",'$2'
    $title = $input.ToString() -replace "(.*(?:\\|/))(\d+)\.(.*?) ?- Zelda.*",'$3'
    $output = $title + ".mp3"
    $paramsMap.Add($input," -i ""$input"" -vn -codec:a libmp3lame -qscale:a 4 -metadata title=""$title""" + 
    " -metadata artist=""$artists"" -metadata album=""$album"" -metadata year=""$year"" " +
    "-metadata track=""$number"" -metadata genre=""$genre"" -y ""$workinkDir\outputs2\$output""")
    
    "N.: " + $number + " | Title: " + $title
    "input: " + $input.ToString();
    "output path: " + $workinkDir + "\outputs2\" + $output
    "ffmpeg params: " + $paramsMap.$input

    $pinfoMap.Add($input, (New-Object System.Diagnostics.ProcessStartInfo($ffmpeg, $paramsMap.$input)));
    $pinfoMap.$input.UseShellExecute = $false
    $pinfoMap.$input.CreateNoWindow = $true
    $pinfoMap.$input.RedirectStandardError = $true
    $pinfoMap.$input.RedirectStandardOutput = $true
    $pMap.Add($input, (New-Object System.Diagnostics.Process))
    Register-ObjectEvent -InputObject $pMap.$input -EventName "Exited" -Action {
        $sem.Release()
        } | Out-Null
    $pMap.$input.StartInfo = $pinfoMap.$input
    #$sem.WaitOne()
    $pMap.$input.Start()
    #$pMap.$input.WaitForExit();
    "------------------------------"
}