#!/bin/bash
#
#PBS -N GAUSSIAN
#PBS -l select=1:ncpus=20:mem=120gb:interconnect=fdr,walltime=72:00:00
#PBS -l place=scatter
#PBS -j oe
#PBS -r n


# Mail Event
#PBS -l select=1:ncpus=20:mem=120gb:interconnect=fdr,walltime=72:00:00
#PBS -M tdelvau@clemson.edu
#PBS -m n
#ae

module add anaconda3/5.1.0-gcc/8.3.1

cd $PBS_O_WORKDIR

Ase_Thermo=false  ## true for calcualte ASE thermodynamics

if [ "$Ase_Thermo" = "true" ] ; then
        shape=nonlinear      ## strucutre shape
        symnum=1              ## symmetry number
        spin=0                 ## spin number
        temp=298.15            ## temperature in K
        pres=101325.0        ## pressure in Pa
fi

NAME=$(basename $(find . -maxdepth 1 -name "*.gjf") .gjf)
MEM_tmp=`qstat -xf $PBS_JOBID | grep Resource_List.select | grep -o '[0-9]\{1,3\}'gb`
SELECT=`qstat -xf $PBS_JOBID | grep Resource_List.nodect | grep -o '[0-9]'`

let MEM_num=${MEM_tmp%gb}
MEM=$(echo ${MEM_tmp/$MEM_num/$[MEM_num-4]})

# user prepared input file
input=$NAME.gjf

# start

module load gaussian/g09

filename=`basename $input .gjf`

OPTKEYWORD=$(awk '{print $2}' $NAME.gjf | head -1)
sed -n '/[!@]/,$p' $NAME.gjf > basisset.tmp

export GAUSS_LFLAGS='-opt "Tsnet.Node.lindarsharg: ssh"'

# prepare a local scratch dirs
#nodes=`cat $PBS_NODEFILE`
scratch="/scratch1/$USER/$USER.$PBS_JOBID"
#for i in $nodes
#do
#  ssh $i "mkdir $scratch"
#done
mkdir $scratch
export GAUSS_SCRDIR=$scratch

# Augment the input file by the Linda and Shared parallelization
# option
tmpinput=${filename}_tmp.gjf
nodelist=`cat $PBS_NODEFILE | uniq | tr '\n' "," | sed 's|,$||'`
echo "%NProcShared="$OMP_NUM_THREADS >> $tmpinput
if [ $SELECT -ne 1 ]; then
	echo "%LindaWorkers="$nodelist >> $tmpinput
fi
echo "%mem="$MEM >> $tmpinput
echo "%chk="$NAME.chk >> $tmpinput
cat $input >> $tmpinput

# run Gaussian 09
g09 $tmpinput

# rename output file
rm $tmpinput
mv ${filename}_tmp.log ${filename}.log

/software/commercial/gaussian/g09/newzmat -bmodel -noround -nosymav -ichk $NAME.chk -ozmat

# End part 1 and start part 2

#Create checkpoint and input files
cp $NAME.com $NAME-p1.gjf
sed -i '/Geom=Connect/d' $NAME-p1.gjf
cat basisset.tmp >> $NAME-p1.gjf
sed -i "s/$OPTKEYWORD/stable=opt guess=read/" $NAME-p1.gjf

cp $NAME.chk $NAME-p1.chk


# user prepared input file
input=$NAME-p1.gjf

# start

#module load gaussian/g09

filename=`basename $input .gjf`

# Augment the input file by the Linda and Shared parallelization
# option
tmpinput=${filename}_tmp.gjf
nodelist=`cat $PBS_NODEFILE | uniq | tr '\n' "," | sed 's|,$||'`
echo "%NProcShared="$OMP_NUM_THREADS >> $tmpinput
if [ $SELECT -eq 1 ]; then
        echo "%LindaWorkers="$nodelist >> $tmpinput
fi
echo "%mem="$MEM >> $tmpinput
echo "%chk="$NAME-p1.chk >> $tmpinput
cat $input >> $tmpinput

# run Gaussian 09
g09 $tmpinput

# rename output file
rm $tmpinput
mv ${filename}_tmp.log ${filename}.log

# move part 2 files
mkdir stable
mv $NAME-p1* stable

# End part 2 and start part 3

#Create	checkpoint and input files
cp $NAME.com $NAME-p2.gjf
sed -i '/Geom=Connect/d' $NAME-p2.gjf
cat basisset.tmp >> $NAME-p2.gjf
sed -i "s/$OPTKEYWORD/freq=noraman guess=read/" $NAME-p2.gjf

cp $NAME.chk $NAME-p2.chk

# user prepared input file
input=$NAME-p2.gjf

# start

filename=`basename $input .gjf`

# Augment the input file by the Linda and Shared parallelization
# option
tmpinput=${filename}_tmp.gjf
nodelist=`cat $PBS_NODEFILE | uniq | tr '\n' "," | sed 's|,$||'`
echo "%NProcShared="$OMP_NUM_THREADS >> $tmpinput
if [ $SELECT -eq 1 ]; then
        echo "%LindaWorkers="$nodelist >> $tmpinput
fi
echo "%mem="$MEM >> $tmpinput
echo "%chk="$NAME-p2.chk >> $tmpinput
cat $input >> $tmpinput

# run Gaussian 09
g09 $tmpinput

# rename output file
rm $tmpinput
mv ${filename}_tmp.log ${filename}.log

if grep -q "freq" ${filename}.log; then
        grep "Frequencies --" ${filename}.log  > tmp_freq_list.dat
        sed -i 's/Frequencies --//g' tmp_freq_list.dat
        TEXT=$(awk '{$1=$1}1' OFS="," tmp_freq_list.dat | tr '\r' ',' | tr '\n' ',' | sed 's/.$//')
        rm tmp_freq_list.dat

        echo "$NAME-p2.log = [$TEXT]" >> frequencies.dat
fi

# move part 3 files
mkdir freq
mv $NAME-p2* freq

# clean the local scratch directories
#for i in $nodes
#do
#  ssh $i "rm -r $scratch"
#done
rm -r $scratch

~/bin/info.sh > $NAME.info

echo "FINISH ---------------------"
qstat -xf $PBS_JOBID

rm core.[0-9]*
rm basisset.tmp

arr1=( $(find . -iname "*.chk" ) )

for FILE1 in ${arr1[@]}; do
        /software/commercial/gaussian/g09/formchk -3 $FILE1
        rm -v $FILE1
done

# end

if [ "$Ase_Thermo" = "true" ] ; then

        log_file=$NAME.log ## log file name

        python ~/bin/ase-thermo-gaussian-arg.py $log_file $shape $symnum $spin $temp $pres > ase-thermo.out

fi

