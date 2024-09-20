# Lambdas

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Hummingbird Mustache Lambda implementation

## Overview

The library provides support for mustache lambdas via the type `MustacheLambda`. 

## Rendering variables

The mustache manual section for mustache lambdas when rendered as variables states. 

> Manual: If any value found during the lookup is a callable object, such as a function or lambda, this object will be invoked with zero arguments. The value that is returned is then used instead of the callable object itself.
>
> An optional part of the specification states that if the final key in the name is a lambda that returns a string, then that string should be rendered as a Mustache template before interpolation. It will be rendered using the default delimiters (see Set Delimiter below) against the current context.

Swift Mustache supports both parts of the specification of lambdas when rendered as variables. Instead of a callable object, swift-mustache requires the type to be a `MustacheLambda` initialized with a closure that has no parameters. 

> If the lambda is rendered as a variable and you supply a closure that accepts a `String` then the supplied `String` is empty.

Below we have a couple of examples of rendering mustache lambdas as variables. One returning a tuple and one returning a `String` which is then parsed as a template. If we have the following object
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
and the following mustache template  
```swift
let mustache = """
    * {{time.hour}}
    * {{today}}
    """
let template = try MustacheTemplate(string: mustache)
```
then `template.render(object)` will output 
```
* 0
* 1970-1-1
```

In this example the first part of the template calls lambda `time` and then uses `hour` from the return object. In the second part the `today` lambda returns a string which is then parsed as mustache and renders the year.

## Rendering sections

The mustache manual section for mustache lambdas when rendered as a section states.

> Manual: When any value found during the lookup is a callable object, such as a function or lambda, the object will be invoked and passed the block of text. The text passed is the literal block, unrendered. {{tags}} will not have been expanded.
>
> An optional part of the specification states that if the final key in the name is a lambda that returns a string, then that string replaces the content of the section. It will be rendered using the same delimiters as the original section content. In this way you can implement filters or caching.

Swift Mustache does not support the part of the specification of lambdas when rendered as sections pertaining to delimiters. As with variables, instead of a callable object, swift-mustache requires the type to be a `MustacheLambda` which can be initialized with either a closure that accepts a String or nothing. When the lambda is rendered as a section the supplied `String` is the contents of the section.

If we have an object as follows
```swift
let object: [String: Any] = [
  "name": "Willy",
  "wrapped": MustacheLambda { text in
    return "<b>" + text + "</b>"
  }
]
```
and the following mustache template  
```swift
let mustache = "{{#wrapped}}{{name}} is awesome.{{/wrapped}}"
let template = try MustacheTemplate(string: mustache)
```
Then `template.render(object)` will output 
```
<b>Willy is awesome.</b>
```

Here when the `wrapped` section is rendered the text inside the section is passed to the `wrapped` lambda and the resulting text passed back is parsed as a new template.