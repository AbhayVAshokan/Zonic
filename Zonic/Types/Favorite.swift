import Foundation

struct Favorite {
    var id: Int64
    var label: String
//    TODO: need to fix Date? => Date
    var created_at: Date?
    var place: Place
}
