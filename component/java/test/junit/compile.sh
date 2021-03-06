#!/bin/bash

function STOUT(){
    $@ 1>/tmp/standard_out 2>/tmp/error_out
    if [ "$?" -eq "0" ]
    then
        cat /tmp/standard_out | awk '{print "[COUT]", $0}'
        cat /tmp/error_out | awk '{print "[COUT]", $0}' >&2
        return 0
    else
        cat /tmp/standard_out | awk '{print "[COUT]", $0}'
        cat /tmp/error_out | awk '{print "[COUT]", $0}' >&2
        return 1
    fi
}
function STOUT2(){
    $@ 1>/dev/null 2>/tmp/error_out
    if [ "$?" -eq "0" ]
    then
        cat /tmp/error_out | awk '{print "[COUT]", $0}' >&2
        return 0
    else
        cat /tmp/error_out | awk '{print "[COUT]", $0}' >&2
        return 1
    fi
}

declare -A map=(
    ["git-url"]="" 
    ["out-put-type"]=""
    ["report-path"]=""
    ["version"]=""
)
data=$(echo $CO_DATA |awk '{print}')
for i in ${data[@]}
do
    temp=$(echo $i |awk -F '=' '{print $1}')
    value=$(echo $i |awk -F '=' '{print $2}')
    for key in ${!map[@]}
    do
        if [ "$temp" = "$key" ]
        then
            map[$key]=$value
        fi
    done
done

if [ "" = "${map["git-url"]}" ]
then
    printf "[COUT] Handle input error: %s\n" "git-url"
    printf "[COUT] CO_RESULT = %s\n" "false"
    exit
fi

if [[ "${map["out-put-type"]}" =~ ^(xml|json|yaml)$ ]]
then
    printf "[COUT] out-put-type: %s\n" "${map["out-put-type"]}" 1>/dev/null 2>&1
else
    printf "[COUT] Handle input error: %s\n" "out-put-type should be one of xml,json,yaml"
    printf "[COUT] CO_RESULT = %s\n" "false"
    exit
fi

if [ "${map["version"]}" = "gradle3" ]
then
    gradle_version=$gradle3/gradle
elif [ "${map["version"]}" = "gradle4" ]
then
    gradle_version=$gradle4/gradle
else
    printf "[COUT] Handle input error: %s\n" "version should be one of gradle3,gradle4"
    printf "[COUT] CO_RESULT = %s\n" "false"
    exit
fi

if [ "" = "${map["report-path"]}" ]
then
    map["report-path"]="./"
fi

STOUT git clone ${map["git-url"]}
if [ "$?" -ne "0" ]
then
    printf "[COUT] CO_RESULT = %s\n" "false"
    exit
fi

pdir=`echo ${map["git-url"]} | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}'`
cd ./$pdir
if [ ! -f "build.gradle" ]
then
    printf "[COUT] file build.gradle not found! \n"
    printf "[COUT] CO_RESULT = %s\n" "false"
    exit
fi 
cd ${map["report-path"]}
cat /root/testng.conf >> build.gradle
$gradle_version test

if [ "${map["out-put-type"]}" = "xml" ]
then
    for file in `ls ./build/test-results/test`
    do
        if test -f ./build/test-results/test/$file
        then
            cat ./build/test-results/test/$file
        fi
    done
else
    for file in `ls ./build/test-results/test`
    do
        if test -f ./build/test-results/test/$file
        then
            java -jar /root/convert.jar ./build/test-results/test/$file ${map["out-put-type"]}
        fi
    done
fi

printf "[COUT] CO_RESULT = %s\n" "true"
exit