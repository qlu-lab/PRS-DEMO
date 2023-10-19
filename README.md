# PRS-DEMO
This is a demo of a PRS script that allows you to automatically train and calculate PRS scores across all popular PRS methods. Currently the demo will only work for LDpred2 and a simple PRS scoring method so the demo can be done in a timely fashion.

### Set up
* Clone this repo into a folder on your local computer
```
git clone https://github.com/qlu-lab/PRS-DEMO.git
```
* Change directory into PRS-DEMO folder
```
cd PRS-DEMO
```

* `PRS-DEMO` is developed using R. The statistical computing software R (>=4.3) is required.
  * The following packages are necessary for running `PRS-DEMO`, but they will be automatically installed for you when you run the demo if you don't already have them installed. Required R packages: [tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html), [data.table](https://cran.r-project.org/web/packages/data.table/index.html), [R.utils](https://cran.r-project.org/web/packages/R.utils/index.html), [plyr](https://cran.r-project.org/web/packages/plyr/index.html), [bigsnpr](https://cran.r-project.org/web/packages/bigsnpr/index.html), [bigreadr](https://cran.r-project.org/web/packages/bigreadr/index.html), [optparse](https://cran.r-project.org/web/packages/optparse/index.html), [foreach](https://cran.r-project.org/web/packages/foreach/index.html), [rngtools](https://cran.r-project.org/web/packages/rngtools/index.html)
  	* Please download these R packages ahead of the demo using `install.packges` if you are able to 

* Make output folder for PRS weights
```
mkdir weights
```

* Download LD and GWAS data and put it in the input folder

If you don't already have `wget` downloaded on your computer, follow the following tutorials to download it on your machine.
  * [Download and Install wget on Mac](https://www.jcchouinard.com/wget/#Download_and_Install_Wget_on_Mac)
  * [Download and Install wget on Linux](https://www.jcchouinard.com/wget/#Download_and_Install_Wget_on_Linux)
  * [Download and Install wget on Windows](https://www.jcchouinard.com/wget/#Download_and_Install_Wget_on_Windows)

Download the LD and GWAS data using `wget`
```
wget -nd -r -P ./input ftp://ftp.biostat.wisc.edu/pub/lu_group/Projects/PRS_demo/input
```

* Download PLINK
  * [Download PLINK](https://www.cog-genomics.org/plink/)
  * Unzip the downloaded file
    <img width="851" alt="Screenshot 2023-10-17 at 1 00 33 PM" src="https://github.com/svdorn/PRSdemo/assets/22485021/0e68097b-f6e7-4444-850b-c4e0d526bd5c">
  * Move the downloaded file from your Downloads folder to your `PRS-DEMO` folder
    <img width="838" alt="Screenshot 2023-10-17 at 1 04 53 PM" src="https://github.com/svdorn/PRSdemo/assets/22485021/48e9b332-7978-4e6e-b2f5-695d40b2aec2">
  * Rename the folder to "plink"
    <img width="847" alt="Screenshot 2023-10-17 at 1 04 30 PM" src="https://github.com/svdorn/PRSdemo/assets/22485021/76d4dd17-7bb4-4fdd-8cd6-d8136768d8b0">
  * For macs, you may see the following error message after downloading PLINK:

	<img width="311" alt="Screenshot 2023-10-17 at 2 24 09 PM" src="https://github.com/svdorn/PRSdemo/assets/22485021/ccb90e5f-ea8a-4435-8470-df048f15f255">
   
   *  If you get this error go to System Settings -> Privacy & Security and scroll down until you get to this section. Allow PLINK to be downloaded and try downloading again.

		<img width="495" alt="Screenshot 2023-10-17 at 2 22 42 PM" src="https://github.com/svdorn/PRSdemo/assets/22485021/d04dcfa6-b78e-4914-bd95-0aae17072376">



### Run
* To run the script to get PRS scores, run
```
bash calculate_prs.sh \
	-s ./input/gwas_train.txt.gz \
	-l ./input/1kg_hm3_QCed_noM \
	-g ./input/1kg_hm3_QCed_noM \
	-p ./plink \
	-m ldpred2,prs \
	-o mac
```
Where flags are 
* -s: path to sumstats_file
* -l: path to LD files
* -g: path to genotype file
* -p: path to PLINK software
* -m: PRS methods you want to run
* -o: opterating system (mac, windows, or linux)

If you are using a Windows machine, follow this tutorial for [running .sh scripts in Windows](https://softwarekeep.com/help-center/how-to-run-shell-script-file-in-windows#)
  
Output will be written to `prs_scores.txt` and the first few rows of data will look like:

![image](https://github.com/svdorn/PRSdemo/assets/22485021/7354c93e-46fe-4656-8fb2-714e0de3307c)
The columns are as follows:
* FID: family ID from genotype file
* IID: individual ID from genotype file
* LDpred2_: 13 columns representing running LDpred2 with 13 different tuning parameters
	* LDpred2_auto: sample p from a posterior distribution and calculate h2 in each iteration of Gibbs sampler
 	* All other columns are of the format LDpred2_0.03_0.001_sparse. In this example, the tuning parameters are:
  		* heritability (h2) is 0.03
    		* the proportion of causal variants (p) is 0.001
      		* sparse is True (when sparse is True, for variants whose posterior probability of being a causal variant is smaller than the set proportion of causal variants value in 2, their effect sizes will be exactly 0)
* PRS_: 5 columns representing running default PRS method with 5 different tuning parameters
	* All columns are of the format PRS_0.01. In this example the tuning parameter is:
 		* p-value <= 0.01
