#!/bin/bash

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