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

if __name__ == '__main__':
    unittest.main()
