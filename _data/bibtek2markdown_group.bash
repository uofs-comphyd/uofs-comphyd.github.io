#!/bin/bash
#
# used to loop through group members to reformat pubs into markdown format

team=(gharari knoben clark)
for member in "${team[@]}"; do
 echo -----
 echo Processing publications for "$member"
 ./bibtek2markdown_member.bash "$member"
done

exit 1
