# LDAP
- **DS (Directory Server)** - entity which stores data (aka database)

## LDAP Entry
Holds data for an entity and consists of 3 main components:
- **DN (Distinguished Name)** - unique identifier for the entry, includes multiple **Relative Distinguished Names (RDNs)**. Each RDNs consists of key-value pair `uid=admin,dc=hackthebox,dc=com`
- Multiple **attributes** that store data. Each attribute consists of an attribute type and a set of values
- Multiple **Object Classes** which consists of attribute types that are related to a particular type of object, e.g Person or Group

## LDAP Operations
- **Bind Operation**: client authc with the server
- **Unbind Operation**: close the client connetion to the server
- **Add Operation**: Create a new entry
- **Delete Operation**: Delete an entry
- **Modify OPeration**: Modify an entry
- **Search Operation**: Search for entries matching a search query

## LDAP Search Filter Syntax
A search filter may consist of multiple components, each needing to be enclosed in parentheses `()`. Each base component consists of an **attribute**, an **operand**, and a **value(()) to search for.

|Name|Operand|Example|Description|
|-|-|-|-|
|Equality|`=`|`(name=Kaylie)`|Matches all entries that contain a **name** attribute with the value **Kaylie**|
|Greater-Or-Equal|`>=`|`(uid>=10)`|Matches all entries that contain a **uid** attribute with a value greater-or-equal to **10**|
|Less-Or-Equal|`<=`|`(uid<=10)`|Matches all entries that contain a **uid** attribute with a value less-or-equal to **10**|
|Approximate Match|`~=`|`(name~=Kaylie)`|Matches all entries that contain a **name** attribute with approximately the value **Kaylie**|
|And|`(&()())`|`(&(name=Kaylie)(title=Manager))`|Matches all entries that contain a **name** attribute with the value **Kaylie** and a **title** attribute with the value **Manager**|
|And||`(&(attr1=a)(attr2=b)(attr3=c)(attr4=d))`||
|Or|`(\|()())`|`(\|(name=Kaylie)(title=Manager))`|Matches all entries that contain a **name** attribute with the value **Kaylie** or a **title** attribute with the value **Manager**|
|Or||`(\|(attr1=a)(attr2=b)(attr3=c)(attr4=d))`||
|Not|`(!())`|`(!(name=Kaylie))`|Matches all entries that contain a **name** attribute with a value different from **Kaylie**|
|`True`|`(&)`||
|`False`|`(\|)`||
|||`(name=*)`|Matches all entries that contain a **name** attribute|
|||`(name=K*)`|Matches all entries that contain a **name** attribute that begins with **K**|
|||`(name=*a*)`|(name=*a*)	Matches all entries that contain a **name** attribute that contains an **a**|

## Common Attribute Types
|Type|Description|
|-|-|
|`cn`|Full name|
|`givenName`|FIrst Name|
|`sn`|Last name|
|`uid`|User ID|
|`objectClass`|Object type|
|`distinguishedName`|Distinguished Name|
|`ou`|Organizational Unit|
|`title`|Title of a Person|
|`telephoneNumber`|Phone Number|
|`description`|Description|
|`mail`|Email Address|
|`street`|Address|
|`postalCode`|Zip code|
|`member`|Group Memberships|
|`userPassword`|User password|