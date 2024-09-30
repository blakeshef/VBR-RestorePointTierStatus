## TODO: add loop over multiple backup sets for selecting a repository
$backupSet = Get-VBRBackup -Name '<Name of Your Backup Set Here>'

$rps = Get-VBRRestorePoint -Backup $backupSet
$cts = Get-VBRCapacityExtent -Repository $rps[0].GetRepository()

$ctListProperty = @{}

if ($cts.length -gt 0) {
    foreach ($ct in $cts){
        $ctListProperty.Add($ct.Repository.Name, $false)
    }
}

$points = New-Object System.Collections.ArrayList

foreach ($rp in $rps){
    ## get storage info about point
    $storage = $rp.GetStorage()

    ## create custom point object for info storage, we don't need the full point or storage info
    ## I'm using Add-Memeber because without knowing the property names ahead of time, select object is really hard to use without ugly looking code
    ## This way it outputs in the expected order
    $point = [PSCustomObject]@{}
    $point | Add-Member -NotePropertyName "VM Name" -NotePropertyValue $rp.VmName
    $point | Add-Member -NotePropertyName "Creation Time" -NotePropertyValue $storage.CreationTime
    $point | Add-Member -NotePropertyName "Point Type" -NotePropertyValue $rp.Type
    $point | Add-Member -NotePropertyName "Is Availaible" -NotePropertyValue $storage.IsAvailable
    $point | Add-Member -NotePropertyName "Is Local" -NotePropertyValue $storage.IsContentInternal
    $point | Add-Member -NotePropertyMembers $ctListProperty
    $point | Add-Member -NotePropertyName "Archive Tier" -NotePropertyValue $storage.IsContentFrozen
    $point | Add-Member -NotePropertyName "Is Copied" -NotePropertyValue $false

    if ($storage.IsContentExternal -eq $false) {
        foreach($ct in $cts) {
            try {
                $shadowStorage = [Veeam.Backup.Core.CStorage]::GetShadowStorageByOriginalStorageId($storage.Id, $ct.Id)
                $point.($ct.Repository.Name) = $shadowStorage.IsContentExternal
                $point."Is Copied" = $point."Is Local" -and $point.($ct.Repository.Name)
            } catch [System.Management.Automation.MethodInvocationException] {
                continue
            }
        }
    }
    
    ## supresses int return of the add function, not to flood the console with numbers while processing
    $null = $points.Add($point)
}

$points | ft