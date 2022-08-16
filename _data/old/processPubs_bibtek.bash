#!/bin/bash
#
# used to reformat pubs into markdown format

bibtexFile=clarkPubs_part1.bib
websiteFile=../_posts/members/pubs/clarkPubs.markdown

# -----
# * read the references from bib-tex format and save in arrays...
# ---------------------------------------------------------------

# initialize the counter
i=0

# loop through lines in the file
while read ref; do

 # get the field
 IFS='{' read -r -a cVec <<< "${ref}"
 key=${cVec[0]}
 value=${cVec[1]}
 newline=$'\n'

 # save article ID
 if [[ ${key} == "@article" ]]; then
  i=$((i+1))
  IFS='_' read -r -a id <<< "${value%,*}"  # note "${value%,*}" removes everything after the comma
  var=`paste <(printf %s "${i}") <(printf '%s\n' "${id[*]}")`
  merged[i]=`echo "$var${newline}"`
  echo Reading reference ${merged[i]}

  # initialize variables
  title[i]=unknown
  authors[i]=unknown
  year[i]=unknown
  journal[i]=unknown
  doi[i]=unknown
 
 # save other variables
 else
   
  # remove tabs from line
  line=`echo "${ref}" | sed "s/[\t]//g"`
 
  # separate key-value pairs
  key=${line%=*}      # everything before the "=" sign
  value=${line##*=}   # everything after the "=" sign
  value=`echo "${value}" | sed "s/[\}\)\{\(,]//g"`        # (remove extra curly braces and commas)
  value=`echo "${value}" | sed 's/^[ \t]*//;s/[ \t]*$//'` # (remove leading and trailing white space and tabs)

  # save information
  if [[ ${key} == "title " ]];   then title[i]=${value}; fi
  if [[ ${key} == "author " ]];  then author[i]=`echo "${value}" | sed "s/ and /, /g"`; fi
  if [[ ${key} == "year " ]];    then year[i]=${value}; fi
  if [[ ${key} == "doi " ]];     then doi[i]=${value}; fi

  # change case of the journal
  if [[ ${key} == "journal " ]]; then
   string=${value}
   name=`echo $value | tr [:upper:] [:lower:]`                           # convert to lower case
   name=`echo $name | sed 's/\<\([[:lower:]]\)\([[:alnum:]]*\)/\u\1\2/g'` # convert first letter of each word to upper case
   name=`echo $name | sed 's/ Of / of /g' | sed 's/ And / and /g' | sed 's/ The / the /g' | sed 's/ In / in /g' | sed 's/: /-/g'` 
   journal[i]=$name
  fi # changing the case of the journal

 fi  # if saving other variables
 
done <$bibtexFile

# -----
# * sort the data and write in the Nijssen format...
# --------------------------------------------------

# sort the IDs
IFS=$'\n' sortedIds=($(sort -k4r -k2 <<<"${merged[*]}"))
unset IFS

# start writing to file
exec 1>$websiteFile

# add headings
echo "# articles_published - shown on the publications page"
echo "articles_published:"

# loop through references
for id in "${sortedIds[@]}"; do

 # get the sorted index for a given reference
 IFS=$'\t' read -r -a index <<< "${id}"

 # print in the Nijssen format
 echo '  - title: "'${title[${index[0]}]}'"'
 echo '    authors: '${author[${index[0]}]}
 echo '    year: '${year[${index[0]}]}
 echo '    journal: '${journal[${index[0]}]}
 echo '    doi: '${doi[${index[0]}]}

done # loop through references
