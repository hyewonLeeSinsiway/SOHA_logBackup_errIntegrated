#!/bin/bash

###
# 2023.06.07 by hwlee
# 로그 통합 스크립트
# 1. 로그 내용 통합
#
# 사용법: sh error_integrated.sh [%Y-%m-%d] [%H:%M:%S] [errer | err]
# ex) sh error_integrated.sh
#     인자가 없을 경우: 
#     - 오늘 날짜로 설정($period_date)
#     - 전체 통합밖에 되지 않음
# ex) sh error_integrated.sh 2021-06-07 00:00:00
# ex) sh error_integrated.sh 2021-06-07 18:30:00 error
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
# 로그 내용 통합
###
extract_logs_period () {
    local log_dir=$SOHA_HOME/$SOHA_SVC/log
    local backup_dir=$SOHA_HOME/$SOHA_SVC/log/backup
    local period_date=`date -d "$1 $2" +%s`
    local summary_file_name="summary_log"
    
    # error integerated log check variable
    local extract_error=$3

    local error_code=("Exception" "Error" "error" "ERROR" "exception" "EXCEPTION" "fail" "FAIL" "Fail" "FATAL" "fatal" "Fatal" "FATAL" "WARN" "warn" "Warn" "WARNING" "warning" "Warning")

    # 
    # create_backup_dir
    #
    if ! create_backup_dir; then
        return 1
    fi
    
    
    #
    # 로그 통합 종류 확인하여 파일명 설정
    # 두번째 인자가 없을 경우: 전체 로그 통합(summary_log_######.log)
    # 두번째 인자 err 경우: 에러 부분만 추출하여 통합(exception_log_######.log)
    #
    if [ -z "$extract_error" ]; then
        summary_file_name="summary_log"
    elif [ "$extract_error" = "err" ] || [ "$extract_error" = "error" ]; then
        extract_error="err"
        summary_file_name="exception_log"
    else
        echo "extract_error type is not valid. Aborting log integrated."
        echo "ex) err"
        echo "ex) [NULL]"
        return 1
    fi

    
    #
    # 로그 통합 시작
    #
    echo '--------------------------------------' >> ${backup_dir}/${summary_file_name}_${period_date}.log
    echo `date "+%Y/%m/%d %H:%M:%S"` >> ${backup_dir}/${summary_file_name}_${period_date}.log
    for file in $(ls $log_dir/*.log); do

        file_time=`date -d "$(stat -c %y $file | awk {'print $1'})" +%s`
            
        #
        # 1) 기간 확인 - 파일 생성 시간과 기간 비교
        # 기간보다 작을 경우: 다음 파일로 넘어감
        # 기간보다 클 경우: 로그 통합 대상
        # 2) 기간 확인 - 파일 내 시간과 기간 비교
        # 입력한 기간의 로그만 통합
        #

        if (( $file_time < $period_date )); then
            #
            # 1) 기간 확인 - 파일 생성 시간과 기간 비교
            # 기간보다 작을 경우: 다음 파일로 넘어감
            #
            continue
        else
            echo "======================" >> ${backup_dir}/${summary_file_name}_${period_date}.log
            echo "$(basename "$file") " >> ${backup_dir}/${summary_file_name}_${period_date}.log
            echo "======================" >> ${backup_dir}/${summary_file_name}_${period_date}.log
            #
            # 2) 기간 확인 - 파일 내 시간과 기간 비교
            # [2023-06-27 14:47:00:12345] 와 같이 작성된 로그 내용 중 시간 비교
            #
            line_arr=($(basename "$file"))
            line_arr+=(`grep -oPn '^\[\K\d{4}-\d{2}-\d{2}\ \d{2}:\d{2}:\d{2}(?=:\d{1,6}\])' $file`)
            line_arr_length=${#line_arr[@]}
            i=1
            while [ $line_arr_length -gt $i ]; do
                IFS=':' read -ra DATELINE <<< "${line_arr[$i]}"
                line_date=`date -d "${DATELINE[1]} ${line_arr[(($i+1))]}" +%s`
                local switch=0
                if [ $period_date -le $line_date ]; then
                    IFS=':' read -ra NEXTLINE <<< "${line_arr[$i+2]}"
                    if [ -z ${NEXTLINE[0]} ]; then
                        next_line_num=$((${DATELINE[0]}+1))
                    else
                        next_line_num=${NEXTLINE[0]}
                    fi
                    #
                    # 로그 통합 종류 확인
                    # 1. extract_error=err: 에러 부분만 추출하여 통합
                    # 2. extract_error=NULL: 전체 로그 통합
                    #
                    if [ "$extract_error" == "err" ]; then
                        for code in "${error_code[@]}"; do
                            switch=$(awk -v code="$code" -v line_num=${DATELINE[0]} -v next_line_num=${NEXTLINE[0]} 'NR>=line_num && NR<next_line_num { if (index($0, code)) {print 1; exit} else {print 0}}' $file)
                            if [ "$switch" = "1" ]; then
                                awk -v line_num=${DATELINE[0]} -v next_line_num=$next_line_num 'NR>=line_num && NR<next_line_num {print $0}' $file >> ${backup_dir}/${summary_file_name}_${period_date}.log
                                break;
                            fi
                        done
                    else
                        awk -v line_num=${DATELINE[0]} -v next_line_num=$next_line_num 'NR>=line_num && NR<next_line_num {print $0}' $file >> ${backup_dir}/${summary_file_name}_${period_date}.log
                    fi
                    i=$((i+2))
                else
                    i=$((i+2))
                    continue
                fi
            done
        fi
    done
    echo '--------------------------------------' >> ${backup_dir}/${summary_file_name}_${period_date}.log
}


extract_logs_period $1 $2 $3

