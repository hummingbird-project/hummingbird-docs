import Hummingbird
import HummingbirdFoundation
import Logging

/// Custom request context setting up JSON decoding and encoding
struct TodoRequestContext: RequestContext {
    var coreContext: CoreRequestContext
    /// Set request decoder to be JSONDecoder
    var requestDecoder: JSONDecoder { .init() }
    /// Set response encoder to be JSONEncdoer
    var responseEncoder: JSONEncoder { .init() }

    init(allocator: ByteBufferAllocator, logger: Logger) {
        self.coreContext = .init(
            allocator: allocator,
            logger: logger
        )
    }
}
