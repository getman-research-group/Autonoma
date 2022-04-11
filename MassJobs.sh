#!/bin/bash

# File Name
# file_name="${0##*/}"
# https://stackoverflow.com/questions/192319/how-do-i-know-the-script-file-name-in-a-bash-script

# File Path
# file_path="$(pwd)"

# Import functions from the functions script.
. ./Scripts/Functions.sh # runs the code in this instance of bash
    # https://linoxide.com/make-bash-script-executable-using-chmod/
    
# Import user-controlled variables functions from the UserVariables script.
. ./Scripts/UserVariables.sh # runs the code in this instance of bash

ini_timestamp=$(date +"%Y-%m-%d %H-%M-%S.%3N %zZ %Z") # time when script was started
log_file="$(pwd)/MassJobs.csv" # log file for this script
#status_csv="$(pwd)/MassJobs.csv" # Status file for jobs running from this script
dir_file="$(pwd)"

# Saves log file of all messages and errors to same directory as script
# Also reports bash errors to terminal
# overwrites log file if existing
echo "TIMESTAMP,ASSOCIATED GJF,CONVERGED,CURRENT WORKING DIRECTORY,CURRENT HPC JOB ID,SCRIPT RESPONSIBLE,MSG TYPE,MESSAGE" > "$log_file"

# appends log file with error messages
#exec 2> >(tee -a -i "$log_file")
exec 2> >(pattern="\"";
    replacement="\"\"";
    while IFS= read -r line;
    do printf '%s,N/A,N/A,%s,N/A,MassJobs,SYSTEM,%s\n' "$(timestamp)" "$(pwd)" "\"${line//$pattern/$replacement}\"";
    done >> >(tee -a -i "$log_file"))

# Useful links and reading:
# https://unix.stackexchange.com/questions/26728/prepending-a-timestamp-to-each-line-of-output-from-a-command
# https://unix.stackexchange.com/questions/550979/log-entirety-of-bash-script-and-prepend-timestamp-to-each-line
# https://stackoverflow.com/questions/49507429/prefix-for-command-output

# appends log file with log messages
exec >> "$log_file"

echo "INFO,Script Initializing" > >(while IFS= read -r line;
    do printf '%s,N/A,N/A,%s,N/A,MassJobs,%s\n' "$(timestamp)" "$dir_file" "${line}";
    done >> "$log_file")
#echo "INFO,\"Start date is" $(date +"%A, %B %d, %Y") "at" $(date +"%I:%M:%S %p")"\""


# ==== IMPORTANT READ ====
# use if this script crashes while parallel processes are running. helpful for terminating those processes
# https://askubuntu.com/questions/1033866/how-to-stop-a-bash-while-loop-running-in-the-background
# ps fjx
# kill PID


if ! cd "$(pwd)/Input" ; then # Attempt to change the working directory; report error if failure occurs
    echo "ERROR,Changing working directory to \"$(pwd)/Input\" failed. Script Terminated" > >(while IFS= read -r line;
        do printf '%s,N/A,N/A,%s,N/A,MassJobs,%s\n' "$(timestamp)" "$dir_file" "${line}";
        done >> "$log_file")
    exit # Terminate the script
fi


# Check filetype to look for based on user assigned task type
if [ "${task_type}" = "Gaussian" ]; then
    filetype="*.gjf"
elif [ "${task_type}" = "VASP" ]; then
    filetype="INCAR"
else
    echo "ERROR,\"${task_type}\" is not a valid task type" >> >(while IFS= read -r line;
        do printf '%s,N/A,N/A,%s,N/A,MassJobs,%s\n' "$(timestamp)" "$dir_file" "${line}";
        done >> "$log_file")
    exit # Terminate the script
fi

echo "INFO,Task Type Identified: \"${task_type}\"" > >(while IFS= read -r line;
    do printf '%s,N/A,N/A,%s,N/A,MassJobs,%s\n' "$(timestamp)" "$dir_file" "${line}";
    done >> "$log_file")

# Array of GJF files is the same folder as this script.
mapfile -t array1 < <(find . -mindepth 1  -maxdepth 2 -type f -name "$filetype" -printf '%P\n')

if ! cd ".." ; then # Attempt to change the working directory; report error if failure occurs
    echo "ERROR,Changing working directory failed. Script Terminated" > >(while IFS= read -r line;
        do printf '%s,N/A,N/A,%s,N/A,MassJobs,%s\n' "$(timestamp)" "$dir_file" "${line}";
        done >> "$log_file")
    exit # Terminate the script
fi

for gjf in "${array1[@]}"; do # gjf is the "filename.gjf"
    #echo "$gjf"
    name="${gjf%.*}" # filename is the "filename"
    name="${name%/*}"
    #echo "$name"

    # Uses the folder name for the input scripts if located in a subfolder.
    # Uses the file name for the input scripts if they are not in a subfolder.
    
    #echo "filename: $filename, e: $e" # uncomment to see behavior
    
    ./Autonoma.sh "${name}" "${gjf}" &
    
    sleep 2s # added so log filenames are not the same
done