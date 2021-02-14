; Archivo: main.s
; Dispositivo: PIC16F887
; Autor: Gabriel Fong
; Compilador: pic-as (v2.30), MPLABX V5.40
; 
; Programa: CONTADOR
; Hardware: PUSH EN EL PUERTO A, LEDs en puerto B,C, SUMADOR EN EL D
;
; Creado: 9 feb, 2021
; Última modificación: 13 feb, 2021

PROCESSOR 16F887
#include <xc.inc>

;---------------------CONFIGURATION WORDS --------------------------------------
   
; CONFIGURATION WORD 1
  CONFIG  FOSC = INTRC_NOCLKOUT		; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disable
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIGURATION WORD 2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

  PSECT udata_bank0		;common memory
    FLAG: DS 1			;BANDERA DE 1 BYTE

  PSECT resVect, class=CODE, abs, delta=2

;-------------------------VECTOR RESET ----------------------------------------
  ORG 00h			;posición 0000h para el reset
  resetVec:
    PAGESEL main
    goto main
    
  PSECT code, delta = 2, abs
  ORG 100h			; posición para el código
 ;-------------------------CONFIGURACIÓN- --------------------------------------
 main:
    BANKSEL ANSEL
    clrf    ANSEL		;PINES DIGITALES EN EL PUERTO A
    clrf    ANSELH		;PINES DIGITALES EN EL PUERTO B
    
    banksel TRISA		;LLAMAMOS AL BANCO EN DONDE SE ENCUENTRA TRIS
    bsf	    TRISA,  0		;COLOCAMOS EL PIN 0 DE PORTA COMO INPUT
    bsf	    TRISA,  1		;COLOCAMOS EL PIN 1 DE PORTA COMO INPUT
    bsf	    TRISA,  2		;COLOCAMOS EL PIN 2 DE PORTA COMO INPUT
    bsf	    TRISA,  3		;COLOCAMOS EL PIN 3 DE PORTA COMO INPUT
    bsf	    TRISA,  4		;COLOCAMOS EL PIN 4 DE PORTA COMO INPUT
    clrf    TRISB		;COLOCAMOS EL PUERTO B COMO OUTPUT
    clrf    TRISC		;COLOCAMOS EL PUERTO C COMO OUTPUT
    clrf    TRISD		;COLOCAMOS EL PUERTO D COMO OUTPUT
    
    bcf	    STATUS, 5		;BANCO 00
    bcf	    STATUS, 6
    clrf    PORTA		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO A
    clrf    PORTB		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO B
    clrf    PORTC		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO C
    clrf    PORTD		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO D
  
;-------------------------LOOP PRINCIPAL --------------------------------------
loop:
    btfsc   PORTA, 0		;SI EL PIN 0 DEL PORTA ES 0 SKIP LA FUNCION CALL
    call    antireb1		;LLAMAMOS A LA SUBRUTINA antireb1
    btfss   PORTA,   0		;SI EL PIN 0 DEL PORTA SIGUE EN 1 SKIP LA FUNCION CALL DE INCREMENTAR B
    call    inc_portb		;LLAMAMOS A LA SUBRUTINA inc_portb
    
    btfsc   PORTA,  1		;SI EL PIN 1 DEL PORTA ES 0 SKIP LA FUNCION CALL
    call    antireb2 		;LLAMAMOS A LA SUBRUTINA antireb2
    btfss   PORTA,  1		;SI EL PIN 1 DEL PORTA SIGUE EN 1 SKIP LA FUNCION CALL DE DECREMENTAR B
    call    dec_portb		;LLAMAMOS A LA SUBRUTINA dec_portb
    
    btfsc   PORTA,  2		;SI EL PIN 2 DEL PORTA ES 0 SKIP LA FUNCION CALL
    call    antireb3		;LLAMAMOS A LA SUBRUTINA antireb3
    btfss   PORTA,  2		;SI EL PIN 2 DEL PORTA SIGUE EN 1 SKIP LA FUNCION CALL DE INCREMENTAR C
    call    inc_portc		;LLAMAMOS A LA SUBRUTINA inc_portc
    
    btfsc   PORTA,  3		;SI EL PIN 3 DEL PORTA ES 0 SKIP LA FUNCION CALL
    call    antireb4		;LLAMAMOS A LA SUBRUTINA antireb4
    btfss   PORTA,  3		;SI EL PIN 3 DEL PORTA SIGUE EN 1 SKIP LA FUNCION CALL DE DECREMENTAR C
    call    dec_portc		;LLAMAMOS A LA SUBRUTINA dec_portc
    
    btfsc   PORTA,  4		;SI EL PIN 4 DEL PORTA ES 0 SKIP LA FUNCION CALL
    call    antireb5		;LLAMAMOS A LA SUBRUTINA antireb5
    btfss   PORTA,  4		;SI EL PIN 4 DEL PORTA SIGUE EN 1 SKIP LA FUNCION CALL DE SUMAR
    call    suma_bc		;LLAMAMOS A LA SUBRUTINA suma_bc
    goto    loop
    
