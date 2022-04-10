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
# from: https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash

# $DIR comes from parent script
echo "$(timestamp) INFO: [$file_name] Script Initializing"
echo "$(timestamp) INFO: [$file_name] Target location is \"${DIR}\""
echo "$(timestamp) INFO: [$file_name] *.GJF file is \"${gjf_file}\""

if ! cd "$PBS_O_WORKDIR" ; then # Attempt to change the working directory; report error if failure occurs
    echo "$(timestamp) ERROR: Changing working directory to \"$DIR\" failed. Script Terminated"
    exit # Terminate the script
fi


# Directory for all files to be created in
#DIR="$PBS_O_WORKDIR/TestDirectory/"
if [ -d "${DIR}/${arrIN[0]}" ]; then
    #rm -r $DIR
    echo "$(timestamp) INFO: [$file_name] Directory \"${DIR}/${arrIN[0]}\" Exists"
    # Add check if parent directory contains expected files
    echo "$(timestamp) INFO: [$file_name] Clearing Directory"
    rm -rfv "${DIR}/${arrIN[0]}"/*
    # ADD: Terminate script if removing files fails
    # CONSIDER: Renaming/moving existing directory instead of deleting it
else
    echo "$(timestamp) INFO: [$file_name] Creating Directory \"${DIR}/${arrIN[0]}\""
    mkdir -p "${DIR}/${arrIN[0]}"
    # ADD: Terminate script is making directory fails
fi

# NEED TO: Make gjf file generic
echo "$(timestamp) INFO: [$file_name] Copying input files"

#cp -r "./Input/${gjf_file%.*}" "${DIR}" # Attempt to Copy GJF As Folder
cp -r "./Input/${arrIN[0]}" "${DIR}" # Attempt to Copy GJF As Folder
echo "./Input/${arrIN[0]}"

echo "${DIR}"

cp subvaspc2.sh "${DIR}/${arrIN[0]}" # Copy specific script files needed
# NEED TO FIX: Need to copy from folder
cp -r ./Scripts "${DIR}/${arrIN[0]}/Scripts"

echo "$(timestamp) INFO: [$file_name] Script Shutting Down"