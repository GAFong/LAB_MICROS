; Archivo: main.s
; Dispositivo: PIC16F887
; Autor: Gabriel Fong
; Compilador: pic-as (v2.30), MPLABX V5.40
; 
; Programa: PROYECTO
; Hardware: 3 PUSH EN EL PUERTO B, DISPLAY 7 SEGEMENTOS EN EL PUERTO C, LEDS EN EL PUERTO A & E & RB7, CONTROL DE TRANSISTORES PUERTO D
;
; Creado: 14 de marzo, 2021
; Última modificación: 17 de marzo, 2021

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


 ;PARA VER LAS VARIABLE EN MPLAB
 INC	 EQU 0			;PUSH
 DECR	 EQU 1
 MODO	 EQU 2
	 
ROJO1	EQU 0			;LEDS DE SEMAFORO 1
AMA1	EQU 1
VER1	EQU 2	
	
ROJO2	EQU 3			;LEDS DE SEMAFORO 2
AMA2	EQU 4
VER2	EQU 5	
	
ROJO3	EQU 6			;LEDS DE SEMAFORO 3
AMA3	EQU 7
VER3	EQU 7
	
  GLOBAL    W_TEMP, TVIA1, TVIA2, TVIA3, DECENAS1, UNIDADES1, DISP1, T_VIA1
  PSECT udata_bank0		;VARIABLES EN BANCO 0
  W_TEMP: DS 1			;W_TEMP DE 1 BYTE
  STAT_TEMP: DS 1		;STAT_TEMP 1 BYTE
  CONT_TMR: DS	1		;VARIABLE DEL TIMER 0
  SELECT:   DS	1		;VARIABLE SELECTOR DISPLAY
  TVIA1:    DS	1		;TIEMPO VIA 1
  T_VIA1:   DS	1
  TEMPVIA1: DS	1		;VARIABLE TEMPORAL VIA 1
  TVIA2:    DS	1		;TIEMPO VIA 2
  TVIA3:    DS	1		;TIEMPO VIA 3
  
  SEM_COLOR:DS	1		;BANDERA PARA COLOR DE SEMAFORO
    
  DECENAS1:  DS	1		;VALORES PARA DISPLAY VIA1
  UNIDADES1: DS	1
    
  DECENAS2:  DS	1		;VALORES PARA DISPLAY VIA2
  UNIDADES2: DS	1
    
  DECENAS3:  DS	1		;VALORES PARA DISPLAY VIA3
  UNIDADES3: DS	1
  
  DISP1:    DS 2		;DISPLAYS
  DISP2:    DS 2
  DISP3:    DS 2
  DISP4:    DS 2
  
 PSECT resVect, class=CODE, abs, delta=2
;-------------------------VECTOR RESET ----------------------------------------
  ORG 00h			;posición 0000h para el reset
  resetVec:
    PAGESEL main
    goto main
    
 PSECT	intVect,    class=CODE,	abs, delta=2
 ;-------------------------VECTOR INTERRUPT -------------------------------------  
 ORG	04h
 PUSH:
    BCF	    INTCON, 7		;DESACTIVAMOS LAS INTERRUPCIONES, PARA QUE NO SE CRUCEN ENTRE ELLAS
    MOVWF   W_TEMP		;GUARDAMOS EL VALOR EN W
    SWAPF   STATUS, W		;GUARDA STATUS EN W, (NO AFECTAMOS LAS BANDERAS)
    MOVWF   STAT_TEMP		;GUARDA W EN LA VARIABLE TEMPORAL
    
 ISR:
    ;BTFSC   RBIF		;REVISAMOS LA BANDERA DE CHANGE INTERRUPT
    ;CALL    INC_LED		;LLAMAMOS A LA SUBRUTINA DE INC_LED
    BTFSC   T0IF		;REVISAMOS LA BANDERA DE TOIF
    CALL    TIEMPO1		;LLAMAMOS A LA SUBRUTINA DEL DISPLAY
    CALL    DISP_VIA1
  
 POP:
    SWAPF   STAT_TEMP, W	;REGRESAMOS DE NUEVO EL VALOR COMO SE ENCONTRABA ANTES
    MOVWF   STATUS		;LO COLOCAMOS EN STATUS
    SWAPF   W_TEMP, F		;CAMBIAMOS LOS NIBLES DE W_TEMP
    SWAPF   W_TEMP, W		;REGRESAMOS SU VALOR EL VALOR INICIAL
    RETFIE			;VUELVE ACTIVAR EL GIE
    
