; Archivo: main.s
; Dispositivo: PIC16F887
; Autor: Gabriel Fong
; Compilador: pic-as (v2.30), MPLABX V5.40
; 
; Programa: CONTADOR DISPALY
; Hardware: PUSH EN EL PUERTO A, LEDs en puerto C,DISPLAY EN ELPUERTO D
;
; Creado: 15 feb, 2021
; Última modificación: 15 feb, 2021

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

   PSECT udata_bank0		;common memory
    FLAG: DS 1			;BANDERA DE 1 BYTE
    CONT: DS 1			;CONTEO DE 1 BYTE
    TABLA: DS 1			;TABLA DE 1 BYTE

  PSECT resVect, class=CODE, abs, delta=2

;-------------------------VECTOR RESET ----------------------------------------
  ORG 00h			;posición 0000h para el reset
  resetVec:
    PAGESEL main
    goto main
    
  PSECT code, delta = 2, abs
  ORG 100h			; posición para el código
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
 RETLW	    01110001B		;DIGITO F
;-------------------------CONFIGURACIÓN- --------------------------------------
 main:
    CALL    CONFIG_R
    CALL    CONFIG_IO 
    CALL    CONFIG_TMR0
;-------------------------LOOP PRINCIPAL --------------------------------------
loop:
    BTFSS   INTCON, 2		;REVISAMOS QUE T0IF SE ACTIVE
    GOTO    loop
    CALL    CONT_LED		;LLAMAMOS A LA SUBRUTINA PARA CONTAR
    BTFSC   PORTA,  0
    CALL    ANTI_REB1
    BTFSS   PORTA,  0
    CALL    INC_DISPLAY
    BTFSC   PORTA,  1
    CALL    ANTI_REB2
    BTFSS   PORTA,  1
    CALL    DEC_DISPLAY
    GOTO    loop
;-----------------------SUB RUTINAS DE CONFIGURACION ---------------------------   
CONFIG_R:
    BANKSEL OSCCON
    BSF	    SCS
    RETURN
CONFIG_IO:			;CONFIGURACION DE PUERTOS
    BANKSEL ANSEL
    clrf    ANSEL		;PINES DIGITALES EN EL PUERTO A
    clrf    ANSELH		;PINES DIGITALES EN EL PUERTO B
    
    BANKSEL TRISA		;LLAMAMOS AL BANCO EN DONDE SE ENCUENTRA TRIS
    BSF	    TRISA, 0		;PIN TRISA0 COMO INPUT (PUSH1)
    BSF	    TRISA, 1		;PIN TRISA1 COMO INPUT (PUSH2)
    CLRF    TRISC		;COLOCAMOS EL PUERTO C COMO OUTPUT
    CLRF    TRISD		;COLOCAMOS EL PUERTO D COMO OUTPUT
    
    BANKSEL PORTA
    CLRF    PORTA		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO A
    CLRF    PORTB		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO B
    CLRF    PORTC		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO C
    CLRF    PORTD
    MOVF    00111111B,	W
    MOVLW   PORTD		;COLOCAMOS DIGITO 0 PUERTO D
    CLRF    TABLA
    RETURN
    
CONFIG_TMR0:			;CONFIGURACION DE TMR0
    CLRWDT			;LIMPIA EL WDT  Y PRESCALADOR
    BANKSEL OPTION_REG		;NOS DIRIGIMOS A CONFIGURAR OPTION REG DEL TIMER0
    MOVLW   11010000B		;SELECCIONAMOS SÓLO LOS BITS PSA,PS2,PS1,PS0, TOSC
    ANDWF   OPTION_REG,	W	;Y LOS DEMAS LOS PONEMOS EN 0
    IORLW   00000010B		; PRESCALADOR EN 1:8 (TMR0 EN 125)
    MOVWF   OPTION_REG  
    
   BANKSEL  TMR0
    MOVLW   4
    MOVWF   TMR0		;LE COLOCAMOS 131, PARA LUEGO OBTENER 2 ms
    BCF	    INTCON, 2		;LIMPIAMOS NUESTRA BANDERA DE T0IF  
    RETURN
;----------------------SUB RUTINAS DE FUNCIONES ---------------------------------  
 CONT_LED:
    MOVLW   250			;VALOR INICIAL DEL CONTADOR, NECESITO QUE SE REPITA 250 VECES 
    MOVWF   CONT		;PARA OBTENER LOS 500ms
    BTFSS   INTCON, 2		;SI LA BANDERA TMR0 ESTA EN 1 SKIP
    GOTO    $-1			;REGRESAMOS UNA LINEA
    CALL    REINICIO_TMR0	;LLAMAMOS A LA SUBRUTINA DE REINICIO
    DECFSZ  CONT, 1		;DECREMENTAR EL CONTADOR
    GOTO    $-4			;EJECUTAR 4 LINEAS ANTES PARA REALIZAR LAS 250 VECES
    INCF    PORTC,  F		;INCREMENTAMOS UN BIT EN PORTC
    BTFSC   PORTC,  4		;SI EL BIT 5 DE PORTC ES 1
    CLRF    PORTC		;CLEAR PORTC
    RETURN
 
 REINICIO_TMR0:			;TEMPORIZACION 2ms
    MOVLW   6			;(256-N) N = 6
    MOVWF   TMR0		;LE COLOCAMOS 131, PARA LUEGO OBTENER 2 ms
    BCF	    INTCON, 2		;LIMPIAMOS NUESTRA BANDERA DE T0IF, PARA QUE 
    RETURN
 
 ANTI_REB1:			;ANTIREBOTE PUSH PORTA0
    BSF	    FLAG,   0
    RETURN
 
 INC_DISPLAY:
    BTFSS   FLAG,   0
    RETURN
    INCF    TABLA,  1
    MOVF    TABLA,  0
    CALL    TABLA_DISPLAY
    MOVWF   PORTD
    CLRF    FLAG
    RETURN
 ANTI_REB2:			;ANTIREBOTE PUSH PORTA1
    BSF	    FLAG,   1
    RETURN
    
 DEC_DISPLAY:
    BTFSS   FLAG,   1
    RETURN
    DECF    TABLA,  1
    MOVF    TABLA,  0
    CALL    TABLA_DISPLAY
    MOVWF   PORTD
    CLRF    FLAG
    RETURN
 