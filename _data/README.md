# Scripts to process publications

This directory contains scripts to process publications. The scripts produce a `.yaml` file for group publications and a `.markdown` file for group member publications.

## Scripts

There are two main scripts:

### `bibtek2yaml_group.bash`
This script defines the publications on the [group publications page](https://uofs-comphyd.github.io/publications/)
Currently the criteria for inclusion are any of Clark's papers 2019-present (this needs to be revised).

### `bibtek2markdown_member.bash`
This script defines the publications on the team members page, e.g., for [Martyn Clark](https://uofs-comphyd.github.io/current_member/martyn_clark).
This script has much in common with the `bibtek2yaml_group.bash` script, violating the DRY coding principles ("Don't Repeat Yourself")
This script can be run using `bibtek2markdown_group.bash`, which simply loops through the members in the team.

The code expects that each team member will have a bibtex file named `${member}Pubs.bib`
Moreover, the code expects that the bibtex file is produced using zotero, such that the
*@article* tag is of the form `author_firstWordTitle_year` (this is used for sorting).

## Workflow

The workflow is as follows:
1. Put pubs in the online zotero group
1. Export pubs to a .bib file with the name `xxxxxPubs.bib` (here `xxxxx` is the family name of the group member, all in lower case). Put the .bib file in the `_data` directory in the website repo.
1. Run the script `bibtek2markdown_member.bash` in the `_data` directory. This script takes one command line argument which is the family name of the group member, in lower case. So to run for Martyn Clark you'd type `bibtek2markdown_member.bash clark`. There is also a script  `bibtek2markdown_group.bash` which simply loops through group members.
1. Put an include line in your bio to include the pubs markdown file. This should look like
```
### Publications
{% include_relative pubs/xxxxxPubs.markdown %}
```
where ### Publications is simply the heading for the publications.

You can extend this workflow to also use publications for code and data. Here you repeat steps 1-2 above, but creating files `xxxxxCode.bib` and `xxxxxData.bib`.
The extra lines in your bio file should then look like:
```
### Publications
{% include_relative pubs/xxxxxPubs.markdown %}

### Datasets
{% include_relative pubs/xxxxxData.markdown %}

### Code
{% include_relative pubs/xxxxxCode.markdown %}
```
