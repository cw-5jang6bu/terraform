# Terraform

## VPC 구성
- ap-northeast-2 리전에서 두 AZ에 각각 Public subnet 1개와 EKS+Elasticache 전용 Private subnet와 Aurora 전용 Private subnet 생성
- Public subnet에 NAT Gateway를 생성
- 각 subnet과 module의 security group 구성

## Module 구성
- 두 AZ에 각각 EKS, Elaticache, RDS 구성을 Module을 통해 자동화
- depend on을 이용해 각 서비스의 구축 순서를 정함

#### EKS
- EKS를 두 AZ의 EKS+Elasticache 전용 Private subnet에 걸쳐서 생성

#### Elasticache
- Elasticache를 두 AZ의 EKS+Elasticache 전용 Private subnet에 각각 생성

#### Aurora
- Aurora를 두 AZ의 Aurora 전용 Private subnet에 한 개의 Primary와 한 개의 Replica로 생성

## 관련 사진 첨부
- 전체 인프라

![image](https://github.com/user-attachments/assets/8a736b7c-2456-444d-971d-3e3bf5ea4307)

- 구성 순서 플로우

![image](https://github.com/user-attachments/assets/29ce3bbf-e02b-472e-944f-730fc16ad3c7)