ORG 100h
  TABLA_DISPLAY:
 CLRF	    PCLATH
 BSF	    PCLATH, 0		;PCLATH 01
 ADDWF	    PCL			;PROGRAM COUNTER = PCLATH + PC + W
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
    CLRF    TRISA  		;COLOCAMOS EL PUERTO A D E COMO OUTPUT
    CLRF    TRISE
    CLRF    TRISC		;COLOCAMOS EL PUERTO C COMO OUTPUT
    CLRF    TRISD		;COLOCAMOS EL PUERTO D COMO OUTPUT
    BSF	    TRISB,  INC		;PUSH DE INCREMENTO PORTB0
    BSF	    TRISB,  DECR	;PUSH DE INCREMENTO PORTB1
    BSF	    TRISB,  MODO	;PUSH MODO DE CONFIGURACION PORTB2
    BCF	    TRISB,  VER3
    BSF	    WPUB,   INC		;COLOCAMOS INC & DECR & MODO COMO ENTRADAS Y PINES WEAK PULL  UP
    BSF	    WPUB,   DECR
    BSF	    WPUB,   MODO
    
    BANKSEL PORTA
    CLRF    PORTA		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO A
    CLRF    PORTB		;COLOCAMOS EN 0 TODOS LOS PINES DEL PUERTO B
    CLRF    PORTD
    CLRF    PORTE
    MOVLW   00111111B
    MOVWF   PORTC		;COLOCAMOS DIGITO 0 PUERTO C
    RETURN
    
VARIABLES_INIT:
    CLRF    DISP1
    MOVLW   0X0A		;MOVEMOS 10 A W
    MOVWF   TVIA1,  F		;GUARDAMOS EL VALOR EN LA VARIABLE
    MOVWF   TVIA2,  F
    MOVWF   TVIA3,  F
    MOVF    TVIA1,  W
    MOVWF   T_VIA1
    BANKSEL PORTA
    MOVLW   01001100B		;AGREGAMOS VALORES INICIALES AL SEMAFORO
    MOVWF   PORTA
    BCF	    PORTB,  VER3
    RETURN
    
CONFIG_TMR0:			;CONFIGURACION DE TMR0
    CLRWDT			;LIMPIA EL WDT  Y PRESCALADOR
    BANKSEL OPTION_REG		;NOS DIRIGIMOS A CONFIGURAR OPTION REG DEL TIMER0
    MOVLW   01010000B		;SELECCIONAMOS SÓLO LOS BITS PSA(0),PS2,PS1,PS0, TOSC(0), a RBPU(0) HABILITA PULL UP
    ANDWF   OPTION_REG,	W	;Y LOS DEMAS LOS PONEMOS EN 0
    IORLW   00000100B		; PRESCALADOR EN 1:32 (TMR0 EN 125)
    MOVWF   OPTION_REG  
    CALL    TMR0_RESTART	;LLAMAMOS A LA SUBRUTINA PARA RESTART EL TMR0
    RETURN
 
CONFIG_INT_ENABLE:
    BSF	    GIE			;HABILITAMOS LAS INTERRUPCIONES GLOBALES
    BSF	    RBIE		;HABILITAMOS LAS INTERRUPCIONES INTERRUPT-ON-CHANGE
    BSF	    T0IE		;HABILITAMOS LA INTERRUPCION DE OVERFLOW DE TMR0
    BCF	    T0IF		;LIMPIAMOS LA BANDERA DEL TMR0
    BCF	    RBIF		;LIMPIAMOS LA BANDERA DE INTERRUPT-ON-CHANGE
    RETURN
 
CONFIG_IOCRB:
    BANKSEL TRISA
    BSF	    IOCB,   INC		;HABILITAMOS INTERRRUPT ON CHANGE EN PORTB0 & PORTB1
    BSF	    IOCB,   DECR
    BSF	    IOCB,   MODO
    
    BANKSEL PORTA
    MOVF    PORTB,  W		;COMPARAR LOS VALORES ANTES Y DESPUES, PARA VER EL MISSMATCH (NO IGUALES)
    BCF	    RBIF		;LIMPIAMOS LA BANDERA DE INTERRUPT-ON-CHANGE
    RETURN
 ;-----------------------SUB RUTINAS DE INTERRUPCION --------------------------
  TMR0_RESTART:
    BANKSEL TMR0
    MOVLW   6
    MOVWF   TMR0		;LE COLOCAMOS 6, PARA LUEGO OBTENER 8 ms
    BCF	    INTCON, 2		;LIMPIAMOS NUESTRA BANDERA DE T0IF 
    RETURN
    
  TIEMPO1:
    CALL    TMR0_RESTART	;LLAMAMOS A SUBRUTINA A RESETEAR TMR0
    INCF    CONT_TMR		;INCREMENTAMOS NUESTRA VARIABLE & GUARDAMOS EN W
    MOVF    CONT_TMR,   W	;MOVEMOS EL VAROR A W
    SUBLW   125			;RESTA CON 125, QUEREMOS QUE SE REPITA 125 VECES
    BTFSS   ZERO		;REVISAMOS BANDERA DE ZERO
    RETURN			;REGRESAMOS
    CLRF    CONT_TMR		;LIMPIAMOS LA VARIABLE DE CONTEO
    DECF    T_VIA1
    MOVLW   0X07
    XORWF   T_VIA1,	W	;CUANDO LLEGUE A 4 TIENE QUE CAMBIAR AMARILLO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    BSF	    SEM_COLOR,	0
    MOVLW   0X04
    XORWF   T_VIA1,	W	;CUANDO LLEGUE A 4 TIENE QUE CAMBIAR AMARILLO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    CALL    COLOR_AMA
    MOVLW   0X00
    XORWF   T_VIA1,	W	;CUANDO LLEGUE A 0 TIENE QUE CAMBIAR ROJO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    CALL    COLOR_RED
    RETURN
    
    COLOR_AMA:
    BCF	    SEM_COLOR,	0
    BCF	    PORTA,  2
    BSF	    PORTA,  1
    RETURN
    COLOR_RED:
    BCF	    PORTA,  1
    BSF	    PORTA,  0
    RETURN
 ;-------------------------CONFIGURACIÓN- --------------------------------------
 main:
    CALL    CONFIG_R		;CONFIGURACION DEL RELOJ OSCILADOR 4MHZ
    CALL    CONFIG_IO		;CONFIGURACION DE PUERTOS
    CALL    CONFIG_TMR0		;CONFIGURACION DE TMR0
    CALL    CONFIG_IOCRB	;CONFIGURACION DE IOCRB
    CALL    CONFIG_INT_ENABLE	;CONFIGURACION DE INTERRUPCIONES
    CALL    VARIABLES_INIT	;CONFIGURACION DE VALORES INICIALES DE LAS VARIABLES DE TIEMPO
  
 LOOP:
    CALL    DECENAS_1
    CALL    UNIDADES_1
    CALL    VALORES_VIA1
    CALL    TITILAR
    GOTO    LOOP
    
 TITILAR:
    BTFSC   SEM_COLOR, 0
    GOTO    TIT_VERDE
    RETURN
 
 TIT_VERDE:
    MOVLW   0X3E
    XORWF   CONT_TMR,	W
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    BCF	    PORTA,  2
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    MOVLW   0X7C
    XORWF   CONT_TMR,	W
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    BSF	    PORTA,  2
    RETURN
    
 DECENAS_1:
    MOVF    T_VIA1,  W
    MOVWF   TEMPVIA1
    CLRF    DECENAS1		;LIMPIAMOS NUESTRA VARIABLE
    MOVLW   0X0A		;COLOCAMOS 10
    SUBWF   TEMPVIA1,  F	;RESTAMOS 10 A LA VARIABLE Y LE CARGAMOS EL VALOR
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    INCF    DECENAS1, 1		;INCREMENTAMOS A DECENA1
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    GOTO    $-4
    ADDWF   TEMPVIA1,  F
    RETURN
    
 UNIDADES_1:
    CLRF    UNIDADES1		;LIMPIAMOS LA VARIABLE
    MOVLW   0X01		;COLOCAMOS 1
    SUBWF   TEMPVIA1,  F		;RESTAMOS 1 A LA VARIABLE
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    INCF    UNIDADES1, 1	;INCREMENTAMOS UNIDADES
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    GOTO    $-4
    ADDWF   TEMPVIA1,  F		;LA VARIABLE SE QUEDA EN VALOR DE 0
    RETURN
    
 VALORES_VIA1:
    MOVF    UNIDADES1,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP1		;CARGAMOS EL VALOR UNIDADES
    MOVF    DECENAS1,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP1+1		;CARGAMOS EL VALOR DECENAS
    RETURN

  DISP_VIA1:
    CALL    TMR0_RESTART
    CLRF    PORTD		;LIMPIAMOS EL PORTD
    BTFSC   SELECT, 0		;VERIFICAMOS A QUE DISPLAY CARGAMOS EL VALOR
    GOTO    DISPLAY_V1_1
    BTFSC   SELECT, 1
    GOTO    DISPLAY_V1_0
  
  DISPLAY_V1_0:
    MOVF    DISP1,  W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN EL PRIMER DISPLAY
    BSF	    PORTD,  0
    MOVLW   00000001B
    GOTO    CAMBIO_DISP
 DISPLAY_V1_1:
    MOVF    DISP1+1, W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN SEGUNDO DISPLAY
    BSF	    PORTD,  1
    MOVLW   00000000B
    GOTO    CAMBIO_DISP
    
 CAMBIO_DISP:
    MOVWF   SELECT, F		;CAMBIAMOS LA BANDERA 
    RETURN