# SOHA_logBackup_errIntegrated
SOHA system log: backup &amp; error part integraged bash shell script


# 기본 소개
<2023-06.v1.0>

해당 쉘 스크립트 프로그램은 SOHA의 자체적으로 떨어지는 시스템로그를 백업 및 로그 내용/에러 내용 추출하여 통합 파일로 생성하는데 목적을 둡니다. 

기본 설정값은 모두 SOHA가 설치된 환경을 기준으로 되어있으므로, 여타 다른 시스템이 적용하시려면 스크립트의 내용을 적절하게 수정하여 사용하시기 바랍니다. 

스크립트 내용이 비효율적이고 복잡하기 때문에 이해하기 어려울 수 있습니다. 슬프게도 알고있습니다. 

추후 실력이 늘면 차차 수정/개선할 예정이므로 지금은 일단 넘어가주시기 바랍니다. 

사용 용도에 따라 아래의 쉘을 단품 사용 혹은 교차 사용이 가능합니다. 

1. SOHA 시스템 로그 내용 지우고 기존 내용 압축 백업 - logs_backup
2. SOHA 시스템 로그 내용을 하나의 파일에 전체 출력해서 확인하기 - error_integrated
3. 로그 백업 스크립트를 주기적으로 스케줄링 걸어놓기 - cron

사용하고자 하는 목적에 따라 선택하여 운용합니다. 

# 스크립트 설명

![image](https://github.com/hyewonLeeSinsiway/SOHA_logBackup_errIntegrated/assets/62870767/cd3b05eb-d8a5-4a0f-aaaa-e4c7b5aabbf0)

## 0. backup_dir_create
해당 스크립트는 프로그램을 어느 방향으로 사용하시든간에 반드시 필요합니다. 

사용하려는 스크립트와 동일한 경로에 위치시킵니다. 



### 함수 목록
1. check_disk_space()
- 서버 디스크 용량을 확인합니다.
2. create_backup_dir()

### 사용법



## 1. logs_backup



## 2. error_integrated


## 3. cron


# 사용 방법
## 각각 사용하는 방식
## 같이 사용하는 방식


# 주의사항
## 발생할 수 있는 에러
## 에러 처리 방법
## 저도 몰라요
속 터지는 얘기겠지만, 사실입니다. 

인지하고 있지 않은 에러가 발생할 경우 모든 걸 다 통제할 순 없습니다. 게다가 문제 상황이 꼭 이 엉터리 스크립트 때문이라고 단정짓기도 어렵습니다.

문제가 발생하면 우선 발생 부분의 스크립트를 직접 수정하여 에러를 구체화 시킨 뒤 그 내용을 구글링하는게 하나의 해답이 될 수 있습니다. 

사용법으로 작성한 내용 이외에 해당 스크립트를 다른 참신한 방식으로 접목시킨 뒤 발생하는 오류에 대해서는 책임질 수 없습니다. 그런 참신한 생각은 어떻게 하신건가요?

추후 내용을 개선해가며 에러 예외처리를 계속 추가해 나갈테니 그 전까지는 정체 불명의 오류가 발생하면 눈물 닦고 사용 시기를 좀 늦춰주시기 바랍니다. 


# 버전이력

