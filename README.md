# Micro Controller Unit과 AMBA APB
## CPU
### ISA (Instruction Set Architecture)
- CPU 가 인식, 해석, 실행할 수 있는 명령어들의 모음을 명령어 집합(instruction set) 또는 명령어 집합 구조
- 소프트웨어와 하드웨어 사이의 인터페이스

    CISC(Complex Instruction Set Computer)
    - Micro Processor에게 명령을 내리는데 필요한 모든 명령어 셋을 갖추고 있는 Processor

    [장점] 복합적, 높은 하위 호환성, 범용 컴퓨터에 유리
    [단점] 트랜지스터 집적에 있어 낮은 효율성, 큰 전력 소모, 느린 속도, 비싼 가격 등

    RISC(Reduced Instruction Set Computer)
    - CISC에서 전체 80%이상의 일을 처리하는 20%에 해당하는 명령어들만 모아둔 Processor


#### RISC-V
무료 오픈 소스 RISC 명령어셋 아키텍처

RV32I
- RISC-V에서 32비트 기본 정수형(Integer) 명령어 세트를 사용하는 CPU

(싱글 싸이클 프로세서 블록도)

싱글 싸이클 프로세스의 문제점

(멀티 싸이클 프로세스 블록도)

싱글 싸이클 대비 개선점

각 명령어 소개 및 시뮬레이션

## MCU 
작은 규모의 컴퓨터 시스템을 하나의 칩 안에 통합한 장치

CPU, 메모리(RAM, ROM), 주변장치로 구성
- 임베디드 시스템에서 핵심적인 역할을 수행
- 저전력, Peripheral과의 상호 작용이 필요한 시스템에 적합

(mcu 블럭도)


## AMBA APB