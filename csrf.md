# CSRF

## Referer bypass
Если приложение работает с отсутствующим заголовком `Referer`, то можно его исключить через html
```html
<meta name="referrer" content="never">
```