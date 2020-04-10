## Scripts to process publications

This directory contains scripts to process publications. The scripts produce a .yaml file for group publications and a .markdown file for group member publications.

The code expects that each team member will have a bibtex file named `${member}Pubs.bib`
Moreover, the code expects that the bibtex file is produced using zotero, such that the
*@article* tag is of the form `author_firstWordTitle_year` (this is used for sorting).

There are two main scripts:

### `bibtek2yaml_group.bash`
This script defines the publications on the [group publications page](https://uofs-comphyd.github.io/publications/)
Currently the criteria for inclusion are any of Clark's papers 2019-present (this needs to be revised).

### `bibtek2markdown_member.bash`
This script defines the publications on the team members page, e.g., for [Martyn Clark](https://uofs-comphyd.github.io/current_member/martyn_clark).
This script has much in common with the `bibtek2yaml_group.bash` script, violating the DRY coding principles ("Don't Repeat Yourself")
This script can be run using `bibtek2markdown_group.bash`, which simply loops through the members in the team.
