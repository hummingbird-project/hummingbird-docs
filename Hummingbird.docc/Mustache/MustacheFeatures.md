# Mustache Features

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

An overview of the features of swift-mustache.

## Lambdas

The library provides support for mustache lambdas via the type `MustacheLambda`. 

### Rendering variables

The mustache manual section for rendering lambdas as variables states:

> Manual: If any value found during the lookup is a callable object, such as a function or lambda, this object will be invoked with zero arguments.
> The value that is returned is then used instead of the callable object itself.
>
> An optional part of the specification states that if the final key in the name is a lambda that returns a string, then that string should be rendered as a Mustache template before interpolation. It will be rendered using the default delimiters (see Set Delimiter below) against the current context.

Swift Mustache supports both parts of the specification of lambdas when rendered as variables. Instead of a callable object, swift-mustache requires the type to be an instance of `MustacheLambda` initialized with a closure that has no parameters. 

> If the lambda is rendered as a variable and you supply a closure that accepts a `String` then the supplied `String` is empty.

The examples below are a couple of examples of rendering mustache lambdas as variables.

The first lambda in the example returns a tuple, and the second returns a `String` which is parsed as a template.
```swift
let object: [String: Any] = [
    "year": 1970,
    "month": 1,
    "day": 1,
    "time": MustacheLambda {
        (hour: 0, minute: 0, second: 0)
    },
    "today": MustacheLambda { _ in
        return "{{year}}-{{month}}-{{day}}"
    },
]
```
With the object defined above, and the following mustache template:
```swift
let mustache = """
    * {{time.hour}}
    * {{today}}
    """
let template = try MustacheTemplate(string: mustache)
```

Invoking `template.render(object)` outputs: 
```
* 0
* 1970-1-1
```

The first part of the template calls the lambda `time` and then uses `hour` from the return object. In the second part the `today` lambda returns a string which is then parsed as a mustache template and renders the year.

### Rendering sections

The mustache manual section for rendering lambdas as a section states:

> Manual: When any value found during the lookup is a callable object, such as a function or lambda, the object will be invoked and passed the block of text. The text passed is the literal block, unrendered. {{tags}} will not have been expanded.
>
> An optional part of the specification states that if the final key in the name is a lambda that returns a string, then that string replaces the content of the section. It will be rendered using the same delimiters as the original section content. In this way you can implement filters or caching.

Swift Mustache does not support the part of the specification of lambdas when rendered as sections pertaining to delimiters. As with variables, instead of a callable object, swift-mustache requires the type to be a `MustacheLambda` which can be initialized with either a closure that accepts a String or nothing. When the lambda is rendered as a section the supplied `String` is the contents of the section.

The example below includes a lambda that returns a string:
```swift
let object: [String: Any] = [
  "name": "Willy",
  "wrapped": MustacheLambda { text in
    return "<b>" + text + "</b>"
  }
]
```
With the object in the example above, and the following uses that lambda to render as a section:  
```swift
let mustache = "{{#wrapped}}{{name}} is awesome.{{/wrapped}}"
let template = try MustacheTemplate(string: mustache)
```

Calling `template.render(object)` outputs: 
```
<b>Willy is awesome.</b>
```

When mustache renders the `wrapped` section, the text inside the section is passed to the `wrapped` lambda. The example parses the returned text as a new template.

## Partial templates

Partial templates let you embed one template inside another. 
A partial inherits the context of the template it's embedded within.
Reference a partial template by its name, prefixed with `>`.

For example, given the partial template `included.mustache`:
```
{{! included.mustache }}
Hello world
```

To include this tempalte in another, reference the tag as:
```
{{> included}}
```

> Note: partials and templates using inheritance require that you provide the included templates using a library.

## Template inheritance and parents

Template inheritance allows you to override elements of an included partial. It allows you to create a base page template, or parent as it is called in the mustache manual, and override elements of it with your page content.

A parent that includes overriding elements is indicated with a `<`.
For example, the tag `{{<parent}}` references a template named `parent` that has elements you override.
The template reference is a section tag, and requires an ending tag: `{{/parent}}`.
This is different from the included partial reference, which uses `>`.

Inside the section, override tagged sections using a start and stop for the section.
The start is prefixed with `$`, and the end with `/`. For example: `{{$tag}}contents{{/tag}}`.

For the example template `mypage.mustache`:
```
{{! mypage.mustache }}
{{<base}}
{{$head}}<title>My page title</title>{{/head}}
{{$body}}Hello world{{/body}}
{{/base}}
```

