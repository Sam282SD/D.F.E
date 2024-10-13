function DelGDPY
{	
	Param (
		[string]$ofp
	)
	
	if (Test-Path $ofp) {
		Write-Output "�������� ������ ������ GoodbyeDPI"
		[void](Remove-Item $ofp -Recurse -Confirm:$False -Force)
	}
}

$host.ui.RawUI.WindowTitle = "DFE"
Write-Host "Discord For Everyone" -ForegroundColor red
Write-Host ""

$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
function global:Write-Host() {}

Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global

[void]([System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"))

$os_type = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match �(x64)�

$gdpi_f = "DPI"
$path = ""
if ($os_type -eq $True) {
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $gdpi_f + "\x86_64"
}
else
{
	$path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $gdpi_f + "\x86"
}

Write-Output "�������� ������� GoodbyeDPI"

$gdpi_service_exists = Get-Service -Name "DFE" -ErrorAction SilentlyContinue

if ($gdpi_service_exists.Length -gt 0) {
	$result = [System.Windows.Forms.MessageBox]::Show('� ��� ��� ���������� DFE' + [System.Environment]::NewLine + [System.Environment]::NewLine + '�������?' , "DFE" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Error)
	if ($result -eq 'Yes') {
		Write-Output "������������� � ������� ������ DFE"
		[void](sc.exe stop "DFE")
		[void](sc.exe delete "DFE")
		DelGDPY -ofp (Split-Path $path -Parent)
		exit
	}
	if ($result -eq 'No') {
		exit
	}
}

$result = [System.Windows.Forms.MessageBox]::Show('������ ��������� ������ DFE' + [System.Environment]::NewLine + [System.Environment]::NewLine + '����������?' , "DFE" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {

	$path = Split-Path (Split-Path $path -Parent) -Parent

	DelGDPY -ofp "$path\$gdpi_f"
	
	[void](New-Item -Path "$path\$gdpi_f" -ItemType Directory -Confirm:$False -Force)

	Write-Output "���������� GoodbyeDPI..."
			
	Invoke-RestMethod 'https://api.github.com/repos/ValdikSS/GoodbyeDPI/releases/latest' | % assets | ? name -like "*.zip" | % { 
		Invoke-WebRequest $_.browser_download_url -OutFile ("$path\" + $_.name) 
		$gdpi_an = $_.name
	}
	Write-Output "���������� ������"
	
	Expand-Archive -Path "$path\$gdpi_an" -DestinationPath $path
	$unpacked_folder = "$path\$gdpi_an".TrimEnd('.zip')
	[void](Move-Item -Path "$unpacked_folder\*" -Destination "$path\$gdpi_f" -Force -Confirm:$False)
	
	if (Test-Path "$unpacked_folder") {[void](Remove-Item "$unpacked_folder" -Confirm:$False -Force -Recurse)}
	if (Test-Path "$path\$gdpi_an") {[void](Remove-Item "$path\$gdpi_an" -Confirm:$False -Force)}

	Write-Output "�������� white_list.txt"

	Start-BitsTransfer -Source 'https://raw.githubusercontent.com/Sam282SD/DFE/main/white_list.txt' -Destination "$path\$gdpi_f"

	Write-Output "��������� ������� DFE"
	
	if ($os_type -eq $True) {
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles") + "\" + $gdpi_f + "\x86_64\goodbyedpi.exe"
	}
	else
	{
		$exe_path = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)") + "\" + $gdpi_f + "\x86\goodbyedpi.exe"
	}

	[void](cmd.exe /c "sc create `"DFE`" binPath= `"$exe_path -5 --blacklist `"`"$path\$gdpi_f\white_list.txt`"`"")
	[void](sc.exe config "DFE" start= auto)
	[void](sc.exe description "DFE" "Discord for everyone.")
	
	Write-Output "��������� ������ DFE"
	[void](sc.exe start "DFE")
	
	$result = [System.Windows.Forms.MessageBox]::Show('DFE ������� ����������' + [System.Environment]::NewLine + [System.Environment]::NewLine + "������ ����� �������� ������ � ����� �������, ���� �� �� ������� ��� ��������� �������� DFE_installer.bat", "DFE" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
if ($result -eq 'No') {
	exit
}

