#!/bin/bash
#
# used to reformat pubs into the "Nijssen" format

# add new lines at the start of the text file
fileold=listPubs_MartynClarkSep2018.txt
filenew=listPubs_MartynClarkSep2018-newline.txt
sed s//\\\n/g $fileold > $filenew

# reverse the lines in the file
filerank=listPubs_MartynClarkSep2018-pubOrder.txt
#tail -r $filenew > $filerank

# add headings
echo "# articles_published - shown on the publications page"
echo "articles_published:"

# loop through lines in the file
while read ref; do

 # split the line at the first colon (before is the year and the authors)
 part1=${ref%%:*}
 part2=${ref#*:}

 # remove publication number
 cNum=${part1%%.*}
 cTemp=${part1#*.}

 # skip unwanted lines
 if [[ $cNum != "11" ]] && [[ $cNum != "34" ]] && [ "$ref" != "" ]; then

 # save the authors and the year of publication
 authors=${cTemp%,*}
 pubYear=${cTemp##*,}

 # save the title
 pubTitle=${part2%%.*}
 pubTitle=`echo $pubTitle | xargs`  # remove leading whitespace

 # save the journal information
 cTemp=${part2#*.}
 IFS=',' read -r -a cVec <<< "$cTemp"
 journal=${cVec[0]}

 # identify doi
 doi=unknown
 for i in "${cVec[@]}"; do
  if [[ $i == *"doi:"* ]]; then
   doi=${i##*:}
  fi
 done

 # check
 #echo "pub number = " $cNum
 #echo "ref     = " $ref      
 #echo "part1   = " $part1      
 #echo "part2   = " $part2      

 # print
 echo '  - title: "'$pubTitle'"'    
 echo '    authors: '$authors     
 echo '    year: ' $pubYear   
 echo '    journal: ' $journal   
 echo '    doi: ' $doi      
 #echo "--"       

 fi  # if testing

done <$filerank
