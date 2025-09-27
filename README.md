# Micro Controller Unit과 AMBA APB
## CPU
### ISA (Instruction Set Architecture)
- CPU 가 인식, 해석, 실행할 수 있는 명령어들의 모음을 명령어 집합(instruction set) 또는 명령어 집합 구조
- 소프트웨어와 하드웨어 사이의 인터페이스

   ##### CISC(Complex Instruction Set Computer)
    - Micro Processor에게 명령을 내리는데 필요한 모든 명령어 셋을 갖추고 있는 Processor

    [장점] 복합적, 높은 하위 호환성, 범용 컴퓨터에 유리
    [단점] 트랜지스터 집적에 있어 낮은 효율성, 큰 전력 소모, 느린 속도, 비싼 가격 등

   ##### RISC(Reduced Instruction Set Computer)
    - CISC에서 전체 80%이상의 일을 처리하는 20%에 해당하는 명령어들만 모아둔 Processor


#### RISC-V
무료 오픈 소스 RISC 명령어셋 아키텍처

##### RV32I
- RISC-V에서 32비트 기본 정수형(Integer) 명령어 세트를 사용하는 CPU

명령어 소개
(표)

※ single cycle processor block diagram
<br><img width="2732" height="2004" alt="Image" src="https://github.com/user-attachments/assets/7d4223de-a22b-4b36-8c39-6ac856836765" /><br>
- 모든 명령어를 처리하는 데 한 시스템 Clock 사이클 안에 처리됨   
[단점] : 명령어 중 처리시간이 가장 긴 명령어를 기준으로 최소 Clock 시간이 결정됨  
<처리시간이 긴 이유 = 데이터 흐름이 길기 때문(?)><br>
![Image](https://github.com/user-attachments/assets/62ebdad4-c5aa-490f-a894-0a574ea4e31b)<br>
일부 명령어에서는 처리 시간이 일찍 끝나서 시간이 낭비되고 있는 모습

※ Multi cycle processor block diagram
<br><img width="2700" height="2004" alt="Image" src="https://github.com/user-attachments/assets/621f9e1b-ad60-40ba-8b92-38d76b36e317" /><br>
- 명령어 처리를 여러 사이클동안 진행
- 명령어 하나의 처리 시간은 single cycle 대비 느리지만, 전체적인 프로세서의 처리 시간은 빠름

동작 FSM<br>
<img width="1385" height="913" alt="Image" src="https://github.com/user-attachments/assets/90bddd1c-b8bc-4030-9cb0-ebdaffb311d1" />

각 명령어 소개 및 시뮬레이션

## MCU 
작은 규모의 컴퓨터 시스템을 하나의 칩 안에 통합한 장치

CPU, 메모리(RAM, ROM), 주변장치로 구성
- 임베디드 시스템에서 핵심적인 역할을 수행
- 저전력, Peripheral과의 상호 작용이 필요한 시스템에 적합

(mcu 블럭도)


## AMBA APB
