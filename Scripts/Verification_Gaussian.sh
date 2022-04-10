#!/bin/bash

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