With an example partial `base.mustache`:
```
{{! base.mustache }}
<html>
<head>
{{$head}}{{/head}}
</head>
<body>
{{$body}}Default text{{/body}}
</body>
</html>
```

Mustache renders `mypage.mustache`:
```
<html>
<head>
<title>My page title</title>
</head>
<body>
Hello world
</body>
```

Mustache replaces the `{{$head}}` section in `base.mustache` with the `{{$head}}` section included inside the `{{<base}}` partial reference from `mypage.mustache`.
The same occurs with the `{{$body}}` section.

If a section isn't defined in the template that inherits another, the default value from the template is displayed. 
For example, if the section `{{$body}}Hello world{{/body}}` isn't included in the `mypage.mustache` example, mustache renders the value `Default text` from the template.

## Pragmas/Configuration variables

The syntax `{{% var: value}}` can be used to set template rendering configuration variables specific to Swift-Mustache. The only variable you can set at the moment is `CONTENT_TYPE`. This can be set to either to `HTML` or `TEXT`, and defines how variables are escaped. A content type of `TEXT` means no variables are escaped and a content type of `HTML` will do HTML escaping of the rendered text. The content type defaults to `HTML`.

Given input object `<>`, template:
```
{{%CONTENT_TYPE: HTML}}{{.}}
```
renders as `&lt;&gt;` and 

```
{{%CONTENT_TYPE: TEXT}}{{.}}
```
renders as `<>`.

## Transforms

Transforms are specific to this implementation of Mustache. They are similar to Lambdas but instead of generating rendered text, they allow you to transform one object into another. Transforms are formatted as a function call inside a tag, for example:
```
{{uppercase(string)}}
```
They can be applied to variable, section, and inverted section tags. If you apply them to a section tag or an inverted section tag, include the transform name in the end section tag as well. For example:
```
{{#sorted(array)}}{{.}}{{/sorted(array)}}
```
The library comes with a series of transforms for several standard Swift objects.
- String/Substring
  - capitalized: Returns string with first letter capitalized.
  - lowercase: Returns lowercased version of string.
  - uppercase: Returns uppercased version of string.
  - reversed: Returns a reversed string.
- Int/UInt/Int8/Int16...
  - equalzero: Returns if equal to zero.
  - plusone: Add one to an integer.
  - minusone: Subtract one from an integer.
  - odd: Returns if integer is odd.
  - even: Returns if integer is even.
- Array
  - first: Returns first element of an array.
  - last: Returns last element of an array.
  - count: Returns number of elements in an array.
  - empty: Returns if the array is empty.
  - reversed: Returns the reversed array.
  - sorted: If the elements of the array are comparable, returns the sorted array.
- Dictionary
  - count: Returns number of elements in a dictionary.
  - empty: Returns if the dictionary is empty.
  - enumerated: Returns the dictionary as an array of (key, value) pairs.
  - sorted: If the keys are comparable, returns an array of (key, value) pairs sorted by the key.

If a transform is applied to an object that doesn't recognise it, it returns `nil`.

### Sequence context transforms

Sequence context transforms are transforms applied to the current position in the sequence. They are formatted as a function that takes no parameter. For example:
```
{{#array}}{{.}}{{^last()}}, {{/last()}}{{/array}}
```
This example renders an array as a comma separated list. 
The inverted section of the `last()` transform ensures it doesn't add a comma after the last element.

The following sequence context transforms are available:
- first: Returns if the element the first element of the sequence.
- last: Returns if the element the last element of the sequence.
- index: Returns the index of the element within the sequence.
- odd: Returns if the index of the element is odd.
- even: Returns if the index of the element is even.

### Custom transforms

You can add transforms to your own objects. Conform your object to `MustacheTransformable` and provide an implementation of the function `transform`. For example: 
```swift 
struct Object: MustacheTransformable {
    let either: Bool
    let or: Bool
    
    func transform(_ name: String) -> Any? {
        switch name {
        case "eitherOr":
            return either || or
        default:
            break
        }
        return nil
    }
}
```
When mustache renders an instance of this object with `either` or `or` set to true, the following template renders "Success".
```
{{#eitherOr(object)}}Success{{/eitherOr(object)}}
```
This example illustrates an equivalent of a logical OR statement, which are not possible in the mustache specification.

## See Also

- ``Mustache/MustacheTemplate``
- ``Mustache/MustacheLibrary``
