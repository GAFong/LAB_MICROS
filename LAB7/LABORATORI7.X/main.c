/* 
 * File:   LABORATORIO 07
 * Author: GABRIEL ALEXANDER FONG PENAGOS
 * LED PORTA & D, 2 PUSH EN PORTB, DISPLAY PORTC, TRANSISTORES PORTE
 * Created on April 12, 2021, 5:57 PM
 * Ultima modificación 13/04/2021
 */

#include <xc.h>
#include <stdint.h>

/*--------------------------CONFIGURACIONES ----------------------------------*/

// CONFIG1
#pragma config FOSC = INTRC_CLKOUT// Oscillator Selection bits (INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

#define _tmr0_value 100         //

//------------------------------VARIABLES---------------------------------------
int contador1 = 0;
int contador2 = 0; 
int flag1;
int flag2;

//-----------------------------PROTOTIPOS---------------------------------------
void setup (void);

//---------------------------INTERRUPCION--------------------------------------
void __interrupt()isr(void){
    di();
    if  (T0IF == 1){
        contador1++;        //INCREMENTAMOS LA VARIABLE
        TMR0 = _tmr0_value;
        INTCONbits.T0IF = 0;            //LIMPIO LA BANDERA DE T0IF
    }
    if (RBIF == 1){
         
        if (RB0 == 0){
            flag1 = 1;
        }
        else{
            if (flag1 == 1) {
                contador2++;            //INCREMENTAMOS LA VARIABLE
                flag1 = 0;
            }
        }
           
           
    
        if (RB1 == 0){
            flag2 = 1;
        }
        else {
            if(flag2 ==1){
                contador2--;             //DECREMNTAMOS LA VARIABLE
                flag2 = 0;
            }
        }
  
     INTCONbits.RBIF = 0;    
    }
    ei();
}

void main (void){
    setup();
    
    while(1){
        PORTA = contador1;
        PORTD = contador2;
    }
}
//---------------------------CONFIGURACION--------------------------------------
void setup(void){
    //CONFIGURACION DE MUERTOS
    ANSEL = 0X00;               //PINES COMO DIGITALES 
    ANSELH = 0X00;
    
    TRISA = 0X00;               //PORTA COMO OUTPUT
    TRISC = 0X00;               //PORTC COMO OUTPUT
    TRISD = 0X00;               //PORTD COMO OUTPUT
    TRISE = 0X00;               //PORTE COMO OUTPUT
    TRISB = 0X03;                //PORTB0 Y PORTB1 COMO ENTRADAS
    
    PORTA = 0X00;                //LIMPIAMOS EL PUERTOA
    PORTC = 0X00;                //LIMPIAMOS EL PUERTOC
    PORTD = 0X00;                //LIMPIAMOS EL PUERTOD
    PORTE = 0X00;                //LIMPIAMOS EL PUERTOE
    
    //CONFIGURACION DEL OSCIALDOR
    OSCCONbits.IRCF2 = 1;        //OSCILADOR  DE 4 MHZ
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 0;
    OSCCONbits.SCS = 1;         //RELOJ INTERNO 
    
    //CONFIGURACION DEL TMR0
    OPTION_REG = 0B01010100;    //RBPU HABILITADO, PSA (0) PRESCALER 1:32
    TMR0 = _tmr0_value;         //TMR0 A 5 ms
    
    //CONFIGURACION DEL IOC
    WPUB0 = 1 ;
    WPUB1 = 1 ;
    IOCB0 = 1 ;
    IOCB1 = 1 ;
    
    //CONFIGURACION DE INTERRUPCIONES
    INTCONbits.GIE = 1;         //HABILITAMOS LAS INTERRUPCIONES GLOBALES
    INTCONbits.T0IE = 1;        //HABILITAMOS LA INTERRUPCION DE TMR0
    INTCONbits.T0IF = 0;        //LIMPIAMOS LA BANDERA DEL TMR0
    INTCONbits.RBIE = 1;        //HABILITAMOS LAS INTERRUPCIONES IOC
    INTCONbits.RBIF = 0;        //LIMPIAMOS LA BANDER DE IOC
}
