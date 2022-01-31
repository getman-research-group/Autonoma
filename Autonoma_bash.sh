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
log_G09_final="${foldername}.log"
log_G09_temp="${foldername}_tmp.log"
gjf_name="${gjf_file%.*}"
#echo $log_G09
#exit

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

# Define a timestamp function
function timestamp() {
    date +"%Y-%m-%d %H:%M:%S.%3N %zZ %Z" # current time
}
ini_timestamp=$(date +"%Y-%m-%d %H-%M-%S.%3N %zZ %Z") # time when script was started
log_Autonoma="$(pwd)/${gjf_name}_${ini_timestamp}.csv" # log file for Autonoma
log_DirClean="$(pwd)/${gjf_name}_${ini_timestamp}_DirClean.log" # log file for Directory Cleaner

# Define a current working directory function
function wrk_dir() {
    #pwd
    echo "${dir_GJF}"
    # printf '%s'
}

# Check if job is converged
function chk_converged() {
    echo "${converged}"
}

# Grab current G09 job ID
function chk_G09_job_ID() {
    echo "${curr_G09_ID}"
}

function script_info() {
    echo "$(chk_converged),$(wrk_dir),$(chk_G09_job_ID),Autonoma"
}

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
#DIR="${mainDIR}/TestDirectory"
DIR="${mainDIR}/${foldername}"

cleaner=$(qsub -v DIR="\"${DIR}\"",gjf_file="\"$gjf_file\"" DirectoryCleaner_qsub.sh) # run DirectoryCleaner job
#cleaner=$(qsub -v DIR="\"${DIR}\"",gjf_file="\"$gjf_file\"" -o "\"${log_DirClean}\"" -j oe DirectoryCleaner_qsub.sh) # run DirectoryCleaner job
sleep 1s
echo "$(script_info),INFO,Starting cleanup job ${cleaner}"
chk_num="${cleaner%.*}0"
#echo "Check #: $chk_num"

chkclean=$(qstat "${cleaner}" | sed 's/ .*//') # parses first word
#echo $(timestamp) "INFO: $chkclean"

if [ $chk_num -eq 0 ]; then
    echo "$(script_info),ERROR,Failed to detect qsub job. Script terminated."
    exit
fi

# Escape from while loop when it takes too long (>5 minutes)
j1=1
j2=0

# For checking if job is finished or if fluke network error occured 
j3=0
j4=0

#while [[ -n "${chkclean}" -a ! -z "${chkclean}" ]]; do # Wait for the cleaner job to finish
#while [ $chk_num -gt 0 ]
while [ $((j3+j4)) -ne 2 ]; do
    j3=1
    chkclean=$(qstat "${cleaner}" | sed 's/ .*//')

    while [ -n "${chkclean}" ]; do
        j3=0
        echo "$(script_info),INFO,Cleaner ${cleaner} running"
        if (( "$j1" == 1 )); then
            sleep 1s
            j1=0
            j2=$(( "$j2" + 1 ))
        else
            sleep 5s
            j2=$(( "$j2" + 5 ))
            if (( "$j2" >= 5*60 )); then
                echo "$(script_info),ERROR,Cleanup job ${cleaner} exceeded 5 minute runtime in ${DIR}. Script Terminated"
                exit
            fi
        fi
        chkclean=$(qstat "${cleaner}" | sed 's/ .*//')
    done

    echo "$(script_info),INFO,Cleaner ${cleaner} not detected as running. Confirming..."
    j4=$((j3));
    sleep 1m # Wait 5 minutes before confirming job is actually finished
    # This is to avoid the script thinking the job has finished when an error occurs connecting to
    # the server to perform the qstat request.
