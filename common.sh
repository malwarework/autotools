==gobuster directory
gobuster dir -u $URL -w /opt/SecLists/Discovery/Web-Content/raft-medium-directories.txt -l -k -t 30

===gobuster files
gobuster dir -u $URL -w /opt/SecLists/Discovery/Web-Content/raft-medium-files.txt -l -k -t 30
txt
===gobuster for SubDomain bruteforcing
gobuster dns -d $DOMAIN -w /opt/SecLists/Discovery/DNS/subdomains-top1million-11000 -t 30
"Just make sure that any DNS name you found to an in-scope address before you test it"
=============================================================================================================
===Extract IPs from a text files
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' nmapfile.txt
=============================================================================================================
===WFUZZ XSS Fuzzing
wfuzz -c -z file,/usr/share/wordlists/Fuzzing/command-injection.txt -d "doi=FUZZ" "$URL"
