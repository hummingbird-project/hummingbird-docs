# ``Mustache``

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Mustache template engine. 

## Overview

Mustache is a "logic-less" templating language commonly used in web and mobile platforms. You can find out more about it from the [mustache manual](http://mustache.github.io/mustache.5.html).

While swift-mustache has been designed to be used with the Hummingbird server framework, it has no dependencies and can be used as a standalone library.

## Usage

Load your templates from the filesystem 
```swift
let library = MustacheLibrary("folder/my/templates/are/in")
```
This will look for all the files with the extension `.mustache` in the specified folder and subfolders and attempt to load them. Each file is registered with the name of the file (with subfolder, if inside a subfolder) minus the `.mustache` extension.

The following code shows how to render an object with a template:
```swift
let output = library.render(object, withTemplate: "myTemplate")
```
`Mustache` treats an object as a set of key/value pairs when rendering and renders both dictionaries and objects via `Mirror` reflection.

## Support

Mustache supports all standard Mustache tags and is fully compliant with the Mustache [spec](https://github.com/mustache/spec) with the exception of the Lambda support.  

## Topics

### Template Library

- ``MustacheLibrary``
- ``MustacheTemplate``

### Rendering

- ``MustacheCustomRenderable``
- ``MustacheParent``
- ``MustacheTransformable``
- ``MustacheLambda``

### Content Types

- ``MustacheContentType``
- ``MustacheContentTypes``
