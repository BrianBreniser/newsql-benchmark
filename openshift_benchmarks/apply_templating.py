#!/usr/bin/env python3
"""A module to apply templating from a JSON file to the openshift configs"""

import json
import sys

# Pylint: ignore lines too long
# pylint: disable=C0301 # Yes it needs to be commented, this is how pylint works

# set up logging
import logging
logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger(__name__)

# The grunt of the templating engine
def apply_templating(config_option, file, filename_for_json_values, filename_for_template, filename_for_results):
    """
    Apply templating to a file

    Args:
        config_option (str): The config option to use from the JSON file, this is the first key in the JSON file
        file (str): The file to apply templating to, this is the second key in the JSON file
        filename_for_json_values (str): The name of the JSON file to use, probably values.json, but is configurable
        filename_for_template (str): The name of the template file to use, the yaml file that has templating
        filename_for_results (str): The name of the file to write the results to
    """

    # It's easer to hardcode the path here, unlikely to change
    filename_for_json_values = f'templates/{filename_for_json_values}'
    filename_for_template = f'templates/{filename_for_template}'

    # Get files
    with open(filename_for_json_values, 'r', encoding='utf-8') as json_file:
        # Which config option should we be using? Try to get it.
        try:
            config = json.load(json_file)[config_option]
        except KeyError:
            LOGGER.error("Invalid config option, please see the values.json file in the templates/ dir for valid options")
            sys.exit(1)

        # Which file are we working on? Try to get those KV pairs from the json.
        try:
            data = config[file]
        except KeyError:
            LOGGER.error("Invalid file string, please see the values.json file in the templates/ dir for valid files (It is the second key in the JSON file)")
            sys.exit(1)

    # Grab the template
    with open(filename_for_template, 'r', encoding='utf-8') as template_file:
        filename_for_template = template_file.read()

    # Apply templating
    for key, value in data.items():
        filename_for_template = filename_for_template.replace('{{' + key + '}}', value)

    # Write result
    with open(filename_for_results, 'w', encoding='utf-8') as out_file:
        out_file.write(filename_for_template)

def get_config_options():
    """
    Get the config options from the JSON file

    Returns:
        list: A list of the config options
    """

    # It's easer to hardcode the path here, unlikely to change
    filename_for_json_values = 'templates/values.json'

    # Get files
    with open(filename_for_json_values, 'r', encoding='utf-8') as json_file:
        config_options = json.load(json_file).keys()

    return config_options

# If this is run as a script, run the main function
def main():
    """
    Main function, called when the script is run

    If there are 5 arguments, grab the args and apply templating manually
    Otherwise, the fist argument must be a config option string
    """

    # If there are 5 arguments, grab the args and apply templating manually
    if len(sys.argv) == 6:
        apply_templating(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
        sys.exit(0)

    # quick help flag
    if len(sys.argv) == 2 and (sys.argv[1] == "-h" or sys.argv[1] == "--help"):
        options = get_config_options()
        print("Use Default Template (demo_setup): ./apply_templating.py")
        print("Use Specific Template: ./apply_templating.py <config_option>")
        print("Use Custom Template files: ./apply_templating.py <config_option> <file> <filename_for_json_values> <filename_for_template> <filename_for_results>")
        print("Valid config options:")
        for option in options:
            print(f"  {option}")
        sys.exit(0)

    # If we were not passed any args, use the demo, otherwise, use the argument
    if len(sys.argv) == 1:
        config = "demo_setup"
    else:
        config = sys.argv[1]

    template_list = [
        ("fdb", "values.json", "fdb_template.yaml", "fdb.yaml"),
        ("localstorage", "values.json", "local_storage_operator_template.yaml", "local_storage_operator.yaml"),
        ("ycsb-deployment", "values.json", "ycsb_deployment_template.yaml", "ycsb_deployment.yaml")
    ]

    for template in template_list:
        apply_templating(config, template[0], template[1], template[2], template[3])

if __name__ == '__main__':
    main()
