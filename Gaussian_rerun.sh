#!/bin/bash
#

/software/commercial/gaussian/g09/newzmat -bmodel -noround -nosymav -ichk h20.chk -ozmat

declare -i num
num=$(ls -l | grep ^d | grep 'run*' | wc -l)
num+=1

mkdir run$num

find . -maxdepth 1 -type f -not -iname "*.sh" -exec mv {} run$num \;

mv stable/* run$num/
rm -r stable/
mv freq/* run$num
rm -r freq

cp run$num/*.gjf .
rm *-p1.gjf
rm *-p2.gjf

if [ -f *_tmp.gjf ]; then 
	rm *_tmp.gjf
fi

CM=$( grep -v [a-zA-Z] *.gjf | sed '/^\s*$/d' | head -1 )
CM_com=$( grep -v [a-zA-Z] run$num/*.com | sed '/^\s*$/d' | head -1 )


#echo "Do you wish to remove/replace coordinates?"
# select ynr in "Yes" "No" "Replace"; do
#     case $ynr in
#         Yes ) sed -i "/$CM/,/\(@\|notatom\)/{//!d}"  *.gjf; break;;
#         No ) break;;
# 	Replace ) sed -i "/$CM/,/\(@\|notatom\)/{//!d}"  *.gjf; sed "0,/$CM_com/d" run$num/*.com  >> *.gjf; break;;
#     esac
# done
sleep 5s

sed -i "/$CM/,/\(@\|notatom\)/{//!d}"  *.gjf;
sed "0,/$CM_com/d" run$num/*.com  >> *.gjf;
#nano *.gjf
