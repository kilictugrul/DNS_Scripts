#DNS Sunucusunu tanımlıyoruz.
$dnsServer="192.168.1.100"
#Sadece Primary ve Reverse Zone olmayan zoneları bir diziye alıyoruz.
$zones=Get-DnsServerZone | Where-Object {$_.ZoneType -eq "Primary" -and $_.IsReverseLookupZone -eq $false} | Select-Object ZoneName
#Aranacak A kaydını değişkene aktarıyoruz.
$ipAddress="192.168.1.150"

#Dizi içerisindeki tüm zone lar için ip araması yapılıyor.
foreach($zone in $zones.ZoneName)
{

#zone kayıtlarını export edilecek dizini belirtiyoruz.
$outputCsv = "D:\Scripts\$($zone)_DNS_A_Records.csv"

#Tüm A Kayıtlarını Alıyoruz
$dnsRecords = Get-DnsServerResourceRecord -ComputerName $dnsServer -ZoneName $zone -RRType A

#Ip adresine eşit olanları filtreliyoruz
$filtered = $ $dnsRecords | Where-Object {$_.RecordData.IPV4Address.IPAddressToString -eq $ipAddress} | Select-Object @{n="ZoneName"; e={$($zone)}},Hostname,@{n="IPAddress"; e={$_.RecordData.IPV4Address.IPAddressToString}}

#Zone içinde en az 1 kayıt varsa dışarıya export ediyoruz.
$if ($filtered.Count -gt 0)
{
    #CSV' ye yazıyoruz.
    $filtered | Export-Csv -Path $outputCsv -Encoding UTF8 -NoTypeInformation

    #Kullanıcıya bilgi veriyoruz.
    Write-Host "A Kayıtları CSV Dosyasına kaydedildi: $outputCsv"
}

}