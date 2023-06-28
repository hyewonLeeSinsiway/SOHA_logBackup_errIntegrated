#!/bin/bash

###
# 2023.06.07 by hwlee
# 백업 디렉토리 생성 스크립트
# 1. 디스크 용량 확인
# 2. 백업된 로그 저장할 디렉토리 생성
#
# 사용법: 다른 스크립트에서 불러와 사용 
# source ./backup_dir_create.sh
#
###


###
# 환경 변수 설정 확인
###
if [[ -z $SOHA_SVC ]] || [[ -z $SOHA_HOME ]]; then
    echo "SOHA_SVC/SOHA_HOME is not set. Aborting backup."
    exit 1
fi


###
# 디스크 용량 확인
###
check_disk_space() {
    # df 명령어를 이용하여 디스크 사용량을 확인
    local usage=$(df -h --output=pcent / | tail -n 1 | tr -d ' ')

    # 디스크 사용량이 80% 이상이면 1을, 그렇지 않으면 0을 반환
    if [ "${usage::-1}" -ge 80 ]; then
        echo "1"
    else
        echo "0"
    fi
}



###
# 백업된 로그 저장할 디렉토리 생성
###
create_backup_dir() {
    # 디스크 사용량 확인
    if [ "$(check_disk_space)" -eq 1 ]; then
        echo "Disk space is low. Aborting backup."
        exit 1
    fi

    # 로그 백업 디렉토리 생성
    local backup_dir=$SOHA_HOME/$SOHA_SVC/log/backup

    if [ -d "$backup_dir" ]; then
        echo "Backup directory already exists. Skipping creation."
        return 0
    fi
    
    mkdir -p "$backup_dir"
}

