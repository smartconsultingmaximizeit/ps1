# Create a self-signed certificate
$cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "Cert:\LocalMachine\My"
$thumbprint = $cert.Thumbprint

# Create WinRM HTTPS listener
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"localhost`";CertificateThumbprint=`"$thumbprint`"}"

# Configure WinRM service
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false
Enable-PSRemoting -Force

# Open firewall for port 5986
New-NetFirewallRule -Name "WinRM_HTTPS" -DisplayName "WinRM over HTTPS" -Protocol TCP -LocalPort 5986 -Action Allow

# Ensure WinRM service is set to start automatically
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM
