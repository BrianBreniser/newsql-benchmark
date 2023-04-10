#!/usr/bin/python3
"""A module to apply templating from a JSON file to the openshift configs"""

import json
import sys

# set up logging
import logging
logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger(__name__)

def apply_templating(json_arg, template_arg, output_arg):
    """Apply templating from a 'json' file to 'template' file and store in 'output' file"""

    with open(json_arg, 'r', encoding='utf-8') as json_file:
        data = json.load(json_file)

    with open(template_arg, 'r', encoding='utf-8') as template_file:
        template_arg = template_file.read()

    # Replace the template variables with the values in the JSON file
    for key, value in data.items():
        template_arg = template_arg.replace('{{' + key + '}}', value)

    with open(output_arg, 'w', encoding='utf-8') as out_file:
        out_file.write(template_arg)

def main():
    """Main function"""

    # Check for the correct number of arguments
    if len(sys.argv) != 4:
        LOGGER.error('Usage: %s <json> <template> <output>', sys.argv[0])
        sys.exit(1)

    # Call the function
    apply_templating(sys.argv[1], sys.argv[2], sys.argv[3])

if __name__ == '__main__':
    main()
