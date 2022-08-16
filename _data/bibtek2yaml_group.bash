#!/bin/bash
#
# used to reformat pubs into markdown format

# initialize the counter
i=0

# -----
# * read the references from bib-tex format and save in arrays...
# ---------------------------------------------------------------

# loop through members
for memberFile in ../_posts/members/*.markdown; do

 # get the group member
 memberName="$(basename $memberFile)"
 memberName=${memberName#*_}
 memberName=${memberName%%.*}
 echo Processing group member "$memberName"

 # define files
 bibtexFile=${memberName}Pubs.bib

 # skip member for testing
 #[ "${memberName}" != "arnal" ] && continue

 # skip member if the .bib file does not exist
 [ ! -f "${bibtexFile}" ] && continue

 # get the start date of the employee
 memberFile=`ls ../_posts/members/*${member}.markdown`
 memberFile="$(basename $memberFile)"
 memberYear=`echo ${memberFile%%-*}`

 # loop through lines in the file
 while read ref; do

  # get the field
  IFS='{' read -r -a cVec <<< "${ref}"
  key=${cVec[0]}
  value=${cVec[1]}
  newline=$'\n'
  
  # save article ID
  if [[ ${key} == "@article" ]]; then

   # define valid reference and increment index
   valid=true
   i=$((i+1))

   # get the reference identifiers
   tmp=unknown
   IFS='_' read -r -a id <<< "${value%,*}"  # note "${value%,*}" removes everything after the comma
   if [[ ${#id[@]} -eq "3" ]]; then tmp=${id[@]:0:3}; fi
   if [[ ${#id[@]} -eq "4" ]]; then tmp=${id[@]:1:3}; fi

   # merge the reference identifiers (used for sorting)
   var=`paste <(printf %s "${i}") <(printf '%s\n' "${tmp[*]}")`
   merged[i]=`echo "$var${newline}"`
   echo Reading reference ${merged[i]}

   # save the member's start date
   startDate[i]=$memberYear

   # initialize variables
   title[i]=unknown
   authors[i]=unknown
   year[i]=unknown
   journal[i]=unknown
   doi[i]=unknown
  
  # check that the type is article
  else
   if [[ ${key:0:1} == "@" ]];then valid=false; fi
  fi

  # process if line is valid
  if [[ ${valid} == "true" ]]; then

   # remove tabs from line
   line=`echo "${ref}" | sed "s/[\t]//g"`
  
   # separate key-value pairs
   key=${line%=*}      # everything before the "=" sign
   value=${line##*=}   # everything after the "=" sign
   value=`echo "${value}" | sed "s/[\}\{,]//g"`            # (remove extra curly braces and commas)
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
done  # looping through members

# -----
# * sort the data...
# ------------------

# define temporary file
mkdir -p temp
rm -f temp/*
websiteTemp=temp/refId.txt
websiteUniq=temp/refIdUniq.txt
websiteSort=temp/refIdSort.txt

# prepare file for sorting (include the doi to identify duplicates)
for i in ${!merged[@]}; do
 echo ${merged[i]} ${doi[i]} | sed 's/[[:space:]]\+/,/g' >> $websiteTemp
done

# remove duplicates
# NOTE: sort by the 5th field (doi) and save unique values
sort -t "," -k5 -u $websiteTemp | cut -d "," -f 1,2,3,4 > $websiteUniq

# sort the IDs
# NOTE: sort by the 4th field recursively (year) and then by the second field (author)
sort -t "," -k4r -k2 $websiteUniq > $websiteSort

# -----
# * write in the yaml format...
# -----------------------------

# start writing to file
websiteFile=pubs.yaml
exec 1>$websiteFile

# add headings
echo "# articles_published - shown on the publications page"
echo "articles_published:"

# loop through references
while read -r ref; do

 # get the sorted index for a given reference
 IFS=$',' read -r -a index <<< "${ref}"

 # deal with the special case of >10 authors
 maxAuthors=10  # maximum number of authors to list
 authorList="${author[${index[0]}]}"
 nAuthors=`echo "${authorList}" | sed 's/[^,]//g' | awk '{ print length; }'`
 if [[ "${nAuthors}" -gt "${maxAuthors}" ]]; then
  (( nOtherAuthors = ${nAuthors} - 1 ))
  authorList="${authorList%%,*} and ${nOtherAuthors} others"
 fi

 # remove quotes from title string
 fixedTitle=`echo "${title[${index[0]}]}" | tr -d '"'`

 # print in the yaml format
 if [[ "${year[${index[0]}]}" -ge "${startDate[${index[0]}]}" ]]; then
  echo '  - title: "'${fixedTitle}'"'
  echo '    authors: '${authorList}
  echo '    year: '${year[${index[0]}]}
  echo '    journal: '${journal[${index[0]}]}
  echo '    doi: '${doi[${index[0]}]}
 fi

done < "$websiteSort" # loop through references
