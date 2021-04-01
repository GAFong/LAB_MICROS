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
	
  GLOBAL    W_TEMP, TVIA1, TVIA2, TVIA3, DECENAS1, UNIDADES1, DISP1, T_VIA1, SMODO, DISP4, DISPM, DISP_M0
  PSECT udata_bank0		;VARIABLES EN BANCO 0
  W_TEMP: DS 1			;W_TEMP DE 1 BYTE
  STAT_TEMP: DS 1		;STAT_TEMP 1 BYTE
  CONT_TMR: DS	1		;VARIABLE DEL TIMER 0
  CONT_TMR2:DS	1
  SELECT:   DS	1		;VARIABLE SELECTOR DISPLAY
  VIA:	    DS	1		;INDICA QUE VIA ESTAMOS
  TVIA1:    DS	1		;TIEMPO VIA 1
  T_VIA1:   DS	1
  T_VIA2:   DS	1
  T_VIA3:   DS	1
  TEMPVIA1: DS	1		;VARIABLE TEMPORAL VIA 1
  TEMPVIA2: DS	1
  TEMPVIA3: DS	1
  TVIA2:    DS	1		;TIEMPO VIA 2
  TVIA3:    DS	1		;TIEMPO VIA 3
  
  SEM_COLOR:DS	1		;BANDERA PARA COLOR DE SEMAFORO
  LED:	    DS	1		;PARA TITILEO DE LED
    
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
  DISPM:    DS 2
  DISP_M0:  DS	2
  
  AREB:	    DS	1		;VARIABLE BANDERA DE ANTIREBOTE
  SMODO:    DS	1		;VARIABLE DE SELECCION DE MODO	
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
    BTFSC   RBIF		;REVISAMOS LA BANDERA DE CHANGE INTERRUPT
    CALL    CAMBIAR_MODO		;LLAMAMOS A LA SUBRUTINA DE MODO
    CALL    MODE
    BTFSC   T0IF		;REVISAMOS LA BANDERA DE TOIF
    CALL    TIEMPO1		;LLAMAMOS A LA SUBRUTINA DEL TIEMPO
    CALL    DISP_VIA1		;LLAMAMOS A LA SUBRUTINA DEL DISPLAY
    BTFSC   TMR2IF		;REVISAMOS LA BANDERA TMR2IF
    CALL    LED_BLINK		;LLAMAMOS A LED BLINK
  
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
 RETLW	    00000000B		;APAGADO
 
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
    MOVWF   T_VIA2
    MOVWF   T_VIA3
    MOVF    TVIA2,  W
    ADDWF   T_VIA3,  F
    
    BANKSEL PORTA
    MOVLW   01001100B		;AGREGAMOS VALORES INICIALES AL SEMAFORO
    MOVWF   PORTA
    BCF	    PORTB,  VER3
    CLRF    VIA
    BSF	    VIA,    0
    MOVLW   00000001B
    MOVWF   SMODO,  F		;VALOR INICIO DEL MODO
    MOVLW   0X0A		;MOVEMOS 10 A W
    CALL    TABLA_DISPLAY
    MOVWF   DISPM
    MOVWF   DISPM+1
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
 
  CONFIG_TMR2:
    BANKSEL T2CON
    MOVLW   01100110B		;POSTCALER 1:13	    PRESCALER 1:16
    MOVWF   T2CON
    BANKSEL OPTION_REG
    MOVLW   240
    MOVWF   PR2			;COLOCAMOS EL PR2 EN 240
    BANKSEL TMR0
    BCF	    PIR1,    1		;LIMPIAMOS LA BANDERA
    RETURN
 
