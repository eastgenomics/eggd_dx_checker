# eggd_dx_checker

## What does this app do?

App to check for affects of weekly DNAnexus updates

## What are typical use cases for this app?

Used to evaluate if any changes from weekly DNAnexus updates affect functioning of Sentieon germline FASTQ to VCF.
Should be run in conjunction with Sentieon germline FASTQ to VCF from the same FASTQs as the previously generated VCF against which to check.


## What data are required for this app to run?

A "truth" previously generated VCF and the newly generated VCF from running Sentieon.


## What does this app output?

If no differences are found, an empty `vcf_diff.txt` file is output.
If differences are found, `vcf_diff.txt` is output containing the differences.


### This app was made by EMEE GLH