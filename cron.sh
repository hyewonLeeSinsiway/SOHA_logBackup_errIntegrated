#!/bin/bash

###
# 2023.05.31 by hwlee
# 로그 백업 스케줄 등록 스크립트
# 1. 날짜 형식 확인
# 2. crontab 등록 명령어
# 3. 인자값 cron 형식으로 변환 후 등록
#
# 사용법: sh cron.sh [period] [time]
# ex)
# sh cron.sh day
# sh cron.sh day 11:30
# sh cron.sh week
# sh cron.sh week 3
# sh cron.sh week 1 18:00
# sh cron.sh month
# sh cron.sh month 15
# sh cron.sh month 15 18:00
# sh cron.sh year
# sh cron.sh year 1231
# sh cron.sh year 0306 07:48
#
# 보다 자세한 설명 위해서는 help 옵션
# ex) sh cron.sh help
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
# 날짜 형식 확인
# parameter: minute hour day_of_month month day_of_week
###
date_format_check() {
    local minute=$1
    local hour=$2
    local day_of_month=$3
    local month=$4
    local day_of_week=$5

    # 날짜 형식 틀린 부분 확인 시 1로 변경
    local switch=0

    if [[ $minute -lt 00 || $minute -gt 59 || ! $minute =~ ^[0-9]+$ ]]; then
        echo "minute is wrong"
        switch=1
    fi

    if [[ $hour -lt 00 || $hour -gt 23 || ! $hour =~ ^[0-9]+$ ]]; then
        echo "hour is wrong"
        switch=1
    fi

    if [[ $day_of_month -lt 01 || $day_of_month -gt 31 || ! $day_of_month =~ ^[0-9]+$ ]]; then
        echo "day_of_month is wrong"
        switch=1
    fi

    if [[ $month == 02 && $day_of_month -gt 29 ]]; then
        echo "day_of_month is wrong"
        switch=1
    fi

    if [[ $month == 04 || $month == 06 || $month == 09 || $month == 11 ]]; then
        if [[ $day_of_month -gt 30 ]]; then
            echo "day_of_month is wrong"
            switch=1
        fi
    fi

    if [[ $month -lt 01 || $month -gt 12 || ! $month =~ ^[0-9]+$ ]]; then
        echo "month is wrong"
        switch=1
    fi
    
    if [[ $day_of_week -lt 0 || $day_of_week -gt 6 || ! $day_of_week =~ ^[0-9]+$ ]]; then
        echo "day_of_week is wrong"
        switch=1
    fi
    
    if [[ $switch -eq 1 ]]; then
        # echo "1"
        return 1
    fi

    echo "0"
}



###
# crontab 등록 명령어
###
set_cronjob() {
    local cmd=$1
    local log_dir=$SOHA_HOME/$SOHA_SVC/log
    local backup_dir="$log_dir/backup"
    local cron_log_path="$backup_dir/cron_log.log"
    local schedule="$2"
    local job="$cmd >> $cron_log_path 2>&1"

    echo -e "#" `date` "\n# petra log backup system" | crontab -    
    (crontab -l ; echo "$schedule $job") | crontab -
}


###
# 인자값 cron 형식으로 변환 후 등록
###
set_cron_schedule() {
    local period=${1:-"day"}
    local hour=0
    local minute=0
    local day_week=0
    local day=1
    local month=1

    # 
    # create_backup_dir
    #
    if ! create_backup_dir; then
        return 1
    fi

    # 1.
    # day backup
    # ex )
    # day
    # day 11:30
    # day 18:00
    #
    if [[ $period == "day" ]]; then
        if [[ -n $2 ]]; then
            local time=(${2//:/ })
            hour=${time[0]}
            minute=${time[1]}
        fi
        
        if [ "$(date_format_check $minute $hour $day $month $day_week)" != "0" ]; then
            date_format_check $minute $hour $day $month $day_week
            return 1
        fi
        set_cronjob "sh $SOHA_HOME/$SOHA_SVC/bin/logs_backup.sh" "$minute $hour * * *"
        # echo "$minute $hour * * *"

    # 2.
    # week backup
    # ex )
    # week
    # week 3
    # week 1 18:00
    #
    elif [[ $period == "week" ]]; then
        if [[ -n $2 ]]; then
            if [[ -n $3 ]]; then
                local time=(${3//:/ })
                hour=${time[0]}
                minute=${time[1]}
            fi
        day_week=$2
        fi
        
        if [ "$(date_format_check $minute $hour $day $month $day_week)" != "0" ]; then
            date_format_check $minute $hour $day $month $day_week
            return 1
        fi
        set_cronjob "sh $SOHA_HOME/$SOHA_SVC/bin/logs_backup.sh" "$minute $hour * * $day_week"
        # echo "$minute $hour * * $day_week"

    # 3.
    # month backup
    # ex )
    # month
    # month 15
    # month 15 18:00
    #
    elif [[ $period == "month" ]]; then
        if [[ -n $2 ]]; then
            if [[ -n $3 ]]; then
                local time=(${3//:/ })
                hour=${time[0]}
                minute=${time[1]}
            fi
            day=${2:-"L"}
        else 
            day="L"
        fi

        if [ "$(date_format_check $minute $hour $day $month $day_week)" != "0" ]; then
            date_format_check $minute $hour $day $month $day_week
            return 1
        fi
        set_cronjob "sh $SOHA_HOME/$SOHA_SVC/bin/logs_backup.sh" "$minute $hour $day * *"
        # echo "$minute $hour $day * *"
    
    # 4.
    # year backup
    # ex )
    # year
    # year 1231
    # year 0306 07:48
    #
    elif [[ $period == "year" ]]; then
        if [[ -n $2 ]]; then
            if [[ -n $3 ]]; then
                local time=(${3//:/ })
                hour=${time[0]}
                minute=${time[1]}
            fi
            month=${2:0:2}
            day=${2:2}
        fi
        
        if [ "$(date_format_check $minute $hour $day $month $day_week)" != "0" ]; then
            date_format_check $minute $hour $day $month $day_week
            return 1
        fi
        set_cronjob "sh $SOHA_HOME/$SOHA_SVC/bin/logs_backup.sh" "$minute $hour $day $month *"
        # echo "$minute $hour $day $month *"
    
    # 5.
    # wrong input
    #
    else
        # echo "wrong input"
        echo "usage: sh cron.sh [day|week|month|year] [day_of_week|day_of_month|month_day] [hour:minute]"
        echo ""
        echo "ex) sh cron.sh day"
        echo "ex) sh cron.sh day 11:30"
        echo "ex) sh cron.sh week"
        echo "ex) sh cron.sh week 3"
        echo "ex) sh cron.sh week 1 18:00"
        echo "ex) sh cron.sh month"
        echo "ex) sh cron.sh month 15"
        echo "ex) sh cron.sh month 15 18:00"
        echo "ex) sh cron.sh year"
        echo "ex) sh cron.sh year 1231"
        echo "ex) sh cron.sh year 0306 07:48"
        echo ""
        echo "defautl value) period=day, day=1, month=1, hour=0, minute=0, day_of_week=0"
        echo "day_of_week means) 0:sunday, 1:monday, 2:tuesday, 3:wednesday, 4:thursday, 5:friday, 6:saturday"
        echo ""
        
        exit 1
    fi
    
}

set_cron_schedule $1 $2 $3
