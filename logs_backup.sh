#!/bin/bash

###
# 2023.05.31 by hwlee
# 로그 백업 스크립트
# 1. 디스크 용량 확인
# 2. 백업된 로그 저장할 디렉토리 생성
# 3. 로그 파일 null 처리
# 4. 로그 파일 백업
#
# 사용법: sh logs_backup.sh [not_null]
#  - not_null: 로그 파일 null 처리를 하지 않음
#
###

###
# backup_dir_create 스크립트 불러오기
###
source ./backup_dir_create.sh


###
# 환경 변수 설정 확인
###
if [[ -z $SOHA_SVC ]] || [[ -z $SOHA_HOME ]]; then
    echo "SOHA_SVC/SOHA_HOME is not set. Aborting backup."
    exit 1
fi


###
# 로그 파일 null 처리
###
nullify_logs() {
    # 로그 파일 null 처리
    local log_dir=$SOHA_HOME/$SOHA_SVC/log
    local log_files

    # 로그 파일 null 처리
    pushd $log_dir > /dev/null
    log_files=(*.log)
    for file in ${log_files[@]}; do
        cp /dev/null $file
    done
    popd > /dev/null
}




###
# 로그 파일 백업
###
backup_logs() {
    local log_dir=$SOHA_HOME/$SOHA_SVC/log
    local backup_dir="$log_dir/backup"
    local log_files

    # 
    # create_backup_dir
    #
    if ! create_backup_dir; then
        return 1
    fi

    #
    # 내용 압축 --> backup 디렉토리로 이동
    #
    pushd $log_dir > /dev/null
    log_files=(*.log)
    popd > /dev/null

    tar -czf "${SOHA_SVC}_$(date +%Y%m%d%H%M%S).tar.gz" -C $log_dir ${log_files[@]}
    mv ${SOHA_SVC}* $backup_dir

    #
    # 기존 log 들 null 처리 확인
    # 기본값: null 처리
    #
    if [[ $1 == "not_null" ]]; then
        echo "Logs not be nullifed"
    else
        for file in $log_files; do
            nullify_logs "$file"
        done
    fi
}

backup_logs $1
