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
        Person(name: newName, address: person.address)
    }
)


personNameLens.set("narf", narf)



let personAddressLens = Lens<Person, Address>(
    get: { $0.address },
    set: { (newAddress, person) in
        Person(name: person.name, address: newAddress)
    }
)

let addressStreetLens = Lens<Address, String>(
    get: { $0.street },
    set: { (newStreet, address) in
        Address(street: newStreet)
    }
)



extension Lens {
    func compose<Subpart>(other: Lens<Part, Subpart>) -> Lens<Whole, Subpart> {
        return Lens<Whole, Subpart>(
            get: { whole in
                let part = self.get(whole)
                let subpart = other.get(part)

                return subpart
            },
            set: { (newSubpart, whole) in
                let part = self.get(whole)
                let newPart = other.set(newSubpart, part)
                let newWhole = self.set(newPart, whole)

                return newWhole
            }
        )
    }
}


let personStreetLens = personAddressLens.compose(addressStreetLens)
personStreetLens.get(narf)



extension Person {
    struct Lenses {
        static let name = personNameLens
        static let address = personAddressLens
    }
}


extension Address {
    struct Lenses {
        static let street = addressStreetLens
    }
}



Person.Lenses.name.set("Kuba", narf)
