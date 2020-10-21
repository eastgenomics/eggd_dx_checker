#!/bin/bash
# dx_checker 1.0.0

main() {

    dx download "$truth_vcf"
    dx download "$query_vcf"

    gunzip "$truth_vcf_name" && truth_vcf=${truth_vcf_name/.gz/}
    gunzip "$query_vcf_name" && query_vcf=${query_vcf_name/.gz/}

    # output dir for uploading diff output
    mkdir -p out/check_output

    # install python3.8
    gunzip Miniconda3-latest-Linux-x86_64.sh.gz
    bash ~/Miniconda3-latest-Linux-x86_64.sh -b

    # install required python packages
    cd packages
    ~/miniconda3/bin/pip install -q idna-* multidict-* typing_extensions-* multidict-* chardet-* attrs-* async_timeout-* aiohttp-* slackclient-*
    cd ~

    # get output dir name of unzipped hermes
    hermes_dir=$(find . -name "hermes-*")
    hermes_dir=${hermes_dir/.zip/}
    
    # unzip hermes for Slack notifications
    unzip hermes-*

    # set exit var to check diff exit code against
    exit=0

    # check for differences in variants of original VCF and newly generated VCF
    diff -d -I '^#' $truth_vcf $query_vcf > vcf_diff.txt || exit=$?

    if [ $exit==0 ]; then
        # no diff found
        echo "No difference in VCFs found"
        ~/miniconda3/bin/python "$hermes_dir"/hermes.py msg "✅ dx checker update: no differences identified"
    elif [ $exit==1 ]; then
        # diff found
        echo "VCFs differ"
        ~/miniconda3/bin/python "$hermes_dir"/hermes.py msg "❗ dx checker alert: differences identified in Sentieon output ❗"
    else
        # exit code not 0 or 1 => issue with command
        echo "Issue with diff command"
        ~/miniconda3/bin/python "$hermes_dir"/hermes.py msg "❗ dx checker alert: diff command has exit code $exit, check the job logs for details. ❗"
    fi

    # add diff file to out for uploading
    mv vcf_diff.txt out/check_output

    # upload output files
    dx-upload-all-outputs
}

