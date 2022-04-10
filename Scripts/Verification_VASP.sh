#!/bin/bash

#echo "         Energy(eV)         MagMom         MaxGrad    Converged   "> summary2.dat

# Check for VASP Errors
# Determine location of log fil

#L=$(ls -d */)     #Extract a List of folders
#arr=($L)          #Convert to a list
#Llen=${#arr[@]}
#cwd=$(pwd)
#echo ${L}
#echo ${cwd}
#echo ${Llen}
#cd ${cwd}/${arr[j]}
#echo "Entered Level Zero "

vaspgeom
vaspgeom_output=$(vaspgeom)

#Error1: Cant open input file

var_run=0
if [ "${vaspgeom_output}" = "Can't open input file" ]; then
        echo "${L},Structure NOT Converged"
          cat c2.0${JOBID}
          walltime=${grep 'PBS: job killed' c2.0${JOBID}}
                if ["${tail -n 3 walltime}" = exceeded limit]; then
                  cd $(head -n 1 zb-TO-SCRATCH.dir)
                  cp CONTCAR ${cwd}
                  cd ${cwd}
                  cp -n "POSCAR" "POSCAR_Old"
                  cp "CONTCAR" "POSCAR"
                fi         
else
      echo "$(script_info),INFO,Input files are correct"
	var_run=1
fi


#Error 2: unconverged

if ["${vaspgeom_output}" = "STRUCTURAL RELAXATION UNCONVERGED IN 0 STEPS" ]; then
      NSW=${grep 'NSW' INCAR}}
          if ["${NSW}"=0]
          echo "$(script_info),INFO,single point calculation"
          exit
          fi   
else     
     BTERM=${grep 'BAD TERMINATION' c2.0${JOBID}}
           if ["${BTERM}"=BAD TERMINATION OF ONE OF YOUR APPLICATION PROCESSES]; 
           echo "$(script_info),ERROR,Error in JOB"
           exit
           fi
fi

#Error 3: Entropy Presence

TS=`echo $vaspgeom_output | sed 's/.*T*S://; s/E(sg->0).*//' `

if ["${TS}" == 0.000]; then
echo "${L},Entropy error"
exit
fi              


#Error 4: Electronic Energy error
     
E=$(echo $vaspgeom_output | sed 's/.*E(sg->0)://; s/eV.*//')
if ["${E}" > 0.000]; then
echo "$(script_info),ERROR,Elec. Energy is positive"
exit
fi              

#Error 5: Max grad error

MG=`echo $vaspgeom_output | sed 's/.*Max Grad: //; s/ .*//' `
if ["${MG}" > 0.05]; then
echo "$(script_info),ERROR,Elec. Energy is positive"
exit
fi              

if (( var_run > 0 )); then
	echo "$(script_info),INFO,Structure Converged"
	exit
fi

#Verification

grep 'reached required accuracy - stopping structural energy minimisation' c2.0${JOBID}


#TS=`echo $vaspgeom_output | sed 's/.*T*S://; s/E(sg->0).*//' `
#MM=`echo $vaspgeom_output | sed 's/.*MagMom://; s/Max Grad:.*//' `
#MG=`echo $vaspgeom_output | sed 's/.*Max Grad: //; s/ .*//' `
#CV=`echo $vaspgeom_output | sed 's/.*relaxation //; s/in .*//' `

  
              
echo "------------------------------------------------------END-----------------------------------------------------------------"