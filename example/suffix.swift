
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
