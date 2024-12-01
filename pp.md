# Prototype Pollution
## Useful links
- [Client-Side Prototype Pollution](https://github.com/BlackFan/client-side-prototype-pollution#prototype-pollution)
- [Blackbox detection](https://portswigger.net/research/server-side-prototype-pollution)

## Identification
- **Status code** during manipulation (in case of invalid JSON)
```json
{
	"__proto__":{
		"status":555
	}
}
```
- **Parameter limiting** (reflection of request parameters in response).
Manipulation the number of GET parameters returned by the web application by polluting the `parameterLimit` property of the Object.prototype object 
```json
{
	"__proto__":{
		"parameterLimit":1
	}
}
```
- **Content-Type**. We can force the web application to accept other encodings without breaking the web application. We will use the `UTF-7` encoding for this since it does not break the web application's default `UTF-8` encoding. First, we need to encode a test string in `UTF-7`, which we can do using `iconv`
```bash
echo -n 'HelloWorld!!!' | iconv -f UTF-8 -t UTF-7
```
If we send the test string to the web application, it is reflected as-is. In particular, it was not UTF-7 decoded. 

We can manipulate the value of the `Content-Type` Header used by the web application by polluting the content-type property of the Object.prototype object using a payload similar to the following:
```json
{
	"__proto__":{
		"content-type":"application/json; charset=utf-7"
	}
}
```

