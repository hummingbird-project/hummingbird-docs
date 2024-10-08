#  Template Inheritance and parents

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Template inheritance and parents is an optional part of the Mustache specification.

## Overview

Template inheritance allows you to override elements of an included partial. It allows you to create a base page template, or parent as it is called in the mustache manual, and override elements of it with your page content. A parent that includes overriding elements is indicated with a `{{<parent}}`. Note this is different from the normal partial reference which uses `>`. This is a section tag so needs a ending tag as well. Inside the section the tagged sections to override are added using the syntax `{{$tag}}contents{{/tag}}`.

If your template is as follows
```
{{! mypage.mustache }}
{{<base}}
{{$head}}<title>My page title</title>{{/head}}
{{$body}}Hello world{{/body}}
{{/base}}
```
And you partial is as follows
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
You would get the following output when rendering `mypage.mustache`.
```
<html>
<head>
<title>My page title</title>
</head>
<body>
Hello world
</body>
```
Note the `{{$head}}` section in `base.mustache` is replaced with the `{{$head}}` section included inside the `{{<base}}` partial reference from `mypage.mustache`. The same occurs with the `{{$body}}` section. In that case though a default value is supplied for the situation where a `{{$body}}` section is not supplied. 

