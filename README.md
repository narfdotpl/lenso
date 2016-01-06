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

TODO


Meta
----

Hello, my name is [Maciej Konieczny](http://narf.pl/).  I started playing with lenses and created Lenso (it means "a lens" in Esperanto) after watching Brandon Williams' talk [Lenses in Swift](https://www.youtube.com/watch?v=ofjehH9f-CU).  I recommend you watch it too, it's good! :)

By the way, I'm looking for a job, so if you’re working on a good product (an iOS app, a web service, a game, an ecosystem…), check out [my CV](http://narf.pl/cv), mention me to your boss, and get in touch via email at <hello@narf.pl>.

Cheers.
