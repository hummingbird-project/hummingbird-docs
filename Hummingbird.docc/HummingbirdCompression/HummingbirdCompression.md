# HummingbirdCompression

Adds request decompression and response compression to Hummingbird

## Overview

Add support for compressing HTTP response data. Adding response compression means when a request comes in with header `accept-encoding` set to `gzip` or `deflate` the server will compression the response body.

```swift
let router = Router()
// run response compression when buffer is larger than 4096 bytes
router.middlewares.add(ResponseCompressionMiddleware(minimumResponseSizeToCompress: 4096))
```

Add support for decompressing HTTP request data. Adding request decompression means when a request comes in with header `content-encoding` set to `gzip` or `deflate` the server will attempt to decompress the request body. 

```swift
let router = Router()
// run request decompression
router.middlewares.add(RequestDecompressionMiddleware())
```

## See Also

- ``Hummingbird``