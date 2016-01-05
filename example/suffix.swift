
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

let narf = Person(name: "Maciej Konieczny", address: Address(street: "Sesame Street"))
let familyNarf = Person.Lenses.name.set("Kuba", narf)

narf.throughLens.name.get()
narf.throughLens.name.set("narf")

narf.throughLens.address.street.set("Baker Street")
narf.address.throughLens.street.set("Baker Street")
