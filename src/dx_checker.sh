#!/bin/bash
# dx_checker 1.0.0

main() {

    echo "Value of truth_vcf: '$truth_vcf'"
    echo "Value of query_vcf: '$query_vcf'"

    dx download "$truth_vcf" -o truth_vcf
    dx download "$query_vcf" -o query_vcf

    mkdir -p out/check_output

    # check for differences in variants of original VCF and newly generated VCF
    diff -d -I '^#' truth_vcf query_vcf > vcf_diff.txt

    if [ -s vcf_diff.txt ]; then
        # diff found
        echo "VCFs differ"
        mv vcf_diff.txt out/check_output
        mv query_vcf out/check_output
    else
        # no diff found
        echo "No difference in VCFs found"
        mv vcf_diff.txt out/check_output

    # upload output files
    dx-upload-all-outputs
}