antireb1:			;SUBRUTINA DE ANTIREBOTE EN PORTA0
    bsf   FLAG,   0		;EL FLANCO POSITIVO DE PIN PORTA0 ACTIVA LA BANDERA
    return
    
inc_portb:			;SUBRUTINA INCREMENTO PORTB
    btfss   FLAG, 0		;SI LA BANDERA0 ES 1 SKIP RETURN
    return
    incf    PORTB, F		;INCREMENTAMOS UN BIT EN PORTB
    btfsc   PORTB, 4		;SI PORTB4 (5 BIT) ES 1 SIGNIFICA QUE SE DESBORDO
    clrf    PORTB		;ENTONCES COLOCAMOS EN 0 EL PORTB
    clrf    FLAG		;COLOCAMOS LA BANDERA EN 0
    return			;REGRESAMOS AL LOOP
    
antireb2:			;SUBRUTINA DE ANTIREBOTE EN PORTA1
    bsf   FLAG,   1		;EL FLANCO POSITIVO DE PIN PORTA1 ACTIVA LA BANDERA
    return			;REGRESAMOS AL LOOP
    
dec_portb:			;SUBRUTINA DECREMENTO PORTB
    btfss   FLAG, 1		;SI LA BANDERA1 ES 1 SKIP RETURN
    return
    decf    PORTB, F		;DECREMENTAMOS UN BIT EN PORTB
    MOVLW   00001111B		;CARGAMOS EL VALOR A W
    btfsc   PORTB, 7		;LEEMOS EL ULTIMO BIT DE B
    MOVWF   PORTB		;SET EN LOS PRIMEROS 4 BITS DEL PUERTO B
    clrf    FLAG		;COLOCAMOS LA BANDERA EN 0
    return			;REGRESAMOS AL LOOP

antireb3:			;SUBRUTINA DE ANTIREBOTE EN PORTA2
    bsf   FLAG,   2		;EL FLANCO POSITIVO DE PIN PORTA2 ACTIVA LA BANDERA
    return			;REGRESAMOS AL LOOP
    
inc_portc:			;SUBRUTINA INCREMENTO PORTC
    btfss   FLAG, 2		;SI LA BANDERA2 ES 1 SKIP RETURN
    return
    incf    PORTC, F		;INCREMENTAMOS UN BIT EN PORTC
    btfsc   PORTC, 4		;SI PORTC4 (5 BIT) ES 1 SIGNIFICA QUE SE DESBORDO
    clrf    PORTC		;LIMPIAMOS EL PUERTO PARA EVITAR DESBORDE
    clrf    FLAG		;COLOCAMOS LA BANDERA EN 0
    return			;REGRESAMOS AL LOOP
    
antireb4:			;SUBRUTINA DE ANTIREBOTE EN PORTA3
    bsf   FLAG,   3		;EL FLANCO POSITIVO DE PIN PORTA3 ACTIVA LA BANDERA
    return			;REGRESAMOS AL LOOP
    
dec_portc:			;SUBRUTINA DECREMENTO PORTC
    btfss   FLAG, 3		;SI LA BANDERA3 ES 1 SKIP RETURN
    return
    decf    PORTC, F		;DECREMENTAMOS UN BIT EN PORTC
    MOVLW   00001111B		;CARGAMOS EL VALOR A W
    btfsc   PORTC, 7		;LEEMOS EL ULTIMO BIT DE C
    MOVWF   PORTC		;SET EN LOS PRIMEROS 4 BITS DEL PUERTO B
    clrf    FLAG		;COLOCAMOS LA BANDERA EN 0
    return			;REGRESAMOS AL LOOP

antireb5:			;SUBRUTINA DE ANTIREBOTE EN PORTA4
    bsf   FLAG,   4		;EL FLANCO POSITIVO DE PIN PORTA4 ACTIVA LA BANDERA
    return			;REGRESAMOS AL LOOP
    
 suma_bc:			;SUBRUTINA SUMA DE PORTB & PORTC EN PORTD
    btfss   FLAG,  4		;SI LA BANDERA4 ES 1 SKIP RETURN
    return
    MOVF    PORTB, 0		;CARGAMOS EL VALOR DE PORTB A F
    ADDWF   PORTC, 0		;SUMAMOS EL VALOR DE C Y EN F A W
    MOVWF   PORTD		;COLOCAMOS EL VALOR DE W EN PORTD
    clrf    FLAG		;COLOCAMOS LA BANDERA EN 0
    return			;REGRESAMOS AL LOOP