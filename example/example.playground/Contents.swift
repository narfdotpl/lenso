// Code created by Lenso v0.2.0-dev
// https://github.com/narfdotpl/lenso

// Models generated from JSON

struct Person {
    let name: String
    let address: Address
}

struct Address {
    let street: String
}


// Lenses API

struct Lens<Whole, Part> {
    let get: Whole -> Part
    let set: (Part, Whole) -> Whole
}

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

private func createIdentityLens<Whole>() -> Lens<Whole, Whole> {
    return Lens<Whole, Whole>(
        get: { $0 },
        set: { (new, old) in return new }
    )
}


// Bound lenses API

struct BoundLensStorage<Whole, Part> {
    let instance: Whole
    let lens: Lens<Whole, Part>
}


protocol BoundLensType {
    associatedtype Whole
    associatedtype Part

    init(boundLensStorage: BoundLensStorage<Whole, Part>)

    var boundLensStorage: BoundLensStorage<Whole, Part> { get }

    func get() -> Part
    func set(newPart: Part) -> Whole
}

extension BoundLensType {
    init(instance: Whole, lens: Lens<Whole, Part>) {
        self.init(boundLensStorage: BoundLensStorage(instance: instance, lens: lens))
    }

    init<Parent: BoundLensType where Parent.Whole == Whole>(parent: Parent, sublens: Lens<Parent.Part, Part>) {
        let storage = parent.boundLensStorage
        self.init(instance: storage.instance, lens: storage.lens.compose(sublens))
    }

    func get() -> Part {
        return boundLensStorage.lens.get(boundLensStorage.instance)
    }

    func set(newPart: Part) -> Whole {
        return boundLensStorage.lens.set(newPart, boundLensStorage.instance)
    }
}


struct BoundLens<Whole, Part>: BoundLensType {
    let boundLensStorage: BoundLensStorage<Whole, Part>
}


// Generated lenses

extension Person {
    struct Lenses {
        static let name = Lens<Person, String>(
            get: { $0.name },
            set: { (newName, person) in
                Person(name: newName, address: person.address)
            }
        )

        static let address = Lens<Person, Address>(
            get: { $0.address },
            set: { (newAddress, person) in
                Person(name: person.name, address: newAddress)
            }
        )
    }
}

extension Address {
    struct Lenses {
        static let street = Lens<Address, String>(
            get: { $0.street },
            set: { (newStreet, address) in
                Address(street: newStreet)
            }
        )
    }
}


// Generated bound lenses

struct BoundLensToPerson<Whole>: BoundLensType {
    typealias Part = Person
    let boundLensStorage: BoundLensStorage<Whole, Part>

    var name: BoundLens<Whole, String> {
        return BoundLens<Whole, String>(parent: self, sublens: Person.Lenses.name)
    }

    var address: BoundLensToAddress<Whole> {
        return BoundLensToAddress<Whole>(parent: self, sublens: Person.Lenses.address)
    }
}

struct BoundLensToAddress<Whole>: BoundLensType {
    typealias Part = Address
    let boundLensStorage: BoundLensStorage<Whole, Part>

    var street: BoundLens<Whole, String> {
        return BoundLens<Whole, String>(parent: self, sublens: Address.Lenses.street)
    }
}


extension Person {
    var throughLens: BoundLensToPerson<Person> {
        return BoundLensToPerson<Person>(instance: self, lens: createIdentityLens())
    }
}

extension Address {
    var throughLens: BoundLensToAddress<Address> {
        return BoundLensToAddress<Address>(instance: self, lens: createIdentityLens())
    }
}



// Manual testing

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


// use convenient bound lenses that know about the model hierarchy
let author = Person(name: "Maciej Konieczny", address: Address(street: "Sesame Street"))
let author2 = author.throughLens.address.street.set("Baker Street")

// bound lenses are powered by regular (unbound) lenses...
let author3 = Person.Lenses.name.set("narf", author)

// ...that can be composed
let personStreetLens = Person.Lenses.address.compose(Address.Lenses.street)
let author4 = personStreetLens.set("Wisteria Lane", author)
