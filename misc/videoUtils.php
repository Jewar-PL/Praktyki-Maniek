<?php
function GetFirstUSBDriveLetter() {
    $command = 'powershell -NoProfile -Command "Get-Volume | Where {$_.DriveType -eq \'Removable\'} | Select -ExpandProperty DriveLetter"';

    $output = shell_exec($command);

    if (!$output) return null;

    $letters = array_filter(array_map("trim", explode("\n", $output)));

    if (empty($letters)) return null;

    return $letters[0];
}

function GetVideosFromFolder($folder, $extensions = ["mp4"]) {
    if (!is_dir($folder)) return [];

    $videos = [];

    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($folder, FilesystemIterator::SKIP_DOTS));

    foreach ($it as $file) {
        if (!$file->isFile()) continue;

        $ext = strtolower($file->getExtension());
        if (in_array($ext, $extensions)) {
            $videos[] = $file->getPathname();
        }
    }

    return $videos;
}

function Test() {
    echo "dir: " . __DIR__ . "<br>";
}

function CopyVideosFromUSBDrive($driveLetter, $extensions = ["mp4"]) {
    if ($driveLetter === null) return;

    $prioritySrc = $driveLetter . ':\\priority\\';
    $regularSrc = $driveLetter . ':\\regular\\';

    $priorityDest = __DIR__ . "\\..\\videos\\priority\\";
    $regularDest = __DIR__ . "\\..\\videos\\regular\\";

    if (!is_dir($priorityDest)) return;
    if (!is_dir($regularDest)) return;

    $priorityVideosUSB = GetVideosFromFolder($prioritySrc, $extensions);
    $regularVideosUSB = GetVideosFromFolder($regularSrc, $extensions);

    foreach ($priorityVideosUSB as $src) {
        $file = basename($src);
        $dst = $priorityDest . $file;
        copy($src, $dst);
    }

    foreach ($regularVideosUSB as $src) {
        $file = basename($src);
        $dst = $regularDest . $file;
        copy($src, $dst);
    }
}

function GetAllVideos($extensions = ["mp4"]) {
    $priorityDir = __DIR__ . "\\..\\videos\\priority\\";
    $regularDir = __DIR__ . "\\..\\videos\\regular\\";

    $priorityVideos = GetVideosFromFolder($priorityDir, $extensions);
    $regularVideos = GetVideosFromFolder($regularDir, $extensions);

    return array($priorityVideos, $regularVideos);
}

function GetPlaylist($priorityVideos, $regularVideos) {
    $playlist = [];
    $pCount = count($priorityVideos);
    $rCount = count($regularVideos);

    if ($rCount === 0) return $priorityVideos;
    
    if ($pCount === 0) return $regularVideos;

    if ($rCount === 0 && $pCount === 0) return [];

    $pIndex = 0;
    $rIndex = 0;

    $totalCycles = ceil($rCount / 2) * $pCount;

    for ($cycle = 0; $cycle < $totalCycles; $cycle++) {
        $playlist[] = $priorityVideos[$pIndex];

        for ($i = 0; $i < 2; $i++) {
            $playlist[] = $regularVideos[$rIndex];
            $rIndex++;

            if ($rIndex >= $rCount) $rIndex = 0;
        }

        $pIndex++;
        if ($pIndex >= $pCount) $pIndex = 0;

        if (count($playlist) >= $pCount + $rCount * ceil($pCount/1)) break;
    }
    
    return $playlist;
}