CONFIG_INT_ENABLE:
    BSF	    GIE			;HABILITAMOS LAS INTERRUPCIONES GLOBALES
    BSF	    PEIE		;HABILITAMOS LAS INTERRUPCIONES PERIFERICAS
    BSF	    RBIE		;HABILITAMOS LAS INTERRUPCIONES INTERRUPT-ON-CHANGE
    BSF	    T0IE		;HABILITAMOS LA INTERRUPCION DE OVERFLOW DE TMR0
    BCF	    T0IF		;LIMPIAMOS LA BANDERA DEL TMR0
    BCF	    RBIF		;LIMPIAMOS LA BANDERA DE INTERRUPT-ON-CHANGE
    BANKSEL OPTION_REG
    BSF	    PIE1,    1		;HABILITAMOS LA INTERRUPCION DE OVERFLOW DE TMR2
    BANKSEL TMR0
    BCF	    TMR2IF		;LIMPIAMOS LA BANDERA DEL TMR2
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
    DECF    T_VIA1		;DECREMENTAMOS LA VARIABLE TEMPORAL VIA 1
    DECF    T_VIA2		;DECREMENTAMOS LA VARIABLE TEMPORAL VIA 2
    DECF    T_VIA3		;DECREMENTAMOS LA VARIABLE TEMPORAL VIA 3
    RETURN
    
    LED_BLINK:
    BCF	    TMR2IF		;LIMPIAMOS LA INTERRUPCION
    INCF    CONT_TMR2		;INCREMENTAMOS LA VARIABLE
    MOVF    CONT_TMR2,   W	;MOVEMOS EL VAROR A W
    SUBLW   5			;RESTA CON 5, QUEREMOS QUE SE REPITA 5 VECES
    BTFSS   ZERO		;REVISAMOS BANDERA DE ZERO
    RETURN
    CLRF    CONT_TMR2		;LIMPIAMOS LA VARIABLE DE CONTEO DEL TMR2
    MOVLW   0X01
    XORWF   LED,  F		;REALIZAMOS XOR, ENTONCES EN EL BIT 0 ESTARÁ CAMBIANDO ENTRE 0 Y 1 CADA 250 MS
    RETURN
    
  COLOR_AMA1:
    BCF	    SEM_COLOR,	0
    BCF	    PORTA,  2
    BSF	    PORTA,  1
    RETURN
  COLOR_RED1:
    BCF	    PORTA,  1
    BSF	    PORTA,  0
    MOVLW   00000010B
    MOVWF   VIA,    F		;CAMBIAMOS A LA OTRA VIA
    MOVF    TVIA2,  W
    MOVWF   T_VIA1
    MOVWF   T_VIA2
    MOVWF   T_VIA3
    MOVF    TVIA3,  W
    ADDWF   T_VIA1,  F
    BCF	    PORTA,  3
    BSF	    PORTA,  5
    RETURN
 COLOR_AMA2:
    BCF	    SEM_COLOR,	1
    BCF	    PORTA,  5
    BSF	    PORTA,  4
    RETURN
 COLOR_RED2:
    BCF	    PORTA,  4
    BSF	    PORTA,  3
    MOVLW   00000100B
    MOVWF   VIA,    F		;CAMBIAMOS A LA OTRA VIA
    MOVF    TVIA3,  W
    MOVWF   T_VIA1
    MOVWF   T_VIA2
    MOVWF   T_VIA3
    MOVF    TVIA1,  W
    ADDWF   T_VIA2,  F
    BCF	    PORTA,  6
    BSF	    PORTB,  7
    RETURN
    COLOR_AMA3:
    BCF	    SEM_COLOR,	2
    BCF	    PORTB,  7
    BSF	    PORTA,  7
    RETURN
 COLOR_RED3:
    BCF	    PORTA,  7
    BSF	    PORTA,  6
    MOVLW   00000001B
    MOVWF   VIA,    F		;CAMBIAMOS A LA OTRA VIA
    MOVF    TVIA1,  W
    MOVWF   T_VIA1
    MOVWF   T_VIA2
    MOVWF   T_VIA3
    MOVF    TVIA2,  W
    ADDWF   T_VIA3,  F
    BCF	    PORTA,  0
    BSF	    PORTA,  2
    RETURN
      
  CAMBIAR_MODO:
    BTFSS   PORTB,   MODO	;MIRAMOS QUE EL BOTON NO ESTE PRESIONADO
    RLF     SMODO,  1		;CORREMOS EL VALOR DE LA BANDERA UN ESPACIO
    BCF	    RBIF		;LIMPIAMOS LA BANDERA DE LOS PUSH
    MOVLW   00100000B
    XORWF   SMODO,  W		;QUE LA VARIABLE NO PASE DE 6, SOLO EXISTEN 5 MODOS
    BTFSS   ZERO		;REVISAMOS LA VARIABLE DE ZERO
    RETURN
    MOVLW   00000001B
    MOVWF   SMODO		
    RETURN
 ;-------------------------CONFIGURACIÓN- --------------------------------------
 main:
    CALL    CONFIG_R		;CONFIGURACION DEL RELOJ OSCILADOR 4MHZ
    CALL    CONFIG_IO		;CONFIGURACION DE PUERTOS
    CALL    CONFIG_TMR0		;CONFIGURACION DE TMR0
    CALL    CONFIG_TMR2
    CALL    CONFIG_IOCRB	;CONFIGURACION DE IOCRB
    CALL    CONFIG_INT_ENABLE	;CONFIGURACION DE INTERRUPCIONES
    CALL    VARIABLES_INIT	;CONFIGURACION DE VALORES INICIALES DE LAS VARIABLES DE TIEMPO
  
 LOOP:
    CALL    DECENAS_1
    CALL    UNIDADES_1
    CALL    DECENAS_2
    CALL    UNIDADES_2
    CALL    DECENAS_3
    CALL    UNIDADES_3
    CALL    VALORES_VIA1
    BTFSC   VIA,    0
    CALL    SEMAFORO1
    BTFSC   VIA,    1
    CALL    SEMAFORO2
    BTFSC   VIA,    2
    CALL    SEMAFORO3
    CALL    TITILAR
    GOTO    LOOP
    
 MODE:
     BTFSC  SMODO,  0		;MODO 1
     CALL   MODE_0
     BTFSC  SMODO,  1		;MODO 2
     CALL   MODE_1
     BTFSC  SMODO,  2		;MODO 3
     CALL   MODE_2
     BTFSC  SMODO,  3		;MODO 4
     CALL   MODE_3
     BTFSC  SMODO,  4		;MODO 5
     CALL   MODE_4   
     RETURN
 MODE_0:
    BCF	    PORTE,  0
    BCF	    PORTE,  1
    BCF	    PORTE,  2
    MOVLW   000001010B
    MOVWF   DISPM
    MOVWF   DISPM+1
    RETURN
 MODE_1:
    BSF	    PORTE,  0
    BCF	    PORTE,  1
    BCF	    PORTE,  2
    RETURN
    
  MODE_2:
    BCF	    PORTE,  0
    BSF	    PORTE,  1
    BCF	    PORTE,  2
    RETURN
    
  MODE_3:
    BCF	    PORTE,  0
    BCF	    PORTE,  1
    BSF	    PORTE,  2
    RETURN
  MODE_4:
    BSF	    PORTE,  0
    BSF	    PORTE,  1
    BSF	    PORTE,  2
    RETURN
 SEMAFORO1:
    BTFSS   VIA,    0
    RETURN
    MOVLW   0X07
    XORWF   T_VIA1,	W	;CUANDO LLEGUE A 4 TIENE QUE CAMBIAR AMARILLO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    BSF	    SEM_COLOR,	0
    MOVLW   0X04
    XORWF   T_VIA1,	W	;CUANDO LLEGUE A 4 TIENE QUE CAMBIAR AMARILLO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    CALL    COLOR_AMA1
    MOVLW   0X00
    XORWF   T_VIA1,	W	;CUANDO LLEGUE A 0 TIENE QUE CAMBIAR ROJO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    CALL    COLOR_RED1
    RETURN
 SEMAFORO2:
    BTFSS   VIA,    1
    RETURN
    MOVLW   0X07
    XORWF   T_VIA2,	W	;CUANDO LLEGUE A 4 TIENE QUE CAMBIAR AMARILLO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    BSF	    SEM_COLOR,	1
    MOVLW   0X04
    XORWF   T_VIA2,	W	;CUANDO LLEGUE A 4 TIENE QUE CAMBIAR AMARILLO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    CALL    COLOR_AMA2
    MOVLW   0X00
    XORWF   T_VIA2,	W	;CUANDO LLEGUE A 0 TIENE QUE CAMBIAR ROJO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    CALL    COLOR_RED2
    RETURN
  SEMAFORO3:
    BTFSS   VIA,    2
    RETURN
    MOVLW   0X07
    XORWF   T_VIA3,	W	;CUANDO LLEGUE A 4 TIENE QUE CAMBIAR AMARILLO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    BSF	    SEM_COLOR,	2
    MOVLW   0X04
    XORWF   T_VIA3,	W	;CUANDO LLEGUE A 4 TIENE QUE CAMBIAR AMARILLO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    CALL    COLOR_AMA3
    MOVLW   0X00
    XORWF   T_VIA3,	W	;CUANDO LLEGUE A 0 TIENE QUE CAMBIAR ROJO
    BTFSC   ZERO		;REVISAMOS BANDERA DE ZERO
    CALL    COLOR_RED3
    RETURN
    
 TITILAR:
    BTFSS   SEM_COLOR, 0
    RETURN
    BTFSC   LED,    0		;REVISAMOS BANDERA DE LED
    BSF	    PORTA,  2
    BTFSS   LED,    0		;REVISAMOS BANDERA DE LED
    BCF	    PORTA,  2
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
  DECENAS_2:
    MOVF    T_VIA2,  W
    MOVWF   TEMPVIA2
    CLRF    DECENAS2		;LIMPIAMOS NUESTRA VARIABLE
    MOVLW   0X0A		;COLOCAMOS 10
    SUBWF   TEMPVIA2,  F	;RESTAMOS 10 A LA VARIABLE Y LE CARGAMOS EL VALOR
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    INCF    DECENAS2, 1		;INCREMENTAMOS A DECENA1
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    GOTO    $-4
    ADDWF   TEMPVIA2,  F
    RETURN
    
 UNIDADES_2:
    CLRF    UNIDADES2		;LIMPIAMOS LA VARIABLE
    MOVLW   0X01		;COLOCAMOS 1
    SUBWF   TEMPVIA2,  F		;RESTAMOS 1 A LA VARIABLE
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    INCF    UNIDADES2, 1	;INCREMENTAMOS UNIDADES
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    GOTO    $-4
    ADDWF   TEMPVIA2,  F		;LA VARIABLE SE QUEDA EN VALOR DE 0
    RETURN
 DECENAS_3:
    MOVF    T_VIA3,  W
    MOVWF   TEMPVIA3
    CLRF    DECENAS3		;LIMPIAMOS NUESTRA VARIABLE
    MOVLW   0X0A		;COLOCAMOS 10
    SUBWF   TEMPVIA3,  F	;RESTAMOS 10 A LA VARIABLE Y LE CARGAMOS EL VALOR
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    INCF    DECENAS3, 1		;INCREMENTAMOS A DECENA1
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    GOTO    $-4
    ADDWF   TEMPVIA3,  F
    RETURN
    
 UNIDADES_3:
    CLRF    UNIDADES3		;LIMPIAMOS LA VARIABLE
    MOVLW   0X01		;COLOCAMOS 1
    SUBWF   TEMPVIA3,  F	;RESTAMOS 1 A LA VARIABLE
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    INCF    UNIDADES3, 1	;INCREMENTAMOS UNIDADES
    BTFSC   STATUS, 0		;VERIFIACMOS LA BANDERA DE CARRY
    GOTO    $-4
    ADDWF   TEMPVIA3,  F	;LA VARIABLE SE QUEDA EN VALOR DE 0
    RETURN
 VALORES_VIA1:
    MOVF    UNIDADES1,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP1		;CARGAMOS EL VALOR UNIDADES
    MOVF    DECENAS1,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP1+1		;CARGAMOS EL VALOR DECENAS
    MOVF    UNIDADES2,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP2		;CARGAMOS EL VALOR UNIDADES
    MOVF    DECENAS2,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP2+1		;CARGAMOS EL VALOR DECENAS
    MOVF    UNIDADES3,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP3		;CARGAMOS EL VALOR UNIDADES
    MOVF    DECENAS3,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP3+1		;CARGAMOS EL VALOR DECENAS
    MOVF    DISPM,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP4
    MOVF    DISPM+1,	W	;CARGAMOS EL VALOR A W
    CALL    TABLA_DISPLAY	;VAMOS A NUESTRA TABLA
    MOVWF   DISP4+1
    RETURN

  DISP_VIA1:
    CALL    TMR0_RESTART
    BTFSS   LED,	0
    CALL    DISPLAY1_OFF
    CLRF    PORTD		;LIMPIAMOS EL PORTD
    BTFSC   SELECT, 0		;VERIFICAMOS A QUE DISPLAY CARGAMOS EL VALOR
    GOTO    DISPLAY_V1_1
    BTFSC   SELECT, 1
    GOTO    DISPLAY_V1_0
    BTFSC   SELECT, 2
    GOTO    DISPLAY_V2_0
    BTFSC   SELECT, 3
    GOTO   DISPLAY_V2_1
    BTFSC   SELECT, 4
    GOTO    DISPLAY_V3_0
    BTFSC   SELECT, 5
    GOTO    DISPLAY_V3_1
    BTFSC   SELECT, 6
    GOTO    DISPLAY_V4_0
    BTFSC   SELECT, 7
    GOTO    DISPLAY_V4_1
  
  
  DISPLAY_V1_0:
    CLRF    PORTD
    MOVF    DISP1,  W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN EL PRIMER DISPLAY
    BSF	    PORTD,  0
    MOVLW   00000001B
    GOTO    CAMBIO_DISP
 DISPLAY_V1_1:
    CLRF    PORTD
    MOVF    DISP1+1, W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN SEGUNDO DISPLAY
    BSF	    PORTD,  1
    MOVLW   00000100B
    GOTO    CAMBIO_DISP
 DISPLAY_V2_0:
    CLRF    PORTD
    MOVF    DISP2,  W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN EL PRIMER DISPLAY
    BSF	    PORTD,  2
    MOVLW   00001000B
    GOTO    CAMBIO_DISP
    RETURN
 DISPLAY_V2_1:
    CLRF    PORTD
    MOVF    DISP2+1, W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN SEGUNDO DISPLAY
    BSF	    PORTD,  3
    MOVLW   00010000B
    GOTO    CAMBIO_DISP
    RETURN
  DISPLAY_V3_0:
    CLRF    PORTD
    MOVF    DISP3,  W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN EL PRIMER DISPLAY
    BSF	    PORTD,  4
    MOVLW   00100000B
    GOTO    CAMBIO_DISP
 DISPLAY_V3_1:
    CLRF    PORTD
    MOVF    DISP3+1, W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN SEGUNDO DISPLAY
    BSF	    PORTD,  5
    MOVLW   01000000B
    GOTO    CAMBIO_DISP
   DISPLAY_V4_0:
    CLRF    PORTD
    MOVF    DISP4,  W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN EL PRIMER DISPLAY
    BSF	    PORTD,  6
    MOVLW   10000000B
    GOTO    CAMBIO_DISP
 DISPLAY_V4_1:
    CLRF    PORTD
    MOVF    DISP4+1, W		;CARGAMOS EL VALOR A W
    MOVWF   PORTC		;COLOCAMOS EL VALOR EN SEGUNDO DISPLAY
    BSF	    PORTD,  7
    MOVLW   00000000B
    GOTO    CAMBIO_DISP
    
 CAMBIO_DISP:
    MOVWF   SELECT, F		;CAMBIAMOS LA BANDERA 
    RETURN
DISPLAY1_OFF:
    BTFSS   SEM_COLOR,    0
    RETURN
    //BSF	    PORTD,  1		;SELECCIONO EL DISPLAY DE DECENAS
    //BSF	    PORTD,  0		;SELECCIONO EL DISPLAY DE UNIDADES
   // CLRF    PORTC		;LIMPIO EL PORTC
    MOVLW   00000000B
    MOVWF   DISP1
    MOVWF   DISP1+1
    RETURN
