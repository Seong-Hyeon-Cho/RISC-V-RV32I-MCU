# Micro Controller Unit
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
무료 오픈 소스 RISC 명령어 셋 아키텍처

##### RV32I
- RISC-V에서 32비트 기본 정수형(Integer) 명령어 세트를 사용하는 CPU

명령어
<br><img width="5109" height="1068" alt="Image" src="https://github.com/user-attachments/assets/3b842944-4fd8-4427-8fa5-7a7477ba75a9" /><br>


※ single cycle processor block diagram
<br><img width="2732" height="2004" alt="Image" src="https://github.com/user-attachments/assets/7d4223de-a22b-4b36-8c39-6ac856836765" /><br>
- 모든 명령어를 처리하는 데 한 시스템 Clock 사이클 안에 처리됨  
[장점] : 단순한 구조   
[단점] : 명령어 중 처리시간이 가장 긴 명령어를 기준으로 최소 Clock 시간이 결정됨  
<처리시간이 긴 이유 = 데이터 흐름 경로가 길기 때문><br>
![Image](https://github.com/user-attachments/assets/62ebdad4-c5aa-490f-a894-0a574ea4e31b)<br>
일부 명령어에서는 처리시간이 일찍 끝나서 시간이 낭비되고 있는 모습   

※ Multi cycle processor block diagram
<br><img width="2700" height="2004" alt="Image" src="https://github.com/user-attachments/assets/621f9e1b-ad60-40ba-8b92-38d76b36e317" /><br>
- 명령어 처리를 여러 사이클동안 진행
- 명령어 하나의 처리시간은 single cycle 대비 느리지만, 전체적인 프로세서의 처리시간은 빠름  
[단점] : 복잡해지는 구조

동작 FSM<br>
<img width="1385" height="913" alt="Image" src="https://github.com/user-attachments/assets/90bddd1c-b8bc-4030-9cb0-ebdaffb311d1" />

각 명령어 소개 및 시뮬레이션
- R-Type
<br><img width="2039" height="925" alt="Image" src="https://github.com/user-attachments/assets/4b144367-5202-48f3-b6db-cfba4bf92d82" /><br>
    - 검증<br><img width="2043" height="929" alt="Image" src="https://github.com/user-attachments/assets/3adbc786-b499-4547-8b5f-8e8e8f1a036f" /><br>

- I-Type<br><img width="2043" height="926" alt="Image" src="https://github.com/user-attachments/assets/757e070b-4235-4dc2-9995-ab9ec1448c70" /><br>
    - 검증<br><img width="2043" height="928" alt="Image" src="https://github.com/user-attachments/assets/e5738170-e55a-4f8f-8dc6-0544fb5147a5" /><br>

- S-Type<br><img width="2043" height="929" alt="Image" src="https://github.com/user-attachments/assets/ba08900c-cb3d-4ca6-ab76-0363b7f9f19c" /><br>
    - 검증<br><img width="2045" height="927" alt="Image" src="https://github.com/user-attachments/assets/97544c22-9cb2-432d-9459-f4a1bf95c4d8" /><br>

- L-Type<br><img width="2044" height="925" alt="Image" src="https://github.com/user-attachments/assets/5d68d802-d995-4153-beec-ba6ed8cbb292" /><br>
    - 검증<br><img width="2043" height="927" alt="Image" src="https://github.com/user-attachments/assets/a5d96097-dfad-449f-acfc-933550be546e" /><br>

- B-Type<br><img width="2044" height="928" alt="Image" src="https://github.com/user-attachments/assets/5e8b929d-a5b4-4d43-9d83-18a5a8c98b01" /><br>
    - 검증<br><img width="2042" height="928" alt="Image" src="https://github.com/user-attachments/assets/2aeaa3b9-f564-465c-b2c7-308eef261d66" /><br>

- LU, AU-Type<br><img width="2044" height="930" alt="Image" src="https://github.com/user-attachments/assets/b7fbc62f-4d72-4d7f-ab83-bd5966af2e37" /><br>
    - 검증<br><img width="2045" height="928" alt="Image" src="https://github.com/user-attachments/assets/83a507c2-178c-4ff1-88d0-0c1ca315fa7c" /><br>

- J,JA-Type<br><img width="2044" height="929" alt="Image" src="https://github.com/user-attachments/assets/2b4151ff-8b54-4aa0-b5f5-69c96b59c7d8" /><br>
    - 검증<br><img width="2046" height="927" alt="Image" src="https://github.com/user-attachments/assets/c9002b03-7a16-4720-8556-5010e78a5c0d" /><br>

## MCU 
작은 규모의 컴퓨터 시스템을 하나의 칩 안에 통합한 장치

CPU, 메모리(RAM, ROM), 주변장치로 구성
- 임베디드 시스템에서 핵심적인 역할을 수행
- 저전력, Peripheral과의 상호 작용이 필요한 시스템에 적합

※ MCU block diagram
<br><img width="3162" height="2264" alt="Image" src="https://github.com/user-attachments/assets/1a9a74c4-2c9e-4efd-ac6f-33ffabad21fa" /><br>
- 실행할 명령어 모음을 미리 ROM에 저장하게 되면 장치를 실행하게 되면 명령어 순서대로 명령을 처리하게 된다.


#### 실행 방법
1. 실행시키고자 하는 프로그램을 프로그래밍 언어(예: C언어)로 작성한다.  https://godbolt.org/ 

```C
void sort(int *pData, int size);
void swap(int *pA, int *pB);

int main(){
    int arData[6] = {5,4,3,2,1};
    
    sort(arData,5);

    return 0;
}

void sort(int *pData, int size)
{
    for(int i=0; i<size;i++){
        for(int j=0;j<size-i-1;j++){
            if (pData[j] > pData[j+1])
            swap(&pData[j],&pData[j+1]);
        }
    }
}

void swap(int *pA, int *pB)
{
    int temp;
    temp = *pA;
    *pA = *pB;
    *pB = temp;
}

```

2. 작성한 코드를 어셈블리어로 변환한다.   https://riscvasm.lucasteske.dev/
<pre><code>        addi    sp,sp,0x64
main:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,10
        sw      a5,-20(s0)
        li      a5,20
        sw      a5,-24(s0)
        lw      a1,-24(s0)
        lw      a0,-20(s0)
        call    adder
        sw      a0,-28(s0)
        li      a5,0
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
adder:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        sw      a1,-24(s0)
        lw      a4,-20(s0)
        lw      a5,-24(s0)
        add     a5,a4,a5
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
</code></pre>

3. 어셈블리어를 기계어로 번역한다.
<pre><code>04000113
fe010113
00112e23
00812c23
02010413
00a00793
fef42623
01400793
fef42423
fe842583
fec42503
020000ef
fea42223
00000793
00078513
01c12083
01812403
02010113
00008067
fe010113
00112e23
00812c23
02010413
fea42623
feb42423
fec42703
fe842783
00f707b3
00078513
01c12083
01812403
02010113
00008067
</code></pre>
4. 기계어를 ROM에 저장한다.


MCU 실행 결과<br>
<img width="2046" height="930" alt="Image" src="https://github.com/user-attachments/assets/918094b1-eeef-486c-af6e-419c76daff0b" /><br>

### BUS
- 데이터를 전송하는 통신 시스템

#### AMBA (Advanced Microcontroller Bus Architecture)
- ARM사에서 개발한 칩 내부의 IP 코어들을 연결하고 통신하기 위한 표준 버스 아키텍처입니다.   
- SoC 설계에서 프로세서, 메모리, 주변 장치 간의 통신을 효율적으로 관리하기 위해 사용된다.   


##### APB (Advanced Peripheral Bus)
- 용도: 저속·저전력 레지스터 접근(GPIO, 타이머, UART 등 주변장치 CSR)
- 구조: 단순 동기식, 파이프라이닝/버스트/스플릿 없음.
- 핸드셰이크: 2-phase 타이밍
    - SETUP: PSEL=1, PENABLE=0, PADDR/PWRITE/PWDATA 유효
    - ACCESS: PENABLE=1로 전환, 슬레이브가 PREADY로 완료 알림
- 주요 신호: PCLK, PADDR, PSEL, PENABLE, PWRITE, PWDATA, PRDATA, PREADY, PSLVERR
- 특징: 단일 전송, 낮은 복잡도, 구현/검증 쉬움, 대역폭 낮지만 지연 일정.

[APB 타이밍다이어그램]   
<img width="520" height="230" alt="Image" src="https://github.com/user-attachments/assets/8405201f-58ff-4d76-80f0-657631d8bc63" >   

[인터페이스]   
<img width="727" height="645" alt="Image" src="https://github.com/user-attachments/assets/95ac4d0b-5f81-4a56-8d3d-8e2a99f39083" /><br>
<img width="397" height="380" alt="Image" src="https://github.com/user-attachments/assets/904cbc1e-dfce-499a-83ea-c39697c07f6b" /><br>

[시뮬레이션]   
<img width="1163" height="476" alt="Image" src="https://github.com/user-attachments/assets/78242cb6-db2f-4446-8be9-4e2c177adac5" /><br>

##### AXI (Advanced eXtensible Interface)
- 용도: 고대역폭 메모리-맵드(DDR, 큰 버퍼, DMA)와 제어 레지스터(AXI4-Lite).
- 채널 분리(5채널):
    - 주소: AW(write addr), AR(read addr)
    - 데이터/응답: W(write data), B(write resp), R(read data)   
        각 채널이 VALID/READY 핸드셰이크로 독립 동작 → 고효율 파이프라인
- 버스트/동시성: 버스트 전송, 여러 outstanding 트랜잭션, ID 기반 재정렬/인터리빙 가능
- 변종:
    - AXI4: 버스트 지원, 데이터폭/ID/캐시·QoS 신호 등 풍부
    - AXI4-Lite: 단일 비트(버스트 없음) → CSR용, APB 대체로 자주 사용
    - AXI4-Stream: 주소 없음, 순수 스트리밍(영상/FFT 등 데이터 스트림)
- 특징: 높은 처리량, 낮은 지연(백프레셔 대응), 복잡도·자원 소모 큼.

[AXI4-Lite 타이밍다이어그램]   
<img width="620" height="696" alt="Image" src="https://github.com/user-attachments/assets/372e8cc1-4acc-4fff-8ed1-96011de81854" /><br>

[인터페이스]   
<img width="450" height="226" alt="Image" src="https://github.com/user-attachments/assets/ee35b190-875d-4590-800d-a44bf9138c3b" /><br>

[아키텍처]<br>
<img width="1848" height="701" alt="Image" src="https://github.com/user-attachments/assets/08bdbb68-8f10-4ece-a557-de8a9ea70c92" /><br>

[시뮬레이션]    
<img width="1115" height="462" alt="Image" src="https://github.com/user-attachments/assets/d67f5cc3-fa47-4cc2-bbab-4fabacfb3119" />