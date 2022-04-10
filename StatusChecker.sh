#!/bin/bash

# File Name
# file_name="${0##*/}"
# https://stackoverflow.com/questions/192319/how-do-i-know-the-script-file-name-in-a-bash-script

# File Path
# file_path="$(pwd)"

# Define a timestamp function
function timestamp() {
    date +"[%Y-%m-%d %H:%M:%S,%3N %zZ %Z]" # current time
    }
ini_timestamp=$(date +"%Y-%m-%d %H-%M-%S,%3N") # time when script was started
log_file="$(pwd)/MassJobs.csv" # log file for this script
status_csv="$(pwd)/Status.csv" # Status file for jobs running from this script

# Get first line of log file
# https://stackoverflow.com/questions/2439579/how-to-get-the-first-line-of-a-file-in-a-bash-script
read -r line < "${log_file}"
echo "${line}" > "${status_csv}"

if ! cd "$(pwd)/Input" ; then # Attempt to change the working directory; report error if failure occurs
    echo "$(timestamp) ERROR: Changing working directory to \"$(pwd)/Output\" failed. Script Terminated"
    exit # Terminate the script
fi

# Array of GJF files is the same folder as this script.
filetype="*.gjf"
mapfile -t array1 < <(find . -mindepth 1  -maxdepth 2 -type f -name "$filetype" -printf '%P\n')

if ! cd ".." ; then # Attempt to change the working directory; report error if failure occurs
    echo "$(timestamp) ERROR: Changing working directory failed. Script Terminated"
    exit # Terminate the script
fi

for gjf in "${array1[@]}"; do # gjf is the "filename.gjf"
        filename="${gjf%.*}" # filename is the "filename"
        # echo "${filename}"
        
        # tac prints input file in reverse format
        # https://www.educba.com/linux-tac/

        # CONSIDER: Using something other than tac since initial timestamp will be close to the beginning of the log file.
        #gjf_starttime=$(tac "${log_file}" | grep -m1 "\[${filename}\] \[Autonoma\] INFO: Start time recorded as" | pcregrep -o '(?=as).*' | grep -o '[0-9].*')
        #echo "${gjf_starttime}"

        # Get Most Recent status message
        status_msg=$(tac "${log_file}" | grep -m1 "${filename}")
        echo "${status_msg}" >> "${status_csv}"
        echo "$filename"

        # For accessing individual log files (if desired)
        # gjf_logfile="$(pwd)/${filename}_${gjf_starttime}.log"
        # text=$(tac "${gjf_logfile}")
        # echo "${text}"

        # firstString="I love Suzi and Marry"
        # secondString="Sara"
        # echo "${firstString/Suzi/$secondString}"



done