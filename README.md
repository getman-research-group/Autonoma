# Autonoma
 A tool for high throughput computational simulations on the Palmetto High Performance Computing Cluster.
 

### Scripts
- **MassJobs.sh** ~ Counts the number of input files in the same folder and starts and instance of Autonoma.sh corresponding to each input file.
- **Autonoma.sh** ~ Runs jobs and checks verification script for a single input file.
- **StatusChecker.sh** ~ Checks the status of jobs that are currently running or have run in the same folder. Results are printed to a CSV.
- **DirectoryCleaner.sh** ~ Uses the input file name to create a new directory. Clears the directory if it already exists. Copies files needed for the job into the directory.
- **Scripts/Verification.sh** ~ Contains the verificaton commands that will be run upon cluster job completion
- **Scripts/Functions.sh** ~ File of functions used through the other bash scripts

Please add the following to your .bashrc or run this command before running the scripts:
`module add pcre/8.44-gcc/8.4.1`

Please also note that if you are not on Clemson's campus network, you will need to connect to via Clemson's VPN to access the Palmetto Cluster and your My.VM.
