# JSON Support

@Metadata {
    @PageImage(purpose: icon, source: "logo")
}

Hummingbird provides JSON support through the Foundation framework. By conforming your types to ``ResponseEncodable``, Hummingbird will automatically encode your type to JSON.

Simply create a type that conforms to ``ResponseEncodable`` as such:

```swift
struct User: ResponseEncodable {
    let name: String
    let age: Int
}
```

Because Codable is not exclusively tied to JSON, these same types can also be encoded to other formats.

See: <doc:EncodingAndDecoding> for more information on how to setup another data format.

