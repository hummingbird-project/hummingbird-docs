import MongoKitten
import Hummingbird

struct Kitten: ResponseCodable {
    static let collection = "kittens"

    let _id: ObjectId
    var name: String
}
