#!/usr/bin/env python
# encoding: utf-8
"""
Lenso

A Swift µframework and code generator for lenses — "functional getters and
setters", convenient when changing parts of immutable objects.

https://github.com/narfdotpl/lenso
"""

from __future__ import absolute_import, division

import fileinput
import json


_lenses_api = """
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
"""[1:]

_bound_lenses_api = """
struct BoundLensStorage<Whole, Part> {
    let instance: Whole
    let lens: Lens<Whole, Part>
}


protocol BoundLensType {
    typealias Whole
    typealias Part

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
"""[1:]


class Model(object):

    def __init__(self, name, properties):
        self.name = name
        self.properties = properties

    @staticmethod
    def from_dict(d):
        return Model(d['name'], map(Property.from_dict, d['properties']))

    def _bound_lens_type(self):
        return _bound_lens_type_for_type(self.name)

    def _bound_lens_source(self, model_types):
        source = """
struct %s<Whole>: BoundLensType {
    typealias Part = %s
    let boundLensStorage: BoundLensStorage<Whole, Part>
"""[1:] % (self._bound_lens_type(), self.name)

        for p in self.properties:
            if p.type in model_types:
                bound_lens_type = _bound_lens_type_for_type(p.type) + '<Whole>'
            else:
                bound_lens_type = 'BoundLens<Whole, %s>' % p.type

            source += """
    var %s: %s {
        return %s(parent: self, sublens: %s.Lenses.%s)
    }
""" % (p.name, bound_lens_type, bound_lens_type, self.name, p.name)

        source += "}\n"

        return source

    def bound_lens_extension_source(self):
        type = '%s<%s>' % (self._bound_lens_type(), self.name)

        return """
extension %s {
    var throughLens: %s {
        return %s(instance: self, lens: createIdentityLens())
    }
}
"""[1:] % (self.name, type, type)

    def instance_name(self):
        return self.name[0].lower() + self.name[1:]

    def struct_source(self):
        source = 'struct %s {\n' % self.name

        for property in self.properties:
            source += '    let %s: %s\n' % (property.name, property.type)

        source += '}\n'

        return source

    def lens_source(self):
        return """
extension %s {
    struct Lenses {
%s    }
}
"""[1:] % (self.name, '\n'.join(indent(self._lens_property_source(p), depth=2)
                                for p in self.properties))

    def _lens_property_source(self, property):
        def constructor_argument(some_property):
            p = some_property
            if p == property:
                value = p.new_value_name()
            else:
                value = '%s.%s' % (self.instance_name(), p.name)

            return '%s: %s' % (p.name, value)

        p = property
        return """
static let %s = Lens<%s, %s>(
    get: { $0.%s },
    set: { (%s, %s) in
        %s(%s)
    }
)
"""[1:] % (p.name, self.name, p.type, p.name, p.new_value_name(),
           self.instance_name(), self.name,
           ', '.join(map(constructor_argument, self.properties)))


class Property(object):

    def __init__(self, name, type):
        self.name = name
        self.type = type

    @staticmethod
    def from_dict(d):
        return Property(d['name'], d['type'])

    def new_value_name(self):
        return 'new' + self.name[0].upper() + self.name[1:]


def indent(text, depth=1):
    prefix = ' ' * 4 * depth
    add_prefix = lambda line: prefix + line if line else line
    separator = '\n'

    return separator.join(map(add_prefix, text.split(separator)))


def parse_models_json(json_string):
    parsed_json = json.loads(json_string)

    return map(Model.from_dict, parsed_json['models'])


def _bound_lens_type_for_type(type):
    return 'BoundLensTo%s' % type


def generate_bound_lenses(models):
    model_types = [x.name for x in models]

    return '\n'.join(x._bound_lens_source(model_types) for x in models)


def read_stdin():
    text = ''
    for line in fileinput.input():
        text += line

    return text


def generate_full_source(models):
    return """
// Models generated from JSON

%s

// Lenses API

%s

// Bound lenses API

%s

// Generated lenses

%s

// Generated bound lenses

%s

%s
"""[1:] % (
        '\n'.join(x.struct_source() for x in models),
        _lenses_api,
        _bound_lenses_api,
        '\n'.join(x.lens_source() for x in models),
        generate_bound_lenses(models),
        '\n'.join(x.bound_lens_extension_source() for x in models)
    )


def main():
    print generate_full_source(parse_models_json(read_stdin()))

if __name__ == '__main__':
    main()
