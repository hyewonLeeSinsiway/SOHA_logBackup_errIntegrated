# SOHA_logBackup_errIntegrated
SOHA system log: backup &amp; error part integraged bash shell script


# 기본 소개
<2023-06.v1.0>

해당 쉘 스크립트 프로그램은 SOHA의 자체적으로 떨어지는 시스템로그를 백업 및 로그 내용/에러 내용 추출하여 통합 파일로 생성하는데 목적을 둡니다. 

기본 설정값은 모두 SOHA가 설치된 환경을 기준으로 되어있으므로, 여타 다른 시스템이 적용하시려면 스크립트의 내용을 적절하게 수정하여 사용하시기 바랍니다. 

스크립트 내용이 비효율적이고 복잡하기 때문에 이해하기 어려울 수 있습니다. 슬프지만 저도 알고있습니다. 

추후 실력이 늘면 차차 수정/개선할 예정이므로 지금은 일단 넘어가주시기 바랍니다. 

사용 용도에 따라 아래의 쉘을 단품 사용 혹은 교차 사용이 가능합니다. 

1. SOHA 시스템 로그 내용 지우고 기존 내용 압축 백업 - logs_backup
2. SOHA 시스템 로그 내용을 하나의 파일에 전체 출력해서 확인하기 - error_integrated
3. 로그 백업 스크립트를 주기적으로 스케줄링 걸어놓기 - cron

사용하고자 하는 목적에 따라 선택하여 운용합니다. 

이 때 cron 스크립트를 사용하고자 하면 파일들의 경로는 $SOHA_HOME/$SOHA_SVC/bin 아래에 위치시킵니다. cron 스크립트를 사용하지 않는다면 같은 경로에만 위치하면 되고 어느 경로에 있어도 상관 없습니다. 

해당 프로그램은 linux OS 기반의 서버환경에서의 동작만 보증합니다. 

# 스크립트 설명

