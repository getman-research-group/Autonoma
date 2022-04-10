#!/bin/bash
#PBS -N c2
#PBS -l select=1:ncpus=20:mpiprocs=20:mem=96gb:interconnect=fdr,walltime=72:00:00
#PBS -j oe
#PBS -m abe
#PBS -M vpunyap@g.clemson.edu

echo "START ---------------------"
qstat -xf $PBS_JOBID
echo "Start of Calculation"
module purge
module use /software/commercial/vasp/vasp_rg/modulefile
module load vasp.5.4.4
source /software/intel/bin/compilervars.sh -arch intel64 -platform linux
echo "Modules Loaded"
# Creating the VASP scratch directory
SCRATCH_DIR="/scratch1/$USER/VASP-${PBS_JOBID}"
mkdir -p ${SCRATCH_DIR}
echo ${SCRATCH_DIR} > ${PBS_O_WORKDIR}/zb-TO-SCRATCH.dir
echo ${PBS_O_WORKDIR} > ${SCRATCH_DIR}/zb-TO-PBS-WORKDIR.dir
echo '' > ${PBS_O_WORKDIR}/zc-${PBS_JOBID%.*}.JOBID

# Copying VASP files to scratch
cp ${PBS_O_WORKDIR}/KPOINTS ${PBS_O_WORKDIR}/INCAR ${PBS_O_WORKDIR}/POSCAR ${PBS_O_WORKDIR}/POTCAR ${SCRATCH_DIR}/.

cd ${SCRATCH_DIR}

mpirun -n 20 vasp_std 
# Copying files back to submit directory
declare -a COPY_LIST=("INCAR" "KPOINTS" "POSCAR" "POTCAR" "REPORT" "IBZKPT" "PCDAT" "XDATCAR" "CONTCAR" \
                        "OSZICAR" "EIGENVAL" "vasprun.xml" "OUTCAR" "DOSCAR")

for i in "${COPY_LIST[@]}"; do
        cp ${SCRATCH_DIR}/${i} ${PBS_O_WORKDIR}/.
done

cd ${PBS_O_WORKDIR}
echo "End of Calculation"







