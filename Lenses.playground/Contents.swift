struct Person {
    let name: String
    let address: Address
}

struct Address {
    let street: String
}




extension Person: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(name) from \(address)"
    }
}

extension Address: CustomDebugStringConvertible {
    var debugDescription: String {
        return street
    }
}




let narf = Person(name: "Maciej Konieczny", address: Address(street: "Sesame Street"))



struct Lens<Whole, Part> {
    let get: Whole -> Part
    let set: (Part, Whole) -> Whole
}



let personNameLens = Lens<Person, String>(
    get: { $0.name },
    set: { (newName, person) in
        return Person(name: newName, address: person.address)
    }
)


personNameLens.set("narf", narf)