![image](https://github.com/hyewonLeeSinsiway/SOHA_logBackup_errIntegrated/assets/62870767/cd3b05eb-d8a5-4a0f-aaaa-e4c7b5aabbf0)

## 0. backup_dir_create
해당 스크립트는 프로그램을 어느 방향으로 사용하시든간에 반드시 필요합니다. (모든 스크립트에서 해당 파일을 호출합니다.)

사용하려는 스크립트와 동일한 경로에 위치시킵니다. 

서버 디스크 용량을 확인하여 쉘 스크립트 동작을 통제하고, 각종 파일이 생성될 백업 디렉토리를 생성합니다. 

백업 디렉토리의 경로는 $SOHA_HOME/$SOHA_SVC/log/backup 입니다.

### 함수 목록
1. check_disk_space()
- 서버 디스크 용량을 확인합니다. 80% 이상 찼을 경우 동작을 중지합니다.
2. create_backup_dir()
- $SOHA_HOME/$SOHA_SVC/log/backup 디렉토리를 생성합니다.

### 사용법
다른 스크립트에서 선언하여 사용합니다.
```source ./backup_dir_create.sh```


## 1. logs_backup
SOHA 시스템 로그 초기화 및 압축/백업합니다.

### 함수 목록
1. nullify_logs()
- 로그 파일 크기를 0 으로 바꿔 초기화 시킵니다. 
2. backup_logs()
- 로그 파일을 "${SOHA_SVC}_$(date +%Y%m%d%H%M%S).tar.gz" 으로 압축해 백업 경로로 이동시킵니다. 
### 사용법
``` $ sh logs_backup.sh```
- 로그 파일을 압축/백업하고 로그들의 크기를 0으로 초기화 합니다. 

``` $ sh logs_backup.sh not_null```
- 로그 파일을 압축/백업하지만 기존 로그들은 그대로 유지합니다. 


## 2. error_integrated
SOHA 시스템 로그를 입력한 시간 이후의 로그 내용만 추출하여 하나의 파일로 출력합니다. 

옵션값에 따라 전체 로그 통합,에러 로그만 통합할 수 있습니다. 로그 통합 파일은 백업 디렉토리에 생성됩니다. 

전체 로그 통합 파일은 summary_log_######.log 의 이름 형식으로 지정되며, 에러 로그 통합 파일은 exception_log_######.log 의 이름 형식으로 지정됩니다. 

(뒤에 붙는 숫자는 입력한 시간의 스트링값 입니다.)

에러 로그로 판단하는 기준은 아래 리스트 중 하나라도 로그 블록에 포함되어 있을 경우입니다. 

```"Exception" "Error" "error" "ERROR" "exception" "EXCEPTION" "fail" "FAIL" "Fail" "FATAL" "fatal" "Fatal" "FATAL" "WARN" "warn" "Warn" "WARNING" "warning" "Warning"```

만약 에러 로그 판단 기준을 추가하고 싶다면 스크립트 중 extract_logs_period().error_code 배열을 수정하여 사용하십시오.

### 함수 목록
1. extract_logs_preiod()
- 입력받은 기간 이후의 로그만 추출하여 하나의 파일로 통합합니다. 
- 기간을 입력받지 않을 경우 쉘을 동작한 날짜의 00:00:00 시간 기준으로 통합됩니다. 이 때에는 전체 로그 통합만 가능합니다. 

### 사용법
``` $ sh error_integrated.sh```
- 오늘 날짜의 00:00:00 시간 이후로 작성된 로그 내용만 통합됩니다. 

``` $ sh error_integrated.sh 2023-06-28 18:30:00```
- 2023-06-28 18:30:00 이후 작성된 로그 내용만 통합됩니다. 

``` $ sh error_integrated.sh 2023-06-28 18:30:00 err```
- 2023-06-28 18:30:00 이후 작성된 로그 내용중 error_code 의 단어가 포함된 내용만 통합됩니다. 


## 3. cron
해당 스크립트는 오로지 logs_backup.sh 쉘 스크립트를 보다 편하게 crontab 에 등록할 수 있게 도와줍니다. 

만일 crontab 문법을 잘 아는 경우에는 crontab 에 수동으로 스크립트를 등록하여 사용하시기를 권장합니다. 

해당 스크립트의 보다 자세한 사용법을 원하시면 아래와 같이 입력하십시오.

``` $ sh corn.sh help ```

또한 해당 스크립트를 사용하려면 반드시 모든 파일들의 위치가 $SOHA_HOME/$SOHA_SVC/bin 아래에 존재해야 합니다. 

### 함수 목록
1. date_foramt_check()
- crontab 에 등록해야 할 날짜 형식을 잘못 입력했을 경우 쉘을 종료합니다. 
- 예를들어, 2월은 31일이 없는데 0231 과 같이 2/31 을 입력할 경우 crontab 에 등록하지 않고 에러 문구 출력 후 쉘을 종료합니다. 
2. set_cronjob()
- 실제 crontab 에 등록하는 명령어를 수행합니다. 
3. set_cron_schedule()
- 사용자가 입력한 인자값을 crontab 에 등록할 수 있는 형식으로 변경한 뒤 set_cronjob()을 호출합니다.

### 사용법
``` $ sh cron.sh day```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매일 00:00 에 실행됩니다. 

``` $ sh cron.sh day 11:30```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매일 11:30 에 실행됩니다. 

``` $ sh cron.sh week```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매주 일요일 00:00 에 실행됩니다. 

``` $ sh cron.sh week 3```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매주 수요일 00:00 에 실행됩니다. (1:월요일 ~ 6:토요일)

``` $ sh cron.sh week 3 18:00```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매주 수요일 18:00 에 실행됩니다.

``` $ sh cron.sh month```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매달 마지막 날 00:00 에 실행됩니다.

``` $ sh cron.sh month 15```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매달 15일 00:00 에 실행됩니다.

``` $ sh cron.sh month 15 06:00```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매달 15일 06:00 에 실행됩니다.

``` $ sh cron.sh year```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매년 1월 1일 00:00 에 실행됩니다. 

``` $ sh cron.sh year 0306```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매년 3월 6일 00:00 에 실행됩니다. 

``` $ sh cron.sh year 0306 07:48```
- 위와 같이 입력했을 경우, logs_backup 스크립트는 매년 3월 6일 07:48 에 실행됩니다. 



# 스크립트 사용 방법
이제 기능을 사용해봅시다. 

git 명령어를 통해 소스코드를 다운받은 뒤 쉘 스크립트를 동작시켜 봅니다. 

사전에 주의해야 할 사항은 첫번째: SOHA 관련 환경변수들이 설정되었는지 확인합니다. (env.sh 스크립트를 참조하세요.)

두번째: 제발 테스트 환경에서 연습하고 운영 환경에 적용하세요. 이건 파일 내용을 날리는 프로그램이라고요!

## 각각 사용하는 방식
간단합니다. 

원하는 스크립트를 돌려보세요

``` $sh <script_name.sh>```

무엇이든지 결과가 나올겁니다. 

## 같이 사용하는 방식
모든 스크립트들은 서버 디스크 용량 체크 및 백업 디렉토리 생성을 위해 backup_dir_create 스크립트를 호출합니다. 

동일 경로에 두기 바랍니다. 

또한 cron 스크립트는 backup_dir_create 뿐만 아니라 logs_backup 스크립트를 자체적으로 호출하고 있습니다. 

이 때 logs_backup 스크립트 호출은 "not_null" 옵션이 없는 전체 파일을 0 크기로 초기화 하도록 호출되어 크론탭에 등록됩니다. cron 스크립트 동작 후 crontab 리스트를 확인하여 어떻게 등록됐는지 확인 후 필요에 따라 "not_null" 옵션을 추가하세요.

(뭐... 이 프로그램 버전이 추가되면 제가 옵션으로 넣을 수도 있겠지만요.)

``` $ crontab -l```



# 주의사항
## 제발 먼저 테스트 환경에서 돌려보고 운영에 적용하세요.
해당 프로그램은 테스트를 거친 후 나온 제품이긴 하나, 사용자가 동작 방법이 미숙한 상태로 운영에 적용했을 경우 로그가 사라지거나 변경되는 등 치명적인 이슈가 발생할 수 있습니다. 

반드시 테스트 환경에서 해당 스크립트들의 동작을 연습하신 뒤 실제 운영 환경에서 적용하시기 바랍니다. 

제발요.


## 발생할 수 있는 에러
기본적으로 해당 쉘들은 모두 $SOHA_HOME, $SOHA_SVC 환경변수 설정을 확인합니다. 

해당 값들이 없을 경우 쉘은 동작하지 않고 "SOHA_SVC/SOHA_HOME is not set. Aborting backup." 문구를 뱉은 뒤 종료됩니다. 

## 에러 처리 방법
환경변수를 설정하는 방법은 env.sh 스크립트를 확인하고 환경에 맞춰 수정 후 기동합니다. 

그리고 그 외의 에러 발생에 대해서는, 

## 저도 몰라요
속 터지는 얘기겠지만, 사실입니다. 

인지하고 있지 않은 에러가 발생할 경우 모든 걸 다 통제할 순 없습니다. 게다가 문제 상황이 꼭 이 엉터리 스크립트 때문이라고 단정짓기도 어렵습니다.

문제가 발생하면 우선 발생 부분의 스크립트를 직접 수정하여 에러를 구체화 시킨 뒤 그 내용을 구글링하는게 하나의 해답이 될 수 있습니다. 

사용법으로 작성한 내용 이외에 해당 스크립트를 다른 참신한 방식으로 접목시킨 뒤 발생하는 오류에 대해서는 책임질 수 없습니다. 그런 참신한 생각은 어떻게 하신건가요?

추후 내용을 개선해가며 에러 예외처리를 계속 추가해 나갈테니 그 전까지는 정체 불명의 오류가 발생하면 눈물 닦고 사용 시기를 좀 늦춰주시기 바랍니다. 


# 버전이력
1. v1.0 (2023-06-28): 1차 배포
