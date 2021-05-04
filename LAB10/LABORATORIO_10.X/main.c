/* 
 * File:   LABORATORIO 08
 * Author: GABRIEL ALEXANDER FONG PENAGOS
 * LED PORTD, 2 POT EN PORTB, DISPLAY PORTC, TRANSISTORES PORTE
 * Created on May 3, 2021, 8:23 PM
 * Ultima modificación 
 */
#include <xc.h>
#include <stdio.h>
#include <stdlib.h>


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


#define _XTAL_FREQ 4000000

//------------------------------VARIABLES---------------------------------------

int DATO = 96;
//-----------------------------PROTOTIPOS---------------------------------------
void setup (void);

//---------------------------INTERRUPCION--------------------------------------
void __interrupt()isr(void){
    di();                   //PUSH
    
    if (PIR1bits.RCIF){
        PORTB = RCREG;               //
    }

    ei();                           //POP
}

void main (void){
    setup();                //FUNCION SETUP
    
    while(1) {
        __delay_ms(500);
         if (PIR1bits.TXIF){
             DATO++;
             if(DATO >= 123){
                 DATO = 96;
             }
            TXREG = DATO;       
    }

    }
}
  
void setup (void){
    //CONFIGURACION DE PUERTOS
    ANSEL = 0X00;               //PINES DIGITALES
    ANSELH = 0X00;              //PINES DIGITALES
    
    TRISA = 0X00;               //PORTA COMO OUTPUT
    TRISB = 0X00;               //PORTB0 Y PORTB1 COMO ENTRADAS
    TRISCbits.TRISC6 = 0;
    TRISCbits.TRISC7 = 1;
    
    PORTA = 0X00;                //LIMPIAMOS EL PORTA
    PORTB = 0X00;                //LIMPIAMOS EL PORTB
    
     //CONFIGURACION DEL OSCIALDOR
    OSCCONbits.IRCF2 = 1;        //OSCILADOR  DE 4 MHZ
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 0;
    OSCCONbits.SCS = 1;         //RELOJ INTERNO 
    
    //CONFIGURACION DE INTERRUPCIONES
    INTCONbits.GIE = 1;         //HABILITAMOS LAS INTERRUPCIONES GLOBALES
    INTCONbits.PEIE = 1;        //HABILITAMOS INTERRUPCIONES PERIFERICAS
    PIE1bits.RCIE = 1;          //HABILITAMOS INTERRUPCION DE UART PARA LA INTERUPCION
    PIR1bits.RCIF = 0;
    
    //CONFIGURACION UART

    TXSTAbits.TXEN = 1;         //SE HABILITA EL TX
    TXSTAbits.SYNC = 0;         //LO COLOCAMOS DE MANERA ASINCRONA
    RCSTAbits.SPEN = 1;         //TX COMO SALIDA
    TXSTAbits.TX9 = 0;          //8 BITS

    RCSTAbits.CREN = 1;         //SE HABILITA RC
    RCSTAbits.RX9 = 0;          //8 bits
    //VELOCIDAD
    BAUDCTLbits.BRG16 = 0;      //PARA UTILIZAR LA FORMULA CON EL /64
    SPBRG = 25;                  //VALOR MÁS CERCANO PARA LOS BAUDIOS
    SPBRGH = 1;
    TXSTAbits.BRGH = 1;
    
}