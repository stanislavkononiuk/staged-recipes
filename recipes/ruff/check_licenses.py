"""Verify that Ruff dependency licenses are present."""

import os
import sys
import json
import glob

RECIPE_DIR = os.environ["RECIPE_DIR"]

BASE_GLOB = "{0}-LICENSE*"
DEPENDENCIES = "dependencies.json"
LIBRARY_LICENSES = os.path.join(RECIPE_DIR, "library_licenses")
WHITELIST = {
    # Package license is packaged on the recipe root.
    "ruff",
    # None of these include licenses with the source, despite declaring a license.
    "cachedir",
    "crunchy",
    "hexf-parse",
    "siphasher",
    "terminfo",
}


def main():
    deps = json.load(open(DEPENDENCIES, "r"))
    missing = []
    for pkg in deps:
        pkg_name = pkg["name"]
        repo_url = pkg["repository"]
        pkg_license_type = pkg["license"]
        pkg_glob = BASE_GLOB.format(pkg_name)
        matches = glob.glob(os.path.join(LIBRARY_LICENSES, pkg_glob))
        if len(matches) == 0 and pkg_name not in WHITELIST:
            missing.append((pkg_name, pkg_license_type, repo_url))
    if len(missing) > 0:
        print("Licenses for the following dependencies are " "not being packaged:")
        for name, pkg_license, repo in missing:
            print("* {0} ({1}) -> {2}".format(name, pkg_license, repo))
        sys.exit(1)


if __name__ == "__main__":
    main()
