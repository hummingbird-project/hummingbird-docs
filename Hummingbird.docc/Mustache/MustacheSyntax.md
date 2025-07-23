# Mustache Syntax

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Overview of Mustache Syntax

## Overview

Mustache is a "logic-less" templating engine. The core language has no flow control statements. Instead it has tags that can be replaced with a value, nothing, or a series of values. This article documents the standard mustache tags.

### Context

Mustache renders a template with a context stack. A context is a list of key/value pairs. These can be represented by either a `Dictionary` or the reflection information that `Mirror` provides. For example, the following two objects render in the same way
```swift
let object = ["name": "John Smith", "age": 68]
```
```swift
struct Person {
    let name: String
    let age: Int
}
let object = Person(name: "John Smith", age: 68)
```

Initially the stack consists of the root context object to render. When the template enters a section tag, mustache pushes the associated value onto the context stack. When the template leaves the section, it pops that value back off the stack.

### Tags

Surround all tags with a double curly bracket `{{}}`.
When a tag has a reference to a key, mustache searches for the key from the context at the top of the context stack to return the associated value.
If the key can't be found in the current context, then mustache recursively searches the next context down until either a key is found or it reaches the bottom of the stack.
If no key is found the output is `nil`, which renders as an empty string.

Use dot notation to reference the child of an associated value of a key, similar to Swift.
For example, in the tag `{{main.sub}}`, mustache searches the first context for the key `main`. If found, is uses that value for context and searches `main` for the key `sub`.

To constrain mustache to search for values in the context at the top of the stack, prefix the variable name with the period (`.`), for example: `{{.key}}`.

Use `{{.}}` to reference only the top of the stack, which can be useful if you present a template with a list.

### Tag types

- `{{key}}`: Render the value associated with `key` as text. By default this is HTML escaped. Mustache renders a `nil` value as an empty string.
- `{{{name}}}`: Acts the same as `{{name}}`, except the resulting text is not HTML escaped. You can also use `{{&name}}` to avoid HTML escaping.
- `{{#section}}`: The `#` character represents a section block that either renders text once or multiple times depending on the value of the key in the current context. A section begins with `{{#section}}` and ends with `{{/section}}`. If the key represents a Boolean value, it only renders if true. If the key represents an `Optional` it renders if the object is non-nil. If the key represents an `Array` it renders the internals of the section multiple times, once for each element of the `Array`. Otherwise it renders with the selected value pushed onto the top of the context stack. See <doc:MustacheFeatures#Rendering-sections> for more information.
- `{{^section}}`: An inverted section (`^`) does the opposite of a section. If the key represents a Boolean value, it renders if the value is false. If the key represents an `Optional` it renders if it is `nil`. If the key represents a `Array` it renders if the `Array` is empty.
- `{{! comment }}`: `!` indicates a comment tag, which is ignored.
- `{{>partial}}`: A partial tag (`>`) renders another mustache file, with the current context stack. In Swift Mustache, partial tags only work for templates that are a part of a library, and the tag represents the  name of the referenced template without the ".mustache" extension. See <doc:MustacheFeatures#Partial-templates> for more information.
- `{{*>dynamic}}`: Is a partial that mustache loads dynamically.
- `{{<parent}}`: A parent (`<`) is similar to a partial, but allows for the user to override sections of the included file. A parent tag is a section tag, and needs to end with a `{{/parent}}` tag. See <doc:MustacheFeatures#Template-inheritance-and-parents> for more information.
- `{{$}}`: The `$` represents a block that is a section of a parent template to override. If this is found inside a parent section, then it is the text that mustache replaces from the overriden block. 
- `{{=<% %>=}}`: The set delimiter (`=`) tag allows you to change from using the double curly brackets as tag delimiters. In the example the delimiters have been changed to `<% %>`, but you can change them to whatever you like.

You can find out more about the standard Mustache tags in the [Mustache Manual](https://mustache.github.io/mustache.5.html).
