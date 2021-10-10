#!/usr/local/bin/bash
#
# used to reformat pubs into markdown format

# get the command line arguments
args=("$@")
if [[ "${#args[@]}" -ne "1" ]]; then
 echo "Expect a single command line argument with (the team member's name)"
 exit 1
fi

# define the group member
member=${args[0]}

# define cases
cases=(Pubs Code Data)

# loop through cases
for case in "${cases[@]}"; do

 # define the website file
 websiteFile=../_posts/members/pubs/${member}${case}.markdown
 echo $websiteFile

 # get the bibtex file
 bibtexFile=${member}${case}.bib
 if [ ! -f "$bibtexFile" ]; then
  echo "The bibtex file $bibtexFile does not exist"
  continue
 fi

 # -----
 # * read the references from bib-tex format and save in arrays...
 # ---------------------------------------------------------------

 # initialize the counter
 i=0
 merged=()

 # loop through lines in the file
 while read ref; do

  # get the field
 
  IFS='{' read -r key value <<< "${ref}"
  newline=$'\n'

  # save article ID
  if [[ ${key} == "@article" || ${key} == "@incollection" || ${key} == "@misc" || ${key} == "@phdthesis" || ${key} == "@mastersthesis" ]]; then

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

   # change case of the title
   # NOTE: does not handle acronymns and place names well
   #  if [[ ${key} == "title " ]]; then
   #   string=${value}
   #   name=`echo $value | tr [:upper:] [:lower:]`    # convert to lower case
   #   name=`echo $name | sed 's/esm-snowmip/ESM-SNOWMIP/g'`
   #   title[i]=`echo ${name^}`                       # convert first letter of the title to upper case
   #  fi # changing the case of the title

   # change case of the journal
   if [[ ${key} == "journal " ]]; then
    string=${value}
    name=`echo $value | tr [:upper:] [:lower:]`                            # convert to lower case
    name=`echo $name | sed 's/\<\([[:lower:]]\)\([[:alnum:]]*\)/\u\1\2/g'` # convert first letter of each word to upper case
    name=`echo $name | sed 's/ Of / of /g' | sed 's/ And / and /g' | sed 's/ The / the /g' | sed 's/ In / in /g' | sed 's/: /-/g'` 
    name=`echo $name | sed 's/'\''S/'\''s/g'`
	journal[i]=$name
   fi # changing the case of the journal
  
  fi  # if saving other variables
 
 done <$bibtexFile

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
 # * write in the markdown format...
 # ---------------------------------

 # start writing to file
 rm -f $websiteFile
 exec 3>&1  # Duplicate stdout to file descriptor 3
 exec 1> $websiteFile

 # loop through references
 while read -r ref; do

  # get the sorted index for a given reference
  IFS=$',' read -r -a index <<< "${ref}"
  
  # deal with the special case of >10 authors
  maxAuthors=20  # maximum number of authors to list
  authorList="${author[${index[0]}]}"
  nAuthors=`echo "${authorList}" | sed 's/[^,]//g' | awk '{ print length; }'`
  if [[ "${nAuthors}" -gt "${maxAuthors}" ]]; then
   (( nOtherAuthors = ${nAuthors} - 1 ))
   authorList="${authorList%%,*} and ${nOtherAuthors} others"
  fi
  
  # allow missing journal for code and data
  if [[ "${case}" == "Code" || "${case}" == "Data" ]];then
   journalName=
  else
   journalName="_${journal[${index[0]}]}_,"  # Note, journal name is in italics
  fi

  # format the reference
  ref="${authorList}, ${year[${index[0]}]}: ${title[${index[0]}]}. ${journalName} "

  # currently still list papers even if the doi is unknown
  if [[ ${doi[${index[0]}]} != "unknown" ]]; then
   doi="[doi: ${doi[${index[0]}]}](http://doi.org/${doi[${index[0]}]})"
  else
   doi="doi: unknown"
  fi

  # print in the markdown format
  #if [[ ${journal[${index[0]}]} != "unknown" && ${doi[${index[0]}]} != "unknown" ]]; then
  if [[ ${journal[${index[0]}]} != "unknown" || "${case}" == "Code" || "${case}" == "Data" ]]; then
   printf '%s\n\n' "${ref}${doi}"
  fi

 done < "$websiteSort" # loop through references 

 # close file descriptor
 exec 1>&3  # Duplicate file descriptor 3 to stdout
 exec 3>&-  # Close file descriptor 3 (free the resources)
 
done # loop through cases
exit 0
