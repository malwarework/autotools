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
