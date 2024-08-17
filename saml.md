# SAML
## SAML Components
- **Identity Provider (IdP)**: The entity that authenticates users. The IdP provides identity information to other components and issues SAML assertions
- **Service Provider (SP)**: The entity that provides a service or a resource to the user. It relies on SAML assertions provided by the IdP
- **SAML Assertions**: XML-based data that contains information about a user's authentication and authorization status

## SAML Flow
1. The user accesses a resource provided by the SP
2. Since the user is not authenticated, the SP initiates authentication by redirecting the user to the IdP with a SAML request
3. The user authenticates with the IdP
4. The IdP generates a SAML assertion containing the user's information, digitally signs the SAML assertion, and sends it in the HTTP response to the browser. The browser sends the SAML assertion to the SP
5. The SP verifies the SAML assertion
6. The user requests the resource
7. The SP provides the resource
![saml](./images/saml.png)