done

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
for i in {1..5}; do # Run loop up to 5 times
    #i_true=i_true+1 # Keeps track of how many times the loop is run.
    job=$(qsub G09-Sub-Multi.sh)
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

    # For having different time delay after first job check
    k1=1
    k2=0

    # For checking if job is finished or if fluke network error occured 
    k3=0
    k4=0
    while [ $((k3+k4)) -ne 2 ]; do
        k3=1
        chkjob=$(qstat "$job")
        
        while [ -n "$chkjob" ]; do # ADD escape from while loop when it takes too long
            k3=0
            if (( k1==1 )); then
                echo "$(script_info),INFO,Job $job running"
                sleep 5s
                k1=0
            else
                k2=$(("$k2" + 1))
                if (( k2==60 )); then #60  # Only log update every hour
                    k2=0
                    echo "$(script_info),INFO,Job $job running"
                fi
                sleep 1m
            fi
            chkjob=$(qstat "$job")
        done
        k4=$((k3));
        echo "$(script_info),INFO,Job $job detected as not running. Confirming..."
        sleep 1m # Wait 5 minutes before confirming job is actually finished
        # This is to avoid the script thinking the job has finished when an error occurs connecting to
        # the server to perform the qstat request.
    done

    sleep 1s
    echo "$(script_info),INFO,Job $job has completed"
    
    # Check for Gaussian Errors
    # Determine location of log file.
    log_G09=$log_G09_final
    if [ ! -f "$log_G09" ]; then # if non-temporary log file does not exist
        log_G09=$log_G09_temp # then use temporary log file

        if [ ! -f "$log_G09" ]; then # if temporary log file does not exist
            echo "$(script_info),ERROR,Log file was not be found. Script terminated." # report error
            exit # and stop the script
        fi
    fi

    conv_chk=$(tac "${log_G09}" | grep -m1 "Normal termination of Gaussian")
    if [ -n "${conv_chk}" ]; then
        echo "$(script_info),INFO,Checking for convergence"
        
        
        # tac prints input file in reverse format
        # https://www.educba.com/linux-tac/

        # pcregrep because grep doesn't support multiline parsing
        # returns all convergence checks

        # Why use pcregrep:
        # https://stackoverflow.com/questions/2686147/how-to-find-patterns-across-multiple-lines-using-grep

        # grep again to pull out specific lines
        # grep considers the most recent convergence check and isolated specific
        # checks within it (RMS Displacement, Maximum Displacement)

        # Grep returning only match:
        # https://serverfault.com/questions/51014/dont-need-the-whole-line-just-the-match-from-regular-expression

        # VERY HANDY TOOL:
        # https://www.regextester.com


        # Maximum Force Most Recent Info
        # First number is "Value"; Second number is "Threshold"
        Max_Force_info=$(tac "${log_G09}" | pcregrep -M '\n.*(?=Converged\?)' | grep -m1 'YES')

        # RMS Force Most Recent Info
        # First number is "Value"; Second number is "Threshold"
        RMS_Force_info=$(tac "${log_G09}" | pcregrep -M '\n.*\n.*(?=Converged\?)' | grep -m1 'YES')

        # Maximum Displacement Most Recent Info
        # First number is "Value"; Second number is "Threshold"
        Max_Disp_info=$(tac "${log_G09}" | pcregrep -M '\n.*\n.*\n.*(?=Converged\?)' | grep -m1 'YES')

        # RMS Displacement Most Recent Info
        # First number is "Value"; Second number is "Threshold"
        RMS_Disp_info=$(tac "${log_G09}" | pcregrep -M '\n.*\n.*\n.*\n.*(?=Converged\?)' | grep -m1 'YES')
        
        echo "$(script_info),INFO,${Max_Force_info}"
        echo "$(script_info),INFO,${RMS_Force_info}"
        echo "$(script_info),INFO,${Max_Disp_info}"
        echo "$(script_info),INFO,${RMS_Disp_info}"

        # Isolate numbers in info
        #RMS_Disp_num=$(tac "${log_G09}" | pcregrep -M '\n.*\n.*\n.*\n.*(?=Converged\?)' | grep -m1 'YES' | grep -oE '([0-9.]+%?)')
        #RMS_Disp_num=$(tac "${log_G09}" | pcregrep -M '\n.*\n.*\n.*\n.*(?=Converged\?)' | grep -m1 'YES' | grep -oE '([0-9.]+\b)')

        # for number in $RMS_Disp_num; do
        #     echo $number
        # done

        # Is most recent RMS Displacement check converged? (If so, returns "YES")
        # RMS_Disp_cvg=$(tac "${log_G09}" | pcregrep -M '\n.*\n.*\n.*\n.*(?=Converged\?)' | grep -om1 'YES')

        # Convert info to array of strings
        # Split strings where spaces occur
        # https://linuxhandbook.com/bash-split-string/
        IFS=' ' read -ra Max_Force_array <<< "$Max_Force_info"
        IFS=' ' read -ra RMS_Force_array <<< "$RMS_Force_info"
        IFS=' ' read -ra Max_Disp_array <<< "$Max_Disp_info"
        IFS=' ' read -ra RMS_Disp_array <<< "$RMS_Disp_info"
        
        # Max_Force_array=("$Max_Force_info")
        # RMS_Force_array=("$RMS_Force_info")
        # Max_Disp_array=("$Max_Disp_info")
        # RMS_Disp_array=("$RMS_Disp_info")

        # echo ${Max_Force_array}
        # echo ${RMS_Force_array}
        # echo ${Max_Disp_array}
        # echo ${RMS_Disp_array}


        #echo "$(script_info),INFO,RMS Disp ${RMS_Disp_array[0]}" # RMS or Maximum
        #echo "$(script_info),INFO,RMS Disp ${RMS_Disp_array[1]}" # Item (Force or Displacement)
        #echo "$(script_info),INFO,RMS Disp ${RMS_Disp_array[2]}" # Item Value
        #echo "$(script_info),INFO,RMS Disp ${RMS_Disp_array[3]}" # Convergence Threshold Value
        #echo "$(script_info),INFO,RMS Disp ${RMS_Disp_array[4]}" # Converged (Yes/No)

        # Set maximum thresholds. Script is to terminate if these values are exceeded.
        lim_Max_Force=10.01
        lim_RMS_Force=10.01
        lim_Max_Disp=10.01
        lim_RMS_Disp=10.01

        # Thresholds for near convergence. Script is allow rerunning 1 additional time if ALL values are near convergence.
        #near_Max_Force=0.01
        #near_RMS_Force=0.01
        #near_Max_Disp=0.01
        #near_RMS_Disp=0.01

        # Why 'bc' is used to perform numerical evaluations:
        # https://stackoverflow.com/questions/1786888/in-bash-shell-script-how-do-i-convert-a-string-to-an-number
        
        # Passing results from 'bc' to variable:
        # https://askubuntu.com/questions/229446/how-to-pass-results-of-bc-to-a-variable

        #echo "$(bc <<< "10 <= 1.00")"
        #if [ $(bc <<< "10 <= 1.00") -eq 1 ]; then
        #    echo "$(script_info),INFO,RMS Displacement Converged. 10 <= 1.00"
        #fi



        # Comparing strings:
        # https://linuxize.com/post/how-to-compare-strings-in-bash/
        #echo [ "${Max_Force_array[4]}" = "YES" ] [ "${RMS_Force_array[4]}" = "YES" ] [ "${Max_Disp_array[4]}" = "YES" ] [ "${RMS_Disp_array[4]}" = "YES" ]

        if [ "${Max_Force_array[4]}" = "YES" ] && [ "${RMS_Force_array[4]}" = "YES" ] && \
        [ "${Max_Disp_array[4]}" = "YES" ] && [ "${RMS_Disp_array[4]}" = "YES" ]; then
            converged="Yes" # Is the job converged
            echo "$(script_info),INFO,The job has converged"
            
            # Stop Autonoma
            echo "$(script_info),INFO,Script Shutting Down"
            exit
        fi    
        # Perform individual convergence checks
        echo "$(script_info),INFO,The job has not converged. Checking RMS and Max values of Force and Displacemnt."

        # Check if Maximum Force has converged
        if [ "${Max_Force_array[4]}" = "YES" ]; then
            echo "$(script_info),INFO,Maximum Force Converged. ${Max_Force_array[2]} <= ${Max_Force_array[3]}"
        else
            echo "$(script_info),INFO,Maximum Force NOT Converged. ${Max_Force_array[2]} > ${Max_Force_array[3]}"
            
            # Check if Maximum Force value is within allowed range. Terminate script if not.
            if [ $(bc <<< "${Max_Force_array[2]} <= ${lim_Max_Force}") -eq 1 ]; then
                echo "$(script_info),INFO,Maximum Force Within Allowed Range. ${Max_Force_array[2]} <= ${lim_Max_Force}"
            else
                echo "$(script_info),ERROR,Maximum Force Exceeds Allowed Range. Script terminated. ${Max_Force_array[2]} > ${lim_Max_Force}"
                exit
            fi
            # Check if Max Force is close to converging
            #if [ $(bc <<< "${Max_Force_array[2]} <= ${near_Max_Force}") -eq 1 ]; then
            #    echo "$(script_info),INFO,Maximum Force NOT Converged. ${Max_Force_array[2]} > ${near_Max_Force}"
            #fi
            
        fi

        # Check if RMS Force has converged
        if [ "${RMS_Force_array[4]}" = "YES" ]; then
            echo "$(script_info),INFO,RMS Force Converged. ${RMS_Force_array[2]} <= ${RMS_Force_array[3]}"
        else
            echo "$(script_info),INFO,RMS Force NOT Converged. ${RMS_Force_array[2]} > ${RMS_Force_array[3]}"
            
            # Check if RMS Force value is within allowed range. Terminate script if not.
            if [ $(bc <<< "${RMS_Force_array[2]} <= ${lim_RMS_Force}") -eq 1 ]; then
                echo "$(script_info),INFO,RMS Force Within Allowed Range. ${RMS_Force_array[2]} <= ${lim_RMS_Force}"
            else
                echo "$(script_info),ERROR,RMS Force Exceeds Allowed Range. Script terminated. ${RMS_Force_array[2]} > ${lim_RMS_Force}"
                exit
            fi
        fi

        # Check if Maximum Displacement has converged
        if [ "${Max_Disp_array[4]}" = "YES" ]; then
            echo "$(script_info),INFO,Maximum Displacement Converged. ${Max_Disp_array[2]} <= ${Max_Disp_array[3]}"
        else
            echo "$(script_info),INFO,Maximum Displacement NOT Converged. ${Max_Disp_array[2]} > ${Max_Disp_array[3]}"
            
            # Check if Maximum Displacement value is within allowed range. Terminate script if not.
            if [ $(bc <<< "${Max_Disp_array[2]} <= ${lim_Max_Disp}") -eq 1 ]; then
                echo "$(script_info),INFO,Maximum Displacement Within Allowed Range. ${Max_Disp_array[2]} <= ${lim_Max_Disp}"
            else
                echo "$(script_info),ERROR,Maximum Displacement Exceeds Allowed Range. Script terminated. ${Max_Disp_array[2]} > ${lim_Max_Disp}"
                exit
            fi
        fi

        # Check if RMS Displacement has converged
        if [ "${RMS_Disp_array[4]}" = "YES" ]; then
            echo "$(script_info),INFO,RMS Displacement Converged. ${RMS_Disp_array[2]} <= ${RMS_Disp_array[3]}"
        else
            echo "$(script_info),INFO,RMS Diaplcement NOT Converged. ${RMS_Disp_array[2]} > ${RMS_Disp_array[3]}"
            
            # Check if RMS Displacement value is within allowed range. Terminate script if not.
            if [ $(bc <<< "${RMS_Disp_array[2]} <= ${lim_RMS_Disp}") -eq 1 ]; then
                echo "$(script_info),INFO,RMS Displacement Within Allowed Range. ${RMS_Disp_array[2]} <= ${lim_RMS_Disp}"
            else
                echo "$(script_info),ERROR,RMS Displacement Exceeds Allowed Range. Script terminated. ${RMS_Disp_array[2]} > ${lim_RMS_Disp}"
                exit
            fi
        fi


        # OLD CONVERGENCE STUFF FROM SPRING 2021. MARKED FOR DELETION
        # Acceptable tolerance range from converged for convergence criteria
        # Max_Force_tol=1.0
        # RMS_Force_tol=1.0
        # Max_Disp_tol=1.0
        # RMS_Disp_tol=1.0

        # Distance from convergance for convergence criteria
        # a = {$Max_Force_array[3]}
        # b = {$Max_Force_array[2]}
        # Max_Force_diff=$(expr $a - $b)
        # RMS_Force_diff=1.0
        # Max_Disp_diff=1.0
        # RMS_Disp_diff=1.0

        # echo ${Max_Force_diff}

        # if [ "{Max_Force_array[3]}" = "$Max_Force_tol" ]; then
        #     echo "Max force outside criteria"
        # fi

        # 'Converged\?\n(.*)')
        #$(sed -En 'Converged\?\n\sMaximum\sForce            .*')
        #$(tac ${log_G09} | pcregrep -P '(?<=Converged\?\n).*') # '(?<=Input orientation).*')
        # (?<=Converged\?\n\sMaximum\sForce            ).* 
        

        # EXECUTE:
        # CHECK convergence criteria

        # If 4 yes's, display msg converged in status fine
    fi

    err_chk=$(tac "${log_G09}" | grep -m1 "Error termination via Lnk1e")
    if [ -n "${err_chk}" ]; then
        echo "$(script_info),INFO,Gaussian error termination. Looking for errors."
        unknown_error=1 # 0 mean no, 1 means yes
        ## CHECK for errors

        # ERROR 1: "Unrecognized atomic symbol"
        error1="Unrecognized atomic symbol"
        check1=$(tac "${log_G09}" | grep -m1 "$error1")
        if [ -n "${check1}" ]; then
            echo "$(script_info),ERROR,1: $error1"
            echo "$(script_info),ERROR Description,Syntax error for element name"
            echo "$(script_info),ERROR Action,Operator intervention required"
            
            # EXECUTE:
            # Send error message to MassJobs.sh status file 
            echo "$(script_info),ERROR,Script shutting down due to ERROR 1: $error1"
            exit
        fi

        # ERROR 2: "Unknown center"
        error2="Unknown center"
        check2=$(tac "${log_G09}" | grep -m1 "$error2")
        if [ -n "${check2}" ]; then
            echo "$(script_info),ERROR,2: $error2"
            echo "$(script_info),ERROR Description,Syntax error for element name"
            echo "$(script_info),ERROR Action,Operator intervention required"
            
            # EXECUTE:
            # Send error message to MassJobs.sh status file 
            echo "$(script_info),ERROR,Script shutting down due to ERROR 2: $error2"
            exit
        fi

        # ERROR 3: "No such file or directory"
        error3="No such file or directory"
        check3=$(tac "${log_G09}" | grep -m1 "$error3")
        if [ -n "${check3}" ]; then
            echo "$(script_info),ERROR,3: $error3"
            echo "$(script_info),ERROR Description,Can't open a file."
            echo "$(script_info),ERROR Action,Operator intervention required"
            
            # EXECUTE:
            # Send error message to MassJobs.sh status file
            echo "$(script_info),ERROR,Script shutting down due to ERROR 3: $error3"
            exit
        fi

        # ERROR 4: "Unknown center"
        error4="Warning: center 14 has no basis functions!"
        check4=$(tac "${log_G09}" | grep -m1 "$error4")
        if [ -n "${check4}" ]; then
            echo "$(script_info),ERROR,4: $error4"
            echo "$(script_info),ERROR Description,Check if the baisis set is correct"
            echo "$(script_info),ERROR Action,Operator intervention required"
            
            # EXECUTE:
            # Send error message to MassJobs.sh status file
            echo "$(script_info),ERROR,Script shutting down due to ERROR 4: $error4"
            exit
        fi

        # ERROR 5: "Error termination in NtrErr: NtrErr Called from FileIO."
        error5="Error termination in NtrErr: NtrErr Called from FileIO."
        check5=$(tac "${log_G09}" | grep -m1 "$error5")
        if [ -n "${check5}" ]; then
            echo "$(script_info),ERROR,5: $error5"
            echo "$(script_info),ERROR Description,The calculation has exceeded the maximum limit of maxcyc"
            echo "$(script_info),ERROR Action,No operator intervention, resubmit job from last converged geometry"
            unknown_error=0
            # EXECUTE:
            # Make note of error and proceed
        fi

        # ERROR 6: "Error termination in NtrErr: NtrErr Called from FileIO."
        error6="galloc: could not allocate memory."
        check6=$(tac "${log_G09}" | grep -m1 "$error6")
        if [ -n "${check6}" ]; then
            echo "$(script_info),ERROR,6: $error6"
            echo "$(script_info),ERROR Description,Not enough memory."
            echo "$(script_info),ERROR Action,Operator intervention and display the error in status file"
            
            # EXECUTE:
            # Send error message to MassJobs.sh status file
            echo "$(script_info),ERROR,Script shutting down due to ERROR 6: $error6"
            exit
        fi

        # ERROR 7: "Error termination in NtrErr: NtrErr Called from FileIO."
        error7="Error termination in NtrErr: ntran open failure returned to fopen. Segmentation fault"
        check7=$(tac "${log_G09}" | grep -m1 "$error7")
        if [ -n "${check7}" ]; then
            echo "$(script_info),ERROR,7: $error7"
            echo "$(script_info),ERROR Description,Can't open a file."
            echo "$(script_info),ERROR Action,Operator intervention and display the error in status file"
            
            # EXECUTE:
            # Send error message to MassJobs.sh status file 
            echo "$(script_info),ERROR,Script shutting down due to ERROR 7: $error7"
            exit
        fi

        # ERROR 8: "Error in internal coordinate system."
        error8="Error in internal coordinate system."
        check8=$(tac "${log_G09}" | grep -m1 "$error8")
        if [ -n "${check8}" ]; then
            echo "$(script_info),ERROR,8: $error8"
            echo "$(script_info),ERROR Description,The atom geometry is unable to converge"
            echo "$(script_info),ERROR Action,Look at the convergence criterias table and determine if the job is to be resubmitted"
            
            # EXECUTE:
            # Send error message to MassJobs.sh status file
            echo "$(script_info),ERROR,Script shutting down due to ERROR 8: $error8"
            exit
        fi

        if [ $unknown_error -eq 1 ]; then
            echo "$(script_info),ERROR,UNK: An unknown error an occured."
            echo "$(script_info),ERROR Description,An error not documented in Autonoma_bash.sh has occured."
            echo "$(script_info),ERROR Action,Operation action required."

            echo "$(script_info),ERROR,Script shutting down due to unknown ERROR."
            exit
        fi
    fi 
    
    echo "$(script_info),INFO,Starting rerun.sh"
    ./rerun.sh
    echo "$(script_info),INFO,rerun.sh has finished"

done

echo "$(script_info),INFO,Script shutting down"