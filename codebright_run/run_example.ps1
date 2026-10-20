param(
    [Parameter(Mandatory=$true)][string]$Solver,
    [Parameter(Mandatory=$true)][string]$ExampleArchive,
    [Parameter(Mandatory=$true)][string]$RunDirectory
)
# Run the unchanged UPC equilibrium example in a fresh directory on Windows.
# Inputs are a separately installed official executable and downloaded example ZIP.
# No third-party binaries, tutorial projects, or reference outputs are redistributed.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$Solver = (Resolve-Path -LiteralPath $Solver).Path
$ExampleArchive = (Resolve-Path -LiteralPath $ExampleArchive).Path
$expectedSolver = 'a04ba941accf6bbbc00b93c8b70365e164b51d564d3a2a37cb90c8c0e90d74e0'
$expectedArchive = 'ef07758fc6e4a554d2332478414b65ef430578329801164cb51371555f8f2007'
if ((Get-FileHash -LiteralPath $Solver -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expectedSolver) {
    throw 'Expected the recorded official CODE_BRIGHT_2026_10 executable; hash differs.'
}
if ((Get-FileHash -LiteralPath $ExampleArchive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expectedArchive) {
    throw 'Official example archive differs from the recorded version.'
}
if (Test-Path -LiteralPath $RunDirectory) { throw 'Use a new run directory to exclude stale results.' }
$RunDirectory = (New-Item -ItemType Directory -Path $RunDirectory).FullName
$case = 'Ex_CHE_MECH_eq_CB26_02'
$prefix = $case+'.gid/'
$zip = [System.IO.Compression.ZipFile]::OpenRead($ExampleArchive)
try {
    # Extract input only. In particular, never extract archived .out/.res results.
    foreach ($name in @('root.dat','key.dat',($case+'_gen.dat'),($case+'_gri.dat'),
            ($case+'_chem.dat'),($case+'_chem_ini.dat'))) {
        $entry = $zip.GetEntry($prefix+$name)
        if ($null -eq $entry) { throw ('Missing input '+$name) }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry,(Join-Path $RunDirectory $name))
    }
    $reference = $zip.GetEntry($prefix+$case+'.post.res')
    if ($null -eq $reference) { throw 'Missing distributed reference result.' }
    $stream = $reference.Open()
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { $referenceHash = ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-','').ToLowerInvariant() }
    finally { $stream.Dispose(); $sha.Dispose() }
} finally { $zip.Dispose() }
$inputs = [ordered]@{}
Get-ChildItem -LiteralPath $RunDirectory -File | Sort-Object Name | ForEach-Object {
    $inputs[$_.Name] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
}
$oldThreads = $env:OMP_NUM_THREADS
$env:OMP_NUM_THREADS = '1'
$started = [DateTime]::UtcNow
try {
    $process = Start-Process -FilePath $Solver -WorkingDirectory $RunDirectory -NoNewWindow -PassThru `
        -RedirectStandardOutput (Join-Path $RunDirectory 'stdout.txt') `
        -RedirectStandardError (Join-Path $RunDirectory 'stderr.txt')
    $handle = $process.Handle # Retain a handle even when the small example exits immediately.
    if (-not $process.WaitForExit(120000)) {
        Stop-Process -Id $process.Id
        throw 'CODE_BRIGHT exceeded the 120-second limit.'
    }
    $exitCode = $process.ExitCode
} finally { $env:OMP_NUM_THREADS = $oldThreads }
if ($exitCode -ne 0) { throw ('CODE_BRIGHT failed with exit code '+$exitCode) }
if ((Get-Item -LiteralPath (Join-Path $RunDirectory 'stderr.txt')).Length -ne 0) {
    throw 'Inspect nonempty solver stderr before accepting the run.'
}
$result = Join-Path $RunDirectory ($case+'.post.res')
$log = Join-Path $RunDirectory ($case+'_gen.out')
if (-not (Test-Path -LiteralPath $result)) { throw 'No new solver result was generated.' }
$actualHash = (Get-FileHash -LiteralPath $result -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne $referenceHash) { throw 'New result differs from the distributed reference.' }
$text = Get-Content -LiteralPath $log -Raw
$steps = [regex]::Match($text,'Total number of time steps \(int\)\s*:\s*(\d+)')
$times = [regex]::Matches($text,'\*\*Time step#\s+\d+\s+Time:\s+([0-9.E+\-]+)')
if (-not $steps.Success -or $times.Count -eq 0) { throw 'Solver completion information missing.' }
$finalTime = [double]::Parse($times[$times.Count-1].Groups[1].Value,[Globalization.CultureInfo]::InvariantCulture)
if ([int]$steps.Groups[1].Value -ne 2074 -or $finalTime -ne 720000000) {
    throw 'Solver did not reach the recorded final time and step count.'
}
$metadata = [ordered]@{
    case_name = $case
    run_started_utc = $started.ToString('o')
    run_finished_utc = [DateTime]::UtcNow.ToString('o')
    execution = 'Native Windows command-line CODE_BRIGHT; no GiD session'
    package = 'CODE_BRIGHT_2026_10.gid from UPC official 2026 download'
    example_source = 'https://deca.upc.edu/en/projects/code_bright/downloads/other-examples/2026-geochemistry/chemech/examples_chemech_cb26_02.zip'
    solver_sha256 = $expectedSolver
    example_archive_sha256 = $expectedArchive
    openmp_runtime_sha256 = (Get-FileHash -LiteralPath (Join-Path (Split-Path $Solver) 'libiomp5md.dll') -Algorithm SHA256).Hash.ToLowerInvariant()
    input_sha256 = $inputs
    exit_code = $exitCode
    stderr_bytes = 0
    time_steps = [int]$steps.Groups[1].Value
    final_time_s = $finalTime
    threads = 1
    result_sha256 = $actualHash
    distributed_reference_sha256 = $referenceHash
    matches_distributed_reference = $true
}
$utf8 = [System.Text.UTF8Encoding]::new($false)
$jsonText = (($metadata | ConvertTo-Json -Depth 4).Replace("`r`n","`n").TrimEnd()+"`n")
$completionText = ((((Get-Content -LiteralPath $log -Tail 8) | ForEach-Object { $_.TrimEnd() }) -join "`n").Trim()+"`n")
[IO.File]::WriteAllText((Join-Path $RunDirectory 'run_metadata.json'),
    $jsonText,$utf8)
[IO.File]::WriteAllText((Join-Path $RunDirectory 'completion.txt'),
    $completionText,$utf8)
Write-Output ('Completed '+$case+': '+$metadata.time_steps+' steps, reference SHA-256 matched.')
