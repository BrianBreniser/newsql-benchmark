#!/usr/bin/python3
"""A module to apply templating from a JSON file to the openshift configs"""

import json
import sys

# ignore lines too long
# pylint: disable=C0301

# set up logging
import logging
logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger(__name__)

def apply_templating(parent, json_arg, template_arg, output_arg):
    """Apply templating from a 'json' file to 'template' file and store in 'output' file"""

    # prepend 'templates/' to the file names using string interpolation
    json_arg = f'templates/{json_arg}'
    template_arg = f'templates/{template_arg}'

    # Get files
    with open(json_arg, 'r', encoding='utf-8') as json_file:
        data = json.load(json_file)[parent]

    with open(template_arg, 'r', encoding='utf-8') as template_file:
        template_arg = template_file.read()

    # Apply templating
    for key, value in data.items():
        template_arg = template_arg.replace('{{' + key + '}}', value)

    # Write result
    with open(output_arg, 'w', encoding='utf-8') as out_file:
        out_file.write(template_arg)

def main():
    """Main function"""

    # If there are 5 arguments, grab the args and apply templating
    if len(sys.argv) == 5:
        apply_templating(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
        sys.exit(0)

    template_list = [
        ("fdb", "values.json", "fdb_template.yaml", "fdb.yaml"),
        ("localstorage", "values.json", "local_storage_operator_template.yaml", "local_storage_operator.yaml")
    ]

    for template in template_list:
        apply_templating(template[0], template[1], template[2], template[3])

if __name__ == '__main__':
    main()
