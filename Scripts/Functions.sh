#!/bin/bash

# Define a timestamp function
function timestamp() {
    date +"%Y-%m-%d %H:%M:%S.%3N %zZ %Z" # current time
}

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

# Single function to call in echo commands
# Will print covergence status, working directory, current job ID, and script being run
function script_info() {
    echo "$(chk_converged),$(wrk_dir),$(chk_G09_job_ID),Autonoma"
}

# Check the status of a cleaner job running on the cluster
function cleaner_checker() {
    # Escape from while loop when it takes too long (>5 minutes)
    j1=1
    j2=0

    # For checking if job is finished or if fluke network error occured 
    j3=0 
    j4=0

    #while [[ -n "${chkclean}" -a ! -z "${chkclean}" ]]; do # Wait for the cleaner job to finish
    #while [ $chk_num -gt 0 ]
    while [ $((j3+j4)) -ne 2 ]; do # while j3 + j4 does not equal 2
        j3=1
        chkclean=$(qstat "${cleaner}" | sed 's/ .*//') # check the status of the cleaner job

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
        sleep 10s #1m # Wait 5 minutes before confirming job is actually finished
        # This is to avoid the script thinking the job has finished when an error occurs connecting to
        # the server to perform the qstat request.
    done
}

# Check the status of a job running on the cluster
function job_checker() {
    # For having different time delay after first job check
    k1=1
    k2=0

    # For checking if job is finished or if a fluke network error occured 
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
        sleep 10s # 1m # Wait 5 minutes before confirming job is actually finished
        # This is to avoid the script thinking the job has finished when an error occurs connecting to
        # the server to perform the qstat request.
    done
}