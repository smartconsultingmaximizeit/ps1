param (
    [Parameter(Mandatory=$true)]
    [string]$cn
)

# --- Configuration ---
$port = 5986

# --- Generate a self-signed certificate with CN = $cn ---
$cert = New-SelfSignedCertificate `
    -DnsName $cn `
    -CertStoreLocation 'Cert:\LocalMachine\My' `
    -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.1')  # Server Authentication

$thumbprint = $cert.Thumbprint

# --- Enable and configure WinRM ---
Enable-PSRemoting -Force
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM

# --- Remove existing HTTPS listener if present ---
$existing = @(Get-ChildItem WSMan:\localhost\Listener | Where-Object { $_.Keys -match 'Transport=HTTPS' })
if ($existing.Count -gt 0) {
    winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
}

# --- Create new HTTPS listener ---
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{CertificateThumbprint='$thumbprint';Port='$port'}"

# --- Open firewall port for WinRM HTTPS ---
New-NetFirewallRule -Name 'WinRM-HTTPS' -DisplayName 'WinRM over HTTPS' `
    -Protocol TCP -LocalPort $port -Direction Inbound -Action Allow

Write-Host "✅ WinRM HTTPS listener created on port $port with CN=$cn"
