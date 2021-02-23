; Archivo: main.s
; Dispositivo: PIC16F887
; Autor: Gabriel Fong
; Compilador: pic-as (v2.30), MPLABX V5.40
; 
; Programa: CONTADOR DISPALY
; Hardware: PUSH EN EL PUERTO A, LEDs en puerto C,DISPLAY 7 SEGEMENTOS EN EL PUERTO D
;
; Creado: 15 feb, 2021
; Última modificación: 18 feb, 2021

PROCESSOR 16F887
#include <xc.inc>
 
;---------------------CONFIGURATION WORDS --------------------------------------
   
; CONFIGURATION WORD 1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
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
  
  UP	EQU 0
  DOWN  EQU 7
  
   PSECT udata_bank0		;common memory
    W_TEMP: DS 1		;BANDERA DE 1 BYTE
    STAT_TEMP: DS 1
    CONT: DS 1			;CONTEO DE 1 BYTE
    TABLA: DS 1			;TABLA DE 1 BYTE

  PSECT resVect, class=CODE, abs, delta=2

;-------------------------VECTOR RESET ----------------------------------------
  ORG 00h			;posición 0000h para el reset
  resetVec:
    PAGESEL main
    goto main
 PSECT	intVect,    class=CODE,	abs, delta=2
;-------------------------VECTOR INTERRUPT -------------------------------------  
 ;PSECT interruptVector, delta = 2 ;Posicion 004
 ORG	04h
 PUSH:
    BCF	    INTCON, 7		;DESACTIVAMOS LAS INTERRUPCIONES, PARA QUE NO SE CRUCEN ENTRE ELLAS
    MOVWF   W_TEMP		;GUARDAMOS EL VALOR EN W
    SWAPF   STATUS, W		;GUARDA STATUS EN W, (NO AFECTAMOS LAS BANDERAS)
    MOVWF   STAT_TEMP		;GUARDA W EN LA VARIABLE TEMPORAL
    
 ISR:
    BTFSC   RBIF
    CALL    INC_LED
  
 POP:
    SWAPF   STAT_TEMP, W	;REGRESAMOS DE NUEVO EL VALOR COMO SE ENCONTRABA ANTES
    MOVWF   STATUS		;LO COLOCAMOS EN STATUS
    SWAPF   W_TEMP, F		;CAMBIAMOS LOS NIBLES DE WTEMP
    SWAPF   W_TEMP, W		;REGRESAMOS SU VALOR EL VALOR INICIAL
    RETFIE			;VUELVE ACTIVAR EL GIE
    
/* PSECT code, delta = 2, abs
  TABLA_DISPLAY:
 CLRF	    PCLATH
 BSF	    PCLATH, 0		;PCLATH 01
 ADDWF	    PCL			;PROGRAM COUNTER = PCLATH + PC + W
 ANDLW	    0X0F		;SOLO DEJA CONTAR HASTA 16 DIGITOS
 RETLW	    00111111B		;DIGITO 0
 RETLW	    00000110B		;DIGITO 1
 RETLW	    01011011B		;DIGITO 2
 RETLW	    01001111B		;DIGITO 3
 RETLW	    01100110B		;DIGITO 4
 RETLW	    01101101B		;DIGITO 5
 RETLW	    01111101B		;DIGITO 6
 RETLW	    00000111B		;DIGITO 7
 RETLW	    01111111B		;DIGITO 8
 RETLW	    01100111B		;DIGITO 9
 RETLW	    01110111B		;DIGITO A
 RETLW	    01111100B		;DIGITO B
 RETLW	    00111001B		;DIGITO C
 RETLW	    01011110B		;DIGITO D
 RETLW	    01111001B		;DIGITO E
 RETLW	    01110001B		;DIGITO F */

;-------------------------CONFIGURACIÓN- --------------------------------------
 main:
    CALL    CONFIG_R		;CONFIGURACION DEL RELOJ OSCILADOR
    CALL    CONFIG_IO		;CONFIGURACION DE PUERTOS
    CALL    CONFIG_TMR0		;CONFIGURACION DE TMR0
    CALL    CONFIG_IOCRB
    CALL    CONFIG_INT_ENABLE
    
 LOOP:
    GOTO    LOOP
;-----------------------SUB RUTINAS DE CONFIGURACION ---------------------------   
CONFIG_R:
    BANKSEL OSCCON		;RELOJ INTERNO
    BSF	    SCS
    RETURN
CONFIG_IO:			;CONFIGURACION DE PUERTOS
    BANKSEL ANSEL
    clrf    ANSEL		;PINES DIGITALES EN EL PUERTO A
    clrf    ANSELH		;PINES DIGITALES EN EL PUERTO B
    
    BANKSEL TRISA		;LLAMAMOS AL BANCO EN DONDE SE ENCUENTRA TRIS
    CLRF    TRISA  		;COLOCAMOS EL PUERTO A COMO OUTPUT
    BSF	    TRISB,  UP
    BSF	    TRISB,  DOWN
    CLRF    TRISC		;COLOCAMOS EL PUERTO C COMO OUTPUT
    CLRF    TRISD		;COLOCAMOS EL PUERTO D COMO OUTPUT
    BCF	    TRISE,  0		;PORTE0 COMO SALIDA DE LED DE ALARMA
    BSF	    WPUB,   UP		;COLOCAMOS UP & DOWN COMO ENTRADAS Y PINES EN PULL  UP
    BSF	    WPUB,   DOWN
    
    BANKSEL PORTA
    CLRF    PORTA		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO A
    CLRF    PORTB		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO B
    CLRF    PORTC		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO C
    CLRF    PORTD		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO C
    MOVLW   00111111B
    MOVWF   PORTD		;COLOCAMOS DIGITO 0 PUERTO D
    CLRF    TABLA
    RETURN
    
CONFIG_TMR0:			;CONFIGURACION DE TMR0
    CLRWDT			;LIMPIA EL WDT  Y PRESCALADOR
    BANKSEL OPTION_REG		;NOS DIRIGIMOS A CONFIGURAR OPTION REG DEL TIMER0
    MOVLW   01010000B		;SELECCIONAMOS SÓLO LOS BITS PSA(0),PS2,PS1,PS0, TOSC(0), a RBPU(0)
    ANDWF   OPTION_REG,	W	;Y LOS DEMAS LOS PONEMOS EN 0
    IORLW   00000010B		; PRESCALADOR EN 1:8 (TMR0 EN 125)
    MOVWF   OPTION_REG  
    
   BANKSEL  TMR0
    MOVLW   4
    MOVWF   TMR0		;LE COLOCAMOS 4, PARA LUEGO OBTENER 2 ms
    BCF	    INTCON, 2		;LIMPIAMOS NUESTRA BANDERA DE T0IF  
    RETURN
    
 CONFIG_INT_ENABLE:
    BSF	    GIE
    BSF	    RBIE
    BCF	    RBIF
    RETURN
 CONFIG_IOCRB:
    BANKSEL TRISA
    BSF	    IOCB,   UP
    BSF	    IOCB,   DOWN
    
    BANKSEL PORTA
    MOVF    PORTB,  W
    BCF	    RBIF
    RETURN
 INC_LED:
    BTFSS   PORTB,   UP		;MIRAMOS QUE LA BANDERA ESTE ACTIVA
    INCF    PORTA  		;INCREMENTAMOS EN PORTA
    BTFSS   PORTB,  DOWN		;MOVEMOS EL VALOR DE TABLA A W
    DECF    PORTA
    BTFSC   PORTA,  4
    CLRF    PORTA
    BCF	    RBIF
    RETURN