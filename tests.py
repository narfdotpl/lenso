#!/usr/bin/env python
# encoding: utf-8

import unittest

import lenso
# after `mv lenso.py lenso`:
# from imp import load_source
# lenso = load_source('lenso', 'lenso')


class Tests(unittest.TestCase):

    def setUp(self):
        self.models = lenso.parse_models_json("""{
    "models": [
        {
            "name": "Person",
            "properties": [
                {"name": "name", "type": "String"},
                {"name": "address", "type": "Address"}
            ]
        },
        {
            "name": "Address",
            "properties": [
                {"name": "street", "type": "String"}
            ]
        }
    ]
}""")

    def test_it_generates_structs(self):
        self.assertEqual(self.models[0].struct_source(), """
struct Person {
    let name: String
    let address: Address
}
"""[1:])

        self.assertEqual(self.models[1].struct_source(), """
struct Address {
    let street: String
}
"""[1:])

    def test_it_generates_lenses(self):
        self.assertEqual(self.models[0].lens_source(), """
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
"""[1:])

        self.assertEqual(self.models[1].lens_source(), """
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
"""[1:])

if __name__ == '__main__':
    unittest.main()
