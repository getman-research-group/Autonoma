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
if [ -d "${DIR}" ]; then
    #rm -r $DIR
    echo "$(timestamp) INFO: [$file_name] Directory \"${DIR}\" Exists"
    # Add check if parent directory contains expected files
    echo "$(timestamp) INFO: [$file_name] Clearing Directory"
    rm -rfv "${DIR}"/*
    # ADD: Terminate script if removing files fails
    # CONSIDER: Renaming/moving existing directory instead of deleting it
else
    echo "$(timestamp) INFO: [$file_name] Creating Directory \"${DIR}\""
    mkdir -p "${DIR}"
    # ADD: Terminate script is making directory fails
fi

# NEED TO: Make gjf file generic
echo "$(timestamp) INFO: [$file_name] Copying input files"
cp G09-Sub-Multi.sh "${gjf_file}" rerun.sh "${DIR}"
cp -r ./Scripts "${DIR}/Scripts"
#cp G09-Sub-Multi.sh mo7s12_h2s12-u1.gjf rerun.sh ${DIR}

echo "$(timestamp) INFO: [$file_name] Script Shutting Down"