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

    def struct_source(self):
        source = 'struct %s {\n' % self.name

        for property in self.properties:
            source += '    let %s: %s\n' % (property.name, property.type)

        source += '}\n'

        return source


class Property(object):

    def __init__(self, name, type):
        self.name = name
        self.type = type

    @staticmethod
    def from_dict(d):
        return Property(d['name'], d['type'])


def parse_models_json(json_string):
    parsed_json = json.loads(json_string)

    return map(Model.from_dict, parsed_json['models'])


def main():
    pass

if __name__ == '__main__':
    main()
