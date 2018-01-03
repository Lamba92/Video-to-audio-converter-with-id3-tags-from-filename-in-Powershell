$workinkDir = "C:\Users\lamba\Downloads\Video"
$ffmpeg = "C:\Users\lamba\Desktop\ffmpeg-3.4.1-win64-static\bin\ffmpeg.exe"
$id3 = "C:\Users\lamba\Desktop\id3.exe"
$items = Get-ChildItem -Path "C:\Users\lamba\Downloads\Video\*" -Include *.mp4 -File
$album = "Zelda - Breath of the Wild Soundtrack"
$artists = "Manaka Kataoka/Yasuaki Iwata"
$year = "2017"
$genre = "Soundtrack"
foreach ($input in $items){
    $number = $input.ToString() -replace "(.*(?:\\|/))(\d+)\.(.*?) ?-.*",'$2'
    $title = $input.ToString() -replace "(.*(?:\\|/))(\d+)\.(.*?) ?-.*",'$3'
    $output = $title + ".mp3"
    $ffmpegParams = " -i """ + $input + """ -vn -codec:a libmp3lame -qscale:a 4 -metadata title=""" + 
        $title + """ -metadata artist=""" + $artists + """ -metadata album=""" + 
        $album +  """ -metadata year=""" + $year + """ -metadata track=""" +
        $number +  """ -metadata genre=""" + $genre + """ """ +
        $workinkDir + "\outputs\" + $output + """" 
    
    $id3Params = " -t " + """" + $title + """" + " -a " + $artists + " -l " + $album + 
        " - n " + $number + " -y " + $year + " -g " + $genre + " """ + $workinkDir + 
        "\outputs\" + $output + """"
    
    "N.: " + $number + " | Title: " + $title
    "input: " + $input.ToString();
    "output path: " + $workinkDir + "\outputs\" + $output
    "ffmpeg params: " + $ffmpegParams
    "id3 params: " + $id3Params
    ""
    ""
    Start-Process $ffmpeg $ffmpegParams -Wait -WindowStyle Hidden
    "ffmpeg eseguito"
    "------------------------------"
}