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
    BANKSEL PORTA
    clrf    PORTA		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO A
    clrf    PORTB		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO B
    clrf    PORTC		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO C
    clrf    PORTD		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO D
    
    banksel TRISA		;LLAMAMOS AL BANCO EN DONDE SE ENCUENTRA TRIS
    BSF	    TRISA, 0		;PIN TRISA0 COMO INPUT (PUSH1)
    BSF	    TRISA, 1		;PIN TRISA1 COMO INPUT (PUSH2)
    clrf    TRISC		;COLOCAMOS EL PUERTO C COMO OUTPUT
    clrf    TRISD		;COLOCAMOS EL PUERTO D COMO OUTPUT
    CLRWDT			;LIMPIA EL WDT  Y PRESCALADOR
    
    BANKSEL OPTION_REG		;NOS DIRIGIMOS
    MOVLW   11010000B		;SELECCIONAMOS SÓLO LOS BITS PSA,PS2,PS1,PS0, TOSC
    ANDWF   OPTION_REG,	W	;Y LOS DEMAS LOS PONEMOS EN 0
    IORLW   00000010B		; PRESCALADOR EN 1:8 (TMR0 EN 125)
    MOVWF   OPTION_REG
    

