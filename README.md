Lenso
=====

A Swift µframework and code generator for lenses — "functional getters and setters", convenient when changing parts of immutable objects.  Featuring dot notation, zero new operators.

```swift
struct Person {
    let name: String
    let address: Address
}

struct Address {
    let street: String
}

let author = Person(name: "Maciej Konieczny", address: Address(street: "Sesame Street"))
let author2 = author.throughLens.address.street.set("Baker Street")

// generated lens code "hidden" in another file
```

TODO: intro in README, blog post

- Version 0.1.0 (following [Semantic Versioning](http://semver.org/))
- Developed and tested using Xcode 7.2
- Published under the [MIT License](LICENSE)


Installation
------------

`lenso` is an executable [Python script](lenso) with no dependencies.  Put it
somewhere in your `$PATH`.


Usage
-----

Lenso is a command line application.  It takes as input models described in JSON and returns library code and generated lenses, so that you can keep them in one file:

    cat models.json | lenso > lenses.swift

See [example playground](example) to see it in action.


Introduction to lenses
----------------------

Lenses are "functional getters and setters" for immutable objects.  A lens is made for a `Whole` object and its `Part`.  You can "look through" the lens at an object to get its part — the lens acts as a getter.  You can also use the lens to change a part of an object.  Then it acts like a setter, except we are talking about immutable objects here, so after "setting", the lens returns a new `Whole` object with the new part swapped in.

```swift
struct Lens<Whole, Part> {
    let get: Whole -> Part
    let set: (Part, Whole) -> Whole
}
```

Given models from the top of this README,

```swift
struct Person {
    let name: String
    let address: Address
}

struct Address {
    let street: String
}

let author = Person(name: "Maciej Konieczny", address: Address(street: "Sesame Street"))
```

a lens for a person's name is implemented and used like this:

```swift
let personNameLens = Lens<Person, String>(
    get: { $0.name },
    set: { (newName, person) in
        Person(name: newName, address: person.address)
    }
)

let author2 = personNameLens.set("narf", author)
```

Lenso generates code for such lenses for each specified model and puts them in a `Lenses` struct inside a model extension:

```swift
let author2 = Person.Lenses.name.set("narf", author)
```

Lenses can also be composed: if you have a lens from A to B and a lens from B to C, you can make a new lens out them, from A to C:

```swift
let personStreetLens = Person.Lenses.address.compose(Address.Lenses.street)
let author3 = personStreetLens.set("Wisteria Lane", author)
```

This is much better than manually recreating model hierarchies when you want to change a property value somewhere down the line, but it still requires a lot of typing and feels "indirect".  This is where "chain-aware" *bound lenses* come to help.


Bound lenses
------------

Bound lenses are lenses that are already "used half way".  They already have a `Whole` instance associated with them.  This allows for a much nicer, more familiar syntax: `author.throughLens.name.get()` instead of `Person.Lenses.name.get(author)`.  Lenso generates bound lens structs in such a way that they allow access to properties further down the object chain, without having to manually compose lenses:

```swift
let author4 = author.throughLens.address.street.set("Baker Street")
```

I think this is a big win and it makes working with immutable objects easier.


Meta
----

Hello, my name is [Maciej Konieczny](http://narf.pl/).  I started playing with lenses and created Lenso (it means "a lens" in Esperanto) after watching Brandon Williams' talk [Lenses in Swift](https://www.youtube.com/watch?v=ofjehH9f-CU).  I recommend you watch it too, it's good! :)

By the way, I'm looking for a job, so if you’re working on a good product (an iOS app, a web service, a game, an ecosystem…), check out [my CV](http://narf.pl/cv), mention me to your boss, and get in touch via email at <hello@narf.pl>.

Cheers.
