#!/usr/bin/env python
# encoding: utf-8

from __future__ import absolute_import, division

import json


class Model(object):

    def __init__(self, name, properties):
        self.name = name
        self.properties = properties

    @staticmethod
    def from_dict(d):
        return Model(d['name'], map(Property.from_dict, d['properties']))

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


def main():
    pass

if __name__ == '__main__':
    main()
