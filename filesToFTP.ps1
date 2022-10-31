function UploadToFtp($artifacts, $ftp_uri, $user, $pass){
    $webclient = New-Object System.Net.WebClient 
    $webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)  

    foreach($item in Get-ChildItem -recurse $artifacts){ 

		
        $relpath = [system.io.path]::GetFullPath($item.FullName).SubString([system.io.path]::GetFullPath($artifacts).Length)
		
		echo $relpath

        if ($item.Attributes -eq "Directory"){
            
            try{
                Write-Host Creating $item.Name
                
                $makeDirectory = [System.Net.WebRequest]::Create($ftp_uri+$relpath);
                $makeDirectory.Credentials = New-Object System.Net.NetworkCredential($user,$pass) 
                $makeDirectory.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
                $makeDirectory.GetResponse();
            
            }catch [Net.WebException] {
                Write-Host $item.Name probably exists ...
            }

            continue;
        }
        
        "Uploading $item..."
        $uri = New-Object System.Uri($ftp_uri+$relpath) 
        $webclient.UploadFile($uri, $item.FullName)
    }
}

function main {
	$sourcePath = "./" 
	$destinationPath = "./"
	
	$ftp_uri = "ftp://"
	$ftp_user = "<user>"
	$ftp_pass = "<password>"

	$time = (Get-Date).AddMonths(-6)

	"Copy files to Upload..."
	Get-ChildItem -Path $sourcePath | Where-Object {$_.LastWriteTime -lt $time } | Copy-Item -Destination $destinationPath -Recurse -Container
	
	"Upload files..."
	UploadToFtp $destinationPath $ftp_uri $ftp_user $ftp_pass
	"[Upload finished]"
}

main
