#!/bin/bash

# File Name
# file_name="${0##*/}"
# https://stackoverflow.com/questions/192319/how-do-i-know-the-script-file-name-in-a-bash-script

# File Path
# file_path="$(pwd)"

# Import variables from parent script
foldername=$1 # folder to peform calculations in
gjf_file=$2 # gjf file name
#echo $1 $2

gjf_name="${gjf_file%.*}" # gjf without file extension but including subfolder. e.g. h2o/h2o
arrIN=(${gjf_name//// }) # arrIN=(${gjf_name//;/ }) third character is delimiter
# from: https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
len=${#arrIN[@]}
gjf_only="${arrIN[-1]}"
if (( len > 1 )); then
  folder="${arrIN}/"
else
  folder=""
fi
# echo "${gjf_name}"
# echo "${gjf_only}"
# echo "${arrIN[-1]}"
# echo "${folder}"
# echo "${len}"

# Set directory containing other scripts (log file will also be stored here)
mainDIR="$(pwd)"
#mainDIR="$(pwd)" #"/zfs/curium/tdelvau/sample_calculation/water/"
#cd $mainDIR

# Variables specifially used for generating log messages
converged="No" # Is the job converged
curr_G09_ID="N/A" # Current G09 Job ID

dir_GJF=$(pwd) # Set current working directory
                # Needs to be done every time the script uses "cd"
                # (change directory).

# Import functions from the functions script.
. ./Scripts/Functions.sh # runs the code in this instance of bash
    # https://linoxide.com/make-bash-script-executable-using-chmod/

ini_timestamp=$(date +"%Y-%m-%d %H-%M-%S.%3N %zZ %Z") # time when script was started
log_Autonoma="$(pwd)/Output/${foldername}_${ini_timestamp}.csv" # log file for Autonoma
log_DirClean="$(pwd)/Output/${foldername}_${ini_timestamp}_DirClean.log" # log file for Directory Cleaner

# # exit when any command fails
# set -e
# # keep track of the last executed command
# trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# # echo an error message before exiting
# trap 'echo "$(timestamp) ERROR,\"${last_command}\" command filed with exit code $?."' EXIT

# Reading material:
# https://intoli.com/blog/exit-on-errors-in-bash-scripts/


# Saves log file of all messages and errors to same directory as script
# Also reports bash errors to terminal
# overwrites log file if existing

#export # Used for helping subprocesses see variables
#export -f wrk_dir # Used for helping subprocesses see functions
# Reference:
# https://stackoverflow.com/questions/13093709/how-to-use-shell-variables-in-perl-command-call-in-a-bash-shell-script

# Add header to log file
echo "TIMESTAMP,ASSOCIATED GJF,CONVERGED,CURRENT WORKING DIRECTORY,CURRENT G09 JOB ID,SCRIPT RESPONSIBLE,MSG TYPE,MESSAGE" > "${log_Autonoma}"

echo "$(script_info),INFO,Script Initializing" > >(while IFS= read -r line;
            do printf '%s,%s,%s\n' "$(timestamp)" "$gjf_name" "$line";
            done >> "$log_Autonoma")
            # do printf '%s,%s,%s,%s,%s,Autonoma,%s\n' "$(timestamp)" "$gjf_name" "$(chk_converged)" "$(wrk_dir)" "$(chk_G09_job_ID)" "$line";

# Appends log file with system messages (including system and code execution errors) and sends them to parent script
#exec 2> >(tee -a -i "$log_Autonoma")
# Used for converting " to "" (prevents issues with "s breaking a string)
# https://unix.stackexchange.com/questions/537823/bash-replace-single-quote-by-two-quotes-in-string
exec 2> >(pattern="\"";
            replacement="\"\"";
            while IFS= read -r line;
            # Due to an issue with subshells, not all variables from the parent shell
            # are updated when a subshell is invoked, causing subshells to only report the
            # initial value for many variables. Since "Converged", "Working Directory", and
            # "G09 Job ID" change as the script runs, they cannot be reported using this method
            # for system messages. Pre-defined script messages supply them instead.

            do printf '%s,%s,%s,%s,%s,Autonoma,SYSTEM,%s\n' "$(timestamp)" "$gjf_name" "Unknown" "Unknown" "Unknown" "\"${line//$pattern/$replacement}\"";
            # do printf '%s,%s,%s,%s,%s,Autonoma,SYSTEM,%s\n' "$(timestamp)" "$gjf_name" "$(chk_converged)" "$(wrk_dir)" "$(chk_G09_job_ID)" "\"${line//$pattern/$replacement}\"";
            done > >(tee -a -i "${log_Autonoma}"))
# print strftime "\"[%Y-%m-%d %H:%M:%S,$ms %zZ %Z]\" ", localtime($s)' >> >(tee -a -i "$log_Autonoma")) 

# appends log file with log messages
#exec >> >(tee -a -i "$log_Autonoma") #"$log_Autonoma"
exec >> >(while IFS= read -r line;
            do printf '%s,%s,%s\n' "$(timestamp)" "$gjf_name" "$line";
            # do printf '%s,%s,%s,%s,%s,Autonoma,%s\n' "$(timestamp)" "$gjf_name" "$(chk_converged)" "$(wrk_dir)" "$(chk_G09_job_ID)" "$line";
            done > >(tee -a -i "${log_Autonoma}"))
# print strftime "\"[%Y-%m-%d %H:%M:%S,$ms %zZ %Z]\" ", localtime($s)' >> "$log_Autonoma")

# Basically, the timestamp prefix and other relevant info is added to the output using a small shell script. The shell script's output is then saved to the log file.

# Useful links and reading:
# https://unix.stackexchange.com/questions/26728/prepending-a-timestamp-to-each-line-of-output-from-a-command
# https://unix.stackexchange.com/questions/550979/log-entirety-of-bash-script-and-prepend-timestamp-to-each-line
# https://stackoverflow.com/questions/49507429/prefix-for-command-output

#echo "$(script_info),INFO: Start date is" $(date +"%A, %B %d, %Y") "at" $(date +"%I:%M:%S %p")

# Saves log file of all messages and errors
# Also reports all messages and errors to terminal
#exec > >(tee "$(pwd)/Autonoma.log") 2>&1

# Stack Exchange posts of interest on redirecting commands
# https://unix.stackexchange.com/questions/61931/redirect-all-subsequent-commands-stderr-using-exec
# https://unix.stackexchange.com/questions/424652/capture-all-the-output-of-a-script-to-a-file-from-the-script-itself

#ScriptInfo="$(chk_converged),$(wrk_dir),$(chk_G09_job_ID),Autonoma"

echo "$(script_info),WARNING,\"Messages may occur out of sequential order\""
echo "$(script_info),INFO,Start time recorded as ${ini_timestamp}"
echo "$(script_info),INFO,\"Running Scripts in ${mainDIR}\""
echo "$(script_info),INFO,Directory Cleaner log file: ${log_DirClean}"

# Define directory to clean and run new scripts in
DIR="${mainDIR}/Output/"

cleaner=$(qsub -v DIR="\"${DIR}\"",gjf_file="\"$gjf_file\"" DirectoryCleaner.sh) # run DirectoryCleaner job

DIR="${mainDIR}/Output/${folder}"

#cleaner=$(qsub -v DIR="\"${DIR}\"",gjf_file="\"$gjf_file\"" -o "\"${log_DirClean}\"" -j oe DirectoryCleaner.sh) # run DirectoryCleaner job

# The cleanup job creates a new directory based on the input file name
# If the directory exists, it removes all files and folders from it first
# Once the directory is made or cleaned, any files needed to run the job
# (specified in the DirectoryCleaner.sh script) will be copied over.

sleep 1s
echo "$(script_info),INFO,Starting cleanup job ${cleaner}"
chk_num="${cleaner%.*}0"
#echo "Check #: $chk_num"

chkclean=$(qstat "${cleaner}" | sed 's/ .*//') # parses first word
echo $(timestamp) "INFO: $chkclean"

### UNCOMMENT
if [ $chk_num -eq 0 ]; then
    echo "$(script_info),ERROR,Failed to detect qsub job. Script terminated."
    exit
fi

# === Check the status of the cleanup job ===
cleaner_checker # Run the cleaner_checker function
# (this function is in ./Scripts/Functions.sh)
# Reading material: https://stackoverflow.com/questions/8818119/how-can-i-run-a-function-from-a-script-in-command-line

sleep 1s

if [ ! -d "${DIR}" ]; then # Check if directory does not exist
    echo "$(script_info),ERROR,Cleanup job ${cleaner} failed to create directory ${DIR}. Script Terminated"
    exit
fi
echo "$(script_info),INFO,Cleanup job ${cleaner} has completed"

# On sending command-line arguments
# https://stackoverflow.com/questions/26487658/does-qsub-pass-command-line-arguments-to-my-script

if ! cd "${DIR}" ; then # Try to change working directory; report error if this fails
    echo "$(script_info),ERROR,Changing working directory to ${DIR} failed. Script Terminated"
    exit
fi
dir_GJF=$(pwd) # Set current working directory
echo "$(script_info),INFO,Working Directory Changed"

#vaspgeom
#vaspgeom_output=$(vaspgeom)
#echo "$(script_info),INFO,${vaspgeom_output}"

#echo "$(script_info),INFO,$(pwd)"
#echo "$(script_info),INFO,$(wrk_dir)"
# https://linuxize.com/post/bash-while-loop/
# https://linuxize.com/post/bash-for-loop/
# https://www.garron.me/en/go2linux/bash-for-loop-break-continue-sintax.html

# IMPORTANT
# check what happens if G09 completes and everything gets run again
# does error occur?

#for i in {1..5}; do # Run loop up to 5 times
#i_true=0
for i in {1..2}; do # Run loop up to 5 times
    #i_true=i_true+1 # Keeps track of how many times the loop is run.
    job=$(qsub subvaspc2.sh)
    echo "$(script_info),INFO,Gaussian Calculation Run $i "
    echo "$(script_info),INFO,Starting job $job"
    sleep 1s
    chkjob=$(qstat "${job}" | sed 's/ .*//') # parses first word
    # NEED to check for unknown job id error
    #echo $(timestamp) "INFO,$chkjob"

    chkjob_num="${job%.*}0"
    if [ $chkjob_num -eq 0 ]; then
        echo "$(script_info),ERROR,Failed to detect qsub job. Script terminated."
        exit
    fi
    curr_G09_ID="$job" # Update current G09 Job ID
    arr_JOBID=(${curr_G09_ID//./ }) # arrIN=(${gjf_name//;/ }) third character is delimiter
    JOBID=${arr_JOBID[1]}
    

    # === Run the job ===
    job_checker # Run the job_checker function
    # (this function is in ./Scripts/Functions.sh)
    # Reading material: https://stackoverflow.com/questions/8818119/how-can-i-run-a-function-from-a-script-in-command-line

    sleep 1s
    echo "$(script_info),INFO,Job $job has completed"
    
    . ./Scripts/Verification.sh # runs the code in this instance of bash
    # https://linoxide.com/make-bash-script-executable-using-chmod/

done

echo "$(script_info),INFO,Script shutting down"