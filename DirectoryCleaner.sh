#!/bin/bash
#
#PBS -N DirectoryCleaner
#PBS -l select=1:ncpus=1:mem=4gb:interconnect=1g,walltime=0:05:00
#PBS -l place=scatter
#PBS -j oe
#PBS -r n

# Mail Event
#PBS -M tdelvau@clemson.edu
#PBS -m n

# Define a timestamp function
timestamp() {
    date +"%Y-%m-%d %H:%M:%S.%3N" # current time
    }

file_name="DirectoryCleaner"

arrIN=(${gjf_file//// }) # arrIN=(${gjf_name//;/ }) third character is delimiter
arrFILE=(${arrIN[0]//./ }) # arrIN=(${gjf_name//;/ }) third character is delimiter
if (( len > 1 )); then
  folder="${arrIN[0]}/"
else
  folder=""
fi
#echo "$(timestamp) INFO: [$file_name] arrIN=${arrIN[0]}"
#echo "$(timestamp) INFO: [$file_name] arrFILE=${arrFILE[0]}"
# from: https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash

# $DIR comes from parent script
echo "$(timestamp) INFO: [$file_name] Script Initializing"
echo "$(timestamp) INFO: [$file_name] Target location is \"${DIR}\""
echo "$(timestamp) INFO: [$file_name] *.GJF file is \"${gjf_file}\""

if ! cd "$PBS_O_WORKDIR" ; then # Attempt to change the working directory; report error if failure occurs
    echo "$(timestamp) ERROR: [$file_name] Changing working directory to \"$DIR\" failed. Script Terminated"
    exit # Terminate the script
fi

# Directory for all files to be created in
if [ -d "${DIR}/${arrFILE[0]}" ]; then
    #rm -r $DIR
    echo "$(timestamp) INFO: [$file_name] Directory \"${DIR}${arrFILE[0]}\" Exists"
    # Add check if parent directory contains expected files
    echo "$(timestamp) INFO: [$file_name] Clearing Directory"
    rm -rfv "${DIR:?}/${arrFILE[0]:?}"/* # ':? added to prevent possiblity of deleting root directory.'
    # see https://github.com/koalaman/shellcheck/wiki/SC2115 for more info
    # ADD: Terminate script if removing files fails
    # CONSIDER: Renaming/moving existing directory instead of deleting it
else
    echo "$(timestamp) INFO: [$file_name] Creating Directory \"${DIR}${arrFILE[0]}\""
    mkdir -p "${DIR}/${arrFILE[0]}"
    # ADD: Terminate script is making directory fails
fi

echo "$(timestamp) INFO: [$file_name] Copying input files"

if [ -d "./Input/${arrIN[0]}" ]; then
    echo "$(timestamp) INFO: [$file_name] ./Input/${arrIN[0]} is a directory"
    cp -r "./Input/${arrIN[0]}" "${DIR}" # Attempt to Copy GJF As Folder
elif [ -f "./Input/${arrIN[0]}" ]; then
    echo "$(timestamp) INFO: [$file_name] ./Input/${arrIN[0]} is a file"
    cp -r "./Input/${arrIN[0]}" "${DIR}/${arrFILE[0]}" # Attempt to Copy GJF As Folder
else
    echo "$(timestamp) INFO: [$file_name] ./Input/${arrIN[0]} is not valid"
    exit
fi

#cp -r "./Input/${gjf_file%.*}" "${DIR}" # Attempt to Copy GJF As Folder
#cp -r "./Input/${arrIN[0]}" "${DIR}" # Attempt to Copy GJF As Folder
echo "$(timestamp) INFO: [$file_name] ./Input/${arrIN[0]}"

if [ "${task_type}" = "Gaussian" ]; then
    cp Gaussian_G09-Sub-Multi.sh Gaussian_rerun.sh "${DIR}/${arrFILE[0]}" # Copy specific script files needed
elif [ "${task_type}" = "VASP" ]; then
    cp VASP_subvaspc2.sh "${DIR}/${arrFILE[0]}" # Copy specific script files needed
fi

# NEED TO FIX: Need to copy from folder
cp -r ./Scripts "${DIR}/${arrFILE[0]}/Scripts"

echo "$(timestamp) INFO: [$file_name] Script Shutting Down"
