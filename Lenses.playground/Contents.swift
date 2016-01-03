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



protocol BoundLens {
    typealias Whole
    typealias Part

    var _instance: Whole { get }
    var _lens: Lens<Whole, Part> { get }

    func get() -> Part
    func set(newPart: Part) -> Whole
}

extension BoundLens {
    func get() -> Part {
        return _lens.get(_instance)
    }

    func set(newPart: Part) -> Whole {
        return _lens.set(newPart, _instance)
    }
}

struct GenericBoundLens<A, B>: BoundLens {
    typealias Whole = A
    typealias Part = B

    let _instance: Whole
    let _lens: Lens<Whole, Part>
}



extension Person {
    struct BoundLenses {
        let _instance: Person

        var name: GenericBoundLens<Person, String> {
            return GenericBoundLens<Person, String>(
                _instance: self._instance,
                _lens: Person.Lenses.name
            )
        }

        struct PersonAddressBoundLens: BoundLens {
            typealias Whole = Person
            typealias Part = Address

            let _instance: Whole
            let _lens: Lens<Whole, Part>

            var street: GenericBoundLens<Person, String> {
                return GenericBoundLens<Person, String>(
                    _instance: self._instance,
                    _lens: Person.Lenses.address.compose(Address.Lenses.street)
                )
            }
        }

        var address: PersonAddressBoundLens {
            return PersonAddressBoundLens(
                _instance: _instance,
                _lens: Person.Lenses.address
            )
        }
    }

    var lenses: BoundLenses {
        return BoundLenses(_instance: self)
    }
}



narf.lenses.name.get()
narf.lenses.name.set("narf")

narf.lenses.address.street.set("Baker Street")
