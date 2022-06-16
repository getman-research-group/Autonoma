#!/bin/bash

# Check for VASP Errors

#vaspgeom
vaspgeom_output=$(vaspgeom 2>&1)
echo "${vaspgeom_output}"

#Error1: Cant open input file

random_var1=$(echo "${vaspgeom_output}" | grep -o "Can't open input file")

var_run=0
output_check="Can't open input file"

if [ "${random_var1}" = "${output_check}" ] 
then
  echo "$(script_info),INFO,Structure NOT Converged"
      walltime=$(tac "c2.0${JOBID}" | grep -o "exceeded limit")
      echo "${walltime}"
      if [ "$walltime" == "exceeded limit" ]; then
            cd "$(head -n 1 zb-TO-SCRATCH.dir)"
            cp CONTCAR "${cwd}"
            cd "${cwd}"
            cp -n "POSCAR" "POSCAR_Old"
            mv "CONTCAR" "POSCAR"
      fi   
else
      echo "$(script_info),ERROR,Input files are incorrect"
fi
var_run=1

#Error 3: single point check

random_var3=$(echo "${vaspgeom_output}" | grep -o "STRUCTURAL RELAXATION UNCONVERGED IN 1 STEPS")
output_check_2="STRUCTURAL RELAXATION UNCONVERGED IN 1 STEPS"

if [ "${random_var3}" == "${output_check_2}" ] 
then
#NSW=$(tac "INCAR" | grep - "NSW")
  vaspput=$(cat INCAR)
  NSW=`echo $vaspput | sed 's/.*NSW = //; s/ .*//' `
  #echo "$NSW"
  Var_run=0
  #echo $var
  if [ "$NSW" = "$var" ]; then
    echo "$(script_info),INFO,single point calculation"
  else
    echo "$(script_info),INFO,JOB converged in 1 ionic step"
  fi
fi

#Error 2: Structure unconverged

random_var2=$(echo "${vaspgeom_output}" | grep -o "STRUCTURAL RELAXATION UNCONVERGED IN 0 STEPS")

if [ "random_var2=$(echo "${vaspgeom_output}" | grep -o "STRUCTURAL RELAXATION UNCONVERGED IN 0 STEPS")" ]
then
#echo "$random_var2"
echo "$(script_info),INFO,Structure NOT Converged"      
  error=$(tac "c2.o4787296" | grep -o -m1 "BAD TERMINATION OF ONE OF YOUR APPLICATION PROCESSES")
  #echo $error
  if [ "$error" == "BAD TERMINATION OF ONE OF YOUR APPLICATION PROCESSES" ]
  then
    echo "$(script_info),ERROR,BAD TERMINATION; MISSING INPUT VALUES"
  else
    bterm=$(tac "c2.o4787296" | grep -m1 "Error" -C 3)     
    echo "$(script_info),ERROR,$bterm"
  fi
fi

#Error 4: Entropy Presence

TS=$(echo "${vaspgeom_output}" | sed 's/.*T*S://; s/E(sg->0).*//')
if [ $(bc <<< "${TS} == 0.000") -eq 1 ]
then
  echo "$(script_info),INFO,Entropy error"
fi              

#Error 5: Electronic Energy error
     
E=$(echo "${vaspgeom_output}" | sed 's/.*E(sg->0)://; s/eV.*//')
echo "$(script_info),INFO,E=${E}"
if [ $(bc <<< "${E} > 0.000") -eq 1 ]; then
      echo "$(script_info),ERROR,Elec. Energy is positive"
      exit
fi              

#Error 6: Max grad error

MG=$(echo "${vaspgeom_output}" | sed 's/.*Max Grad: //; s/ .*//')
echo "$(script_info),INFO,MG=${MG}"
if [ $(bc <<< "${MG} > 0.05") -eq 1 ]; then
      echo "$(script_info),ERROR,Max Grad is High"
      exit
fi              

if (( var_run > 0 )); then
      echo "$(script_info),INFO,Structure Converged"
      exit
fi
