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



struct GenericPersonBoundLens<A>: BoundLens {
    typealias Whole = A
    typealias Part = Person

    let _instance: Whole
    let _lens: Lens<Whole, Part>

    var name: GenericBoundLens<Whole, String> {
        return GenericBoundLens<Whole, String>(
            _instance: _instance,
            _lens: _lens.compose(Person.Lenses.name)
        )
    }

    var address: GenericAddressBoundLens<Whole> {
        return GenericAddressBoundLens<Whole>(
            _instance: _instance,
            _lens: _lens.compose(Person.Lenses.address)
        )
    }
}

struct GenericAddressBoundLens<A>: BoundLens {
    typealias Whole = A
    typealias Part = Address

    let _instance: Whole
    let _lens: Lens<Whole, Part>

    var street: GenericBoundLens<Whole, String> {
        return GenericBoundLens<Whole, String>(
            _instance: _instance,
            _lens: _lens.compose(Address.Lenses.street)
        )
    }
}



func createIdentityLens<Whole>() -> Lens<Whole, Whole> {
    return Lens<Whole, Whole>(
        get: { $0 },
        set: { (new, old) in return new }
    )
}



extension Person {
    var lens: GenericPersonBoundLens<Person> {
        return GenericPersonBoundLens<Person>(_instance: self, _lens: createIdentityLens())
    }
}


extension Address {
    var lens: GenericAddressBoundLens<Address> {
        return GenericAddressBoundLens<Address>(_instance: self, _lens: createIdentityLens())
    }
}



narf.lens.name.get()
narf.lens.name.set("narf")

narf.lens.address.street.set("Baker Street")
narf.address.lens.street.set("Baker Street")
