/* 
 * File:   LABORATORIO 09
 * Author: GABRIEL ALEXANDER FONG PENAGOS
 * POT EN PORTB0 Y PORTB1, SERVOS EN RC1 Y RC2
 * Created on April 24, 2021, 7:18 PM
 */

#include <xc.h>
#include <stdlib.h>

#define _XTAL_FREQ 4000000
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

//------------------------------VARIABLES---------------------------------------
int VALOR1 = 0;
int VALOR2 = 0;
//-----------------------------PROTOTIPOS---------------------------------------
void setup (void);


//---------------------------INTERRUPCION--------------------------------------
void __interrupt()isr(void){
    di();                   //PUSH

    if  (ADIF == 1){
        if (ADCON0bits.CHS == 0){       //SI ESTA EL CANAL12 SELECCIONADO
              VALOR1 = ADRESH;
              CCPR1L = (((0.467*VALOR1)+31));            //VALOR DEL CANAL 12 A VALOR2
              ADCON0bits.CHS = 12;   //COLOCAMOS EL CANAL 12 PORTB0
              __delay_us(1000);
             ADCON0bits.GO = 1;        }
        else {
              VALOR2 = ADRESH;
              CCPR2L = ((0.467*VALOR2)+31);            //VALOR DEL CANAL 12 A VALOR2
              ADCON0bits.CHS = 0;   //COLOCAMOS EL CANAL 12 PORTB0
              __delay_us(1000);
             ADCON0bits.GO = 1; 
        }
        PIR1bits.ADIF = 0;              //LIMPIAMOS LA BANDERA DEL ADC
    }
    ei();                           //POP
}

void main (void){
    setup();                        //FUNCION DE SETUP
    ADCON0bits.GO = 1;              //COMIENZA EL CICLO DEL ADC
    while(1){

    }
  
}

void setup(void){
    ANSEL = 0X01;                   //PINES COMO DIGITALES
    ANSELH = 0B00000001;            //PORTB0 Y PORTB1 COMO ANALOGICOS
    
    TRISA = 0X01;
    TRISB = 0X01;
    TRISC = 0B00000000;  
    
    PORTA = 0X00;
    PORTB = 0X00;
    PORTC = 0X00;
    
     //CONFIGURACION DEL OSCIALDOR
    OSCCONbits.IRCF2 = 1;        //OSCILADOR  DE 4 MHZ
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 0;
    OSCCONbits.SCS = 1;         //RELOJ INTERNO 
    //CONFIGURACION DEL TMR2
    T2CON = 0B11111111;         //POSTCALR 1:16, PRESCALER 16
    PR2 = 187;                  //PERIODO DE 3ms
    //CONFIGURACION DE CCP1 COMO PWM
    CCP1CON = 0B00001100;       //CCP1 EN MODO PWM
    //CONFIGURACION DE CCP2 COMO PWM
    CCP2CONbits.CCP2M0 = 1;
    CCP2CONbits.CCP2M1 = 1;
    CCP2CONbits.CCP2M2 = 1;
    CCP2CONbits.CCP2M3 = 1;
    CCP2CONbits.DC2B0 = 0;
    CCP2CONbits.DC2B1 = 0;
    //CONFIGURACION DEL ADC
    ADCON0bits.ADON = 0X01;     //ENCENDEMOS EL MODULO
    ADCON0bits.CHS = 12;      //ESCOGEMOS EL CANAL 0
    __delay_us(100);
    ADCON0bits.ADCS = 0X01;     //ADC CLOCK FOSC/8  
    ADCON1bits.ADFM = 0;        //JUSTIFICADO A LA IZQUIERDA
    ADCON1bits.VCFG0 = 0;       //VOLTAGE DE REFERENCIA EN VDD
    ADCON1bits.VCFG1 = 0;       //VOLTAGE DE REFERENCIA EN VSS
    //CONFIGURACION DE INTERRUPCIONES
    INTCONbits.GIE = 1;         //HABILITAMOS LAS INTERRUPCIONES GLOBALES
    INTCONbits.PEIE = 1;        //HABILITAMOS INTERRUPCIONES PERIFERICAS
    PIE1bits.ADIE = 1;          //HABILITAMOS LA INTERRUPCION DEL ADC
    PIR1bits.ADIF = 0;
    
}
