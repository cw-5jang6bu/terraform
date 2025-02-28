# Terraform

## 주요 기능

#### VPC 구성
- ap-northeast-2 리전에서 두 AZ에 각각 Public subnet 1개와 EKS+Elasticache 전용 Private subnet와 Aurora 전용 Private subnet 생성

#### Module 구성
- 두 AZ에 각각 EKS, Elaticache, RDS 구성을 Module을 통해 자동화

###### EKS
- EKS를 두 AZ의 EKS+Elasticache 전용 Private subnet에 걸쳐서 생성

###### Aurora
- Aurora를 두 AZ의 Aurora 전용 Private subnet에 한 개의 Primary와 한 개의 Replica로 생성

#### 관련 사진 첨부

![image](https://github.com/user-attachments/assets/8a736b7c-2456-444d-971d-3e3bf5ea4307)
