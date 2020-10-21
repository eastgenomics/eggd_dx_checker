#!/bin/bash
# dx_checker 1.0.0

main() {

    dx download "$truth_vcf"
    dx download "$query_vcf"

    gunzip "$truth_vcf_name" && truth_vcf=${truth_vcf_name/.gz/}
    gunzip "$query_vcf_name" && query_vcf=${query_vcf_name/.gz/}

    echo "truth vcf: $truth_vcf"
    echo "query_vcf: $query_vcf"

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
    echo "exit code: $exit"

    if [[ $exit -eq 0 ]]; then
        # no diff found
        echo "No difference in VCFs found"
        message="Weekly dx integrity check notifier: no differences identified ✅"
        ~/miniconda3/bin/python "$hermes_dir"/hermes.py msg "$message" ~/slack_token.txt "egg-logs"
    elif [[ $exit -eq 1 ]]; then
        # diff found
        echo "VCFs differ"
        message="❗ Weekly dx integrity check alert: differences identified in Sentieon output ❗"
        ~/miniconda3/bin/python "$hermes_dir"/hermes.py msg "$message" ~/slack_token.txt "egg-alerts"
    else
        # exit code not 0 or 1 => issue with command
        echo "Issue with diff command"
        message="❗ Weekly dx integrity check alert: diff command has exit code $exit, check the job logs for details. ❗"
        ~/miniconda3/bin/python "$hermes_dir"/hermes.py msg "$message" ~/slack_token.txt "egg-alerts"
    fi

    # add diff file to out for uploading
    mv vcf_diff.txt out/check_output

    # upload output files
    dx-upload-all-outputs
}
