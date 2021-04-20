/* 
 * File:   LABORATORIO 08
 * Author: GABRIEL ALEXANDER FONG PENAGOS
 * LED PORTD, 2 POT EN PORTB, DISPLAY PORTC, TRANSISTORES PORTE
 * Created on April 18, 2021, 5:57 PM
 * Ultima modificación 20/04/2021
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

#define _tmr0_value 100 
#define _XTAL_FREQ 4000000
//------------------------------VARIABLES---------------------------------------
int VALOR = 0;
int select = 1;
int centenas = 0;
int decenas = 0;
int unidades = 0;
//------------------------------TABLA-------------------------------------------
int digitos [10] = {
0B00111111, 0B00000110, 0B01011011, 0B01001111, 0B01100110, 0B01101101,
0B01111101, 0B00000111, 0B01111111, 0B01100111};

//-----------------------------PROTOTIPOS---------------------------------------
void setup (void);
void centena (int numero, int *c);
void decena (int numero, int * d, int * u);
void display(int c, int d,int u);

//---------------------------INTERRUPCION--------------------------------------
void __interrupt()isr(void){
    di();                   //PUSH
    if  (T0IF == 1){
        TMR0 = _tmr0_value; //VALOR
        display(centenas,decenas,unidades);
        INTCONbits.T0IF = 0;            //LIMPIO LA BANDERA DE T0IF
    }
    if  (ADIF == 1){
        if (ADCON0bits.CHS == 0){       //SI ESTA EL CANAL0 SELECCIONADO
            PORTD = ADRESH;             //CARGAMOS ADRESH A PORTD
        }
        else {
            VALOR = ADRESH;             //CARGAMOS ADRESH A VALOR
        }
        PIR1bits.ADIF = 0;              //LIMPIAMOS LA BANDERA DEL ADC
    }
    ei();                           //POP
}

void main (void){
    setup();                        //FUNCION DE SETUP
    ADCON0bits.GO = 1;              //COMIENZA EL CICLO DEL ADC
    while(1){
        switch(ADCON0bits.CHS){
            case 0:
              ADCON0bits.CHS = 12;   //COLOCAMOS EL CANAL 12 PORTB0
              break;
            case 12:
              ADCON0bits.CHS = 0;   //COLOCAMOS EL CANAL 0  PORTA0
              break;
        }
        __delay_us(50);
        ADCON0bits.GO = 1;              //COMIENZA EL CICLO DEL ADC
        centena(VALOR, &centenas);//FUNCION DE CENTENAS
        decena (VALOR, &decenas, &unidades); //FUNCION DE DECENAS Y UNIDADES
    }
}

void setup(void){
    //CONFIGURACION DE MUERTOS
    ANSEL = 0X01;               //RA0 COMO ANALOGICO
    ANSELH = 0X01;              //RB0 COMO ANALOGICO
    
    TRISA = 0X01;               //PORTA COMO OUTPUT
    TRISC = 0X00;               //PORTC COMO OUTPUT
    TRISD = 0X00;               //PORTD COMO OUTPUT
    TRISE = 0X00;               //PORTE COMO OUTPUT
    TRISB = 0X01;                //PORTB0 Y PORTB1 COMO ENTRADAS
    
    PORTA = 0X00;                //LIMPIAMOS EL PORTA
    PORTB = 0X00;                //LIMPIAMOS EL PORTB
    PORTC = 0X00;                //LIMPIAMOS EL PORTC
    PORTD = 0X00;                //LIMPIAMOS EL PORTD
    PORTE = 0X00;                //LIMPIAMOS EL PORTE
    
    //CONFIGURACION DEL OSCIALDOR
    OSCCONbits.IRCF2 = 1;        //OSCILADOR  DE 4 MHZ
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 0;
    OSCCONbits.SCS = 1;         //RELOJ INTERNO 
    
    //CONFIGURACION DEL TMR0
    OPTION_REG = 0B11010100;    //RBPU DESHABILITADO, PSA (0) PRESCALER 1:32
    TMR0 = _tmr0_value;         //TMR0 A 5 ms
    
    //CONFIGURACION DEL ADC
    ADCON0bits.ADON = 0X01;     //ENCENDEMOS EL MODULO
    ADCON0bits.CHS = 0X00;      //ESCOGEMOS EL CANAL 0
    __delay_us(100);
    ADCON0bits.ADCS = 0X01;     //ADC CLOCK FOSC/8  
    ADCON1bits.ADFM = 0;        //JUSTIFICADO A LA IZQUIERDA
    ADCON1bits.VCFG0 = 0;       //VOLTAGE DE REFERENCIA EN VDD
    ADCON1bits.VCFG1 = 0;       //VOLTAGE DE REFERENCIA EN VSS
    //CONFIGURACION DE INTERRUPCIONES
    INTCONbits.GIE = 1;         //HABILITAMOS LAS INTERRUPCIONES GLOBALES
    INTCONbits.T0IE = 1;        //HABILITAMOS LA INTERRUPCION DE TMR0
    INTCONbits.T0IF = 0;        //LIMPIAMOS LA BANDERA DEL TMR0
    PIE1bits.ADIE = 0;          //HABILITAMOS LA INTERRUPCION DEL ADC
    PIR1bits.ADIF = 0;          //LIMPIAMOS LA BANDERA DEL ADC
    
}
void centena(int numero, int *c){
    *c = numero/100;            //DIVIDIMOS ENTRE 100 PARA OBTENER LAS CENTENAS
}
 
void decena (int numero, int * d, int * u){
    if(numero >= 100){
        if(numero >= 200){
            numero = numero - 200;//RESTAMOS 200
            *d = numero/10;     /*DIVIDIMOS EL NUMERO DENTRO DE 10, PARA OBTENER
                                  LA CANTIDAD DE DECENAS*/
            *u = numero % 10;   /*UTILIZAMOS EL RESIDUO PARA OBTENER LAS 
                                 UNIDADES*/
        }
        else {
            numero = numero - 100;//RESTAMOS 100
            *d = numero/10;     /*DIVIDIMOS EL NUMERO DENTRO DE 10, PARA OBTENER
                                  LA CANTIDAD DE DECENAS*/
            *u = numero % 10;   /*UTILIZAMOS EL RESIDUO PARA OBTENER LAS 
                                 UNIDADES*/
        }
    }
    else {
        *d = numero / 10;       /*DIVIDIMOS EL NUMERO DENTRO DE 10, PARA OBTENER
                                  LA CANTIDAD DE DECENAS*/ 
        *u = numero % 10;       /*UTILIZAMOS EL RESIDUO PARA OBTENER LAS 
                                 UNIDADES*/
    }
}
void display(int c, int d,int u){
    PORTE = 0X00;
    switch (select){            //CASOS PARA LA MULTIPLEXACION 
        case 1:                 //CARGAMOS LOS VALORES DE UNIDADES AL DISPLAY
            PORTC = digitos[u];
            PORTE = 0B00000001;
            select = 2;
            break;
        case 2:                 //CARGAMOS LOS VALORES DE DECENAS AL DISPLAY
            PORTC = digitos[d];
            PORTE = 0B00000010;
            select = 3;
            break;
        case 3:                 //CARGAMOS LOS VALORES DE CENTENAS AL DISPLAY
            PORTC = digitos[c];
            PORTE = 0B00000100;
            select = 1;
            break;
    }
}