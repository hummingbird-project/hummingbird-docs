// UPDATE query
let query: PostgresQuery = """
    UPDATE todos SET \(optionalUpdateFields: (("title", title), ("order", order), ("completed", completed))) WHERE id = \(id)
    """

/// Append interpolation of a series of fields with optional values for a SQL UPDATE call. 
/// If the value is nil it doesn't add the field to the query.
/// 
/// This call only works if you have more than one field.
mutating func appendInterpolation<each Value: PostgresDynamicTypeEncodable>(optionalUpdateFields fields: (repeat (String, Optional<each Value>))) {
    func appendSelect(id: String, value: Optional<some PostgresDynamicTypeEncodable>, first: Bool) -> Bool {
        if let value {
            self.appendInterpolation(unescaped: "\(first ? "": ", ")\(id) = ")
            self.appendInterpolation(value)
            return false
        }
        return first
    }
    var first: Bool = true // indicates whether we should prefix with a comma
    repeat (
        first = appendSelect(id: (each fields).0, value: (each fields).1, first: first)
    )
}
