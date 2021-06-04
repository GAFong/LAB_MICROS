/* 
 * File:   main.c
 * Author: GABRIEL FONG
 * PROYECTO FINAL
 * Created on May 10, 2021, 3:53 PM
 * python -m PyQt5.uic.pyuic -x PROYECTO_BRAZO.ui -o PROYECTO_BRAZO.py
 */

#include <stdio.h>
#include <stdlib.h>
#include <xc.h>
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

#define _tmr0_value 206
#define _XTAL_FREQ 4000000
#define SERVO1_1 0
#define SERVO2_1 1
#define SERVO3_1 2
#define SERVO1_2 3
#define SERVO2_2 4
#define SERVO3_2 5
#define SERVO1_3 6
#define SERVO2_3 7
#define SERVO3_3 8

//------------------------------VARIABLES---------------------------------------
int PWM3=0;
unsigned int POT0 = 0;
unsigned int POT1 = 0;
unsigned int POT2 = 0;
unsigned int POT3 = 0;
unsigned char POT0A = 0;
unsigned char POT1A = 0;
unsigned char POT2A = 0;
unsigned char POT3A = 0;
int VALORAN = 0;
int DATO;
int RB0_FLAG = 1;
int RB1_FLAG = 1;
int SEL_G = 0; 
int SEL;
int FLAG_TX = 0;
int POS_TX = 0;
//-----------------------------PROTOTIPOS---------------------------------------
void setup (void);
void EEPROM_W(unsigned int dato, int add);
unsigned int EEPROM_R(unsigned int add);
void ANALOGICOS(int VALORAN);
unsigned char MANDAR (void);
unsigned char MANDAR_UART (void);
void GUARDAR(unsigned int POT0,unsigned int POT1,unsigned int POT2,unsigned int POT3);

//---------------------------INTERRUPCION--------------------------------------
void __interrupt()isr(void){
    di();                   //PUSH
    if  (T0IF == 1){
        TMR0 = _tmr0_value;             //VALOR DE REINICIO
        PWM3++;                         //INCREMENTAMOS PWM3
        //SEÑAL DE PWM3 COMPARA CON LA VARIABLE Y EL VALOR MAPEADO DEL AN0
        if (PWM3>= 25){         //CONTROL DEL PERIODO DE PWM3
          PWM3 = 0;}
          if  (PWM3 >= POT0){             
           PORTCbits.RC3 = 0;
           }
          else     {
           PORTCbits.RC3 = 1;
           }
        if  (PWM3 >= POT3){             
           PORTCbits.RC0 = 0;
           }
          else     {
           PORTCbits.RC0 = 1;
           }
          INTCONbits.T0IF = 0;            //LIMPIO LA BANDERA DE T0IF
    }
    
    if (ADIF == 1){
        VALORAN = ADRESH;               //CARGAMOS ADRESH A VALORAN
        PIR1bits.ADIF = 0;              //LIMPIAMOS LA BANDERA DEL ADC
    }
   
    if (PIR1bits.RCIF){
        if (RCREG >= 97 && RCREG <= 104 ){
                SEL = RCREG;  }
        else  {
            DATO = RCREG;
        }
      //  RCIF = 0;
    }
    ei();                           //POP
}

void main (void){
    setup();  
    while(1){
        while(RB6 == 1 && RB7 ==1){
            PORTE = 0X06;
            TXREG = MANDAR();
        ANALOGICOS(VALORAN);    //FUNCION DE VALORES ANALOGICOS
     
        if (RB0 == 1 && RB0_FLAG == 0){//HASTA DEJAR DE SER PRESIONADO
            GUARDAR(POT0, POT1, POT2, POT3);
        }
        
        RB0_FLAG = RB0;
        }
        
        while (RB6 == 0 && RB7 == 1){
            PORTE = 0X05;
            
            if (RB4 == 0 && RB5 == 1){
                POT0 = EEPROM_R(SERVO1_1);
                CCPR1L = EEPROM_R(SERVO2_1);
                CCPR2L = EEPROM_R(SERVO3_1);
        }
            if (RB4 == 1 && RB5 == 0){
                POT0 = EEPROM_R(SERVO1_2);
                CCPR1L = EEPROM_R(SERVO2_2);
                CCPR2L = EEPROM_R(SERVO3_2);
        }
            if (RB4 == 0 && RB5 == 0){
                POT0 = EEPROM_R(SERVO1_3);
                CCPR1L = EEPROM_R(SERVO2_3);
                CCPR2L = EEPROM_R(SERVO3_3);
        }
            RB1_FLAG = RB1;
        }
        
        while (RB6 == 1 && RB7 == 0){
            PORTE = 0X03;
             TXREG = MANDAR();
            switch(SEL){
                case 96:
                    break;
                case 97:
                    
                    POT0 =(1.1*(DATO-48)+5);
                    break;
                case 98:
                    
                    POT2 = (6.55*(DATO-48)+31);
                    CCPR2L = POT2;
                    break;
                case 99:
                    
                    POT1 = (8*(DATO-48)+75);
                    CCPR1L = POT1;
                    break;
                case 100:
                   
                    PORTD = 0X04;
                    switch (DATO - 48){
                        case 0:
                            PORTD = 0X02;
                            POT3 = 9;
                            break;
                        case 1:
                            POT3 = 12;
                            break;
                        case 2:
                            PORTD = 0X01;
                            POT3 = 15;
                            break;            
                    }
                    break;
                case 101:
                    GUARDAR(POT0, POT1, POT2, POT3);
                    SEL = 96;
                    break;
                case 102:
                    POT0 = EEPROM_R(SERVO1_1);
                    CCPR1L = EEPROM_R(SERVO2_1);
                    CCPR2L = EEPROM_R(SERVO3_1);
                    break;
                case 103:
                    POT0 = EEPROM_R(SERVO1_2);
                    CCPR1L = EEPROM_R(SERVO2_2);
                    CCPR2L = EEPROM_R(SERVO3_2);
                    break;
                case 104:
                    POT0 = EEPROM_R(SERVO1_3);
                    CCPR1L = EEPROM_R(SERVO2_3);
                    CCPR2L = EEPROM_R(SERVO3_3);
                    break;
                    }
            
           
        }
    }
        
}
void setup(void){
    //CONFIGURACION DE PUERTOS
    ANSEL = 0B00000111;               //RA0, RA1, RA2, RA3 ANALOGICO
    ANSELH = 0X02;
    
    TRISA = 0B00001111;          //RA0, RA1, RA2, RA3 INPUT
    TRISC = 0B10000000;          //PORTC COMO OUTPUT, RC7 TX
    TRISD = 0X00;               //PORTD COMO OUTPUT
    TRISE = 0X00;               //PORTE COMO OUTPUT
    TRISB = 0B11111111;         //RB0, RB1, RB6, RB7 COMO INPUT 
    
    PORTA = 0X00;                //LIMPIAMOS EL PUERTOA
    PORTB = 0X00;                //LIMPIAMOS EL PUERTOB
    PORTC = 0X00;                //LIMPIAMOS EL PUERTOC
    PORTD = 0X00;                //LIMPIAMOS EL PUERTOD
    PORTE = 0X00;                //LIMPIAMOS EL PUERTOE
    
    //CONFIGURACION DEL OSCIALDOR
    OSCCONbits.IRCF2 = 1;        //OSCILADOR  DE 4 MHZ
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 0;
    OSCCONbits.SCS = 1;         //RELOJ INTERNO 
    
    //CONFIGURACION DEL TMR0
    OPTION_REG = 0B01000000;    //RBPU HABILITADO, PSA (0) PRESCALER 1:16
    TMR0 = _tmr0_value;         //TMR0 A 50 us
  /*  //CONFIGURACION DEL TMR1
    T1CON	 = 0x11;
    PIR1bits.TMR1IF = 0;
    TMR1H	 = 0x3C;
    TMR1L	 = 0xB0;
    PIE1bits.TMR1IE = 1;*/
    
    //CONFIGURACION DEL IOC
    WPUB = 0B11110011;          //WEAK PULL UP ACTIVADO
    IOCB = 0B11110011;          //INTERRUPT ON CHANGE HABILITADO
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
    ADCON0bits.CHS = 0;        //ESCOGEMOS EL CANAL 0
    __delay_us(100);
    ADCON0bits.ADCS = 0X01;     //ADC CLOCK FOSC/8  
    ADCON1bits.ADFM = 0;        //JUSTIFICADO A LA IZQUIERDA
    ADCON1bits.VCFG0 = 0;       //VOLTAGE DE REFERENCIA EN VDD
    ADCON1bits.VCFG1 = 0;       //VOLTAGE DE REFERENCIA EN VSS
    //CONFIGURACION DE INTERRUPCIONES
    INTCONbits.GIE = 1;         //HABILITAMOS LAS INTERRUPCIONES GLOBALES
    INTCONbits.T0IE = 1;        //HABILITAMOS LA INTERRUPCION DE TMR0
    INTCONbits.T0IF = 0;        //LIMPIAMOS LA BANDERA DEL TMR0
    PIE1bits.ADIE = 1;          //HABILITAMOS LA INTERRUPCION DEL ADC
    PIR1bits.ADIF = 0;
    INTCONbits.RBIE = 0;        //DESHABILITAMOS LAS INTERRUPCIONES IOC
    INTCONbits.RBIF = 0;        //LIMPIAMOS LA BANDER DE IOC
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

void GUARDAR(unsigned int POT0,unsigned int POT1,unsigned int POT2,unsigned int POT3){
    switch (SEL_G){
                case 0:
                    EEPROM_W(POT0, SERVO1_1);     //CARGAMOS EL VALOR A LA DIRECCION DE SERVO1
                    EEPROM_W(POT1, SERVO2_1);     //CARGAMOS EL VALOR A LA DIRECCION DE SERVO2
                    EEPROM_W(POT2, SERVO3_1);     //CARGAMOS EL VALOR A LA DIRECCION DE SERVO3
                    SEL_G = 1;
                    break;
                case 1:
                    EEPROM_W(POT0, SERVO1_2);     //CARGAMOS EL VALOR A LA DIRECCION DE SERVO1
                    EEPROM_W(POT1, SERVO2_2);     //CARGAMOS EL VALOR A LA DIRECCION DE SERVO2
                    EEPROM_W(POT2, SERVO3_2);     //CARGAMOS EL VALOR A LA DIRECCION DE SERVO3
                    SEL_G = 2;
                    break;
                case 2:
                    EEPROM_W(POT0, SERVO1_3);     //CARGAMOS EL VALOR A LA DIRECCION DE SERVO1
                    EEPROM_W(POT1, SERVO2_3);     //CARGAMOS EL VALOR A LA DIRECCION DE SERVO2
                    EEPROM_W(POT2, SERVO3_3);     //CARGAMOS EL VALOR A LA DIRECCION DE SERVO3
                    SEL_G = 0;
                    break;
            }
}

void ANALOGICOS(int VALORAN){
     
    switch(ADCON0bits.CHS){
        case 0:
            POT0 = ((0.0380*VALORAN)+5);    //MAPEO DEL SERVO 3, (5,16)
            ADCON0bits.CHS = 1;   //COLOCAMOS EL CANAL 1 PORTA1
           __delay_us(100);
            ADCON0bits.GO = 1;              //COMIENZA EL CICLO DEL ADC*/
            break;
            
        case 1:
            POT1 = (((0.254*VALORAN)+75));
            CCPR1L = POT1;
            ADCON0bits.CHS = 2;   //COLOCAMOS EL CANAL 2 PORTA2
            __delay_us(100);
           ADCON0bits.GO = 1;              //COMIENZA EL CICLO DEL ADC*/
            break;
            
        case 2:
            POT2 = ((0.23*VALORAN)+35);    //(31,120)
            CCPR2L = POT2;
            ADCON0bits.CHS = 9;   //COLOCAMOS EL CANAL 3 PORTA3
           __delay_us(100);
             ADCON0bits.GO = 1;              //COMIENZA EL CICLO DEL ADC*/
            break;
        case 9:
           if (VALORAN >= 52 && VALORAN<=179){    //MAPEO DEL SERVO 3, (5,16)
               POT3 = 12;
           }
           else if (VALORAN >= 0 && VALORAN<=51){    //MAPEO DEL SERVO 3, (5,16)
               POT3 = 10;
               PORTD = 0X02;
           }
           else if (VALORAN >= 180 && VALORAN<=255){    //MAPEO DEL SERVO 3, (5,16)
               POT3 = 15;
               PORTD = 0X01;
           }
         //  POT3 = ((0.0380*VALORAN)+5);    //MAPEO DEL SERVO 3, (5,16)
           ADCON0bits.CHS = 0;   //COLOCAMOS EL CANAL 1 PORTA1
           __delay_us(100);
           ADCON0bits.GO = 1;              //COMIENZA EL CICLO DEL ADC*/
           break;
    }
}

void EEPROM_W(unsigned int dato, int add){
    EEADR = add;                //COLOCAMOS LA DIRECCION
    EEDAT = dato;               //COLOCAMOS EL DATO
    EECON1bits.EEPGD = 0;       //ENTRAMOS A LA PROGRAM MEMORY (EEPROM) 
    EECON1bits.WREN = 1;        //HABILITAMOS ESCRITURA 
    INTCONbits.GIE = 0;         //DESHABILIATMOS LAS INTERRUPCIONES GLOBALES
    EECON2 = 0X55;              //REALIZAMOS SECUENCIA REQUERIDA
    EECON2 = 0XAA;
    EECON1bits.WR = 1;
    while(PIR2bits.EEIF == 0);  //MIENTRAS LA BANDERA ESTE EN 0 SE ESTA ENVIANDO EL DATO
    PIR2bits.EEIF = 0;
    EECON1bits.WREN = 0;        //DESHABILITAMOS LA ESCRITURA
    INTCONbits.GIE = 1;         //DESHABILIATMOS LAS INTERRUPCIONES GLOBALES
//    return EECON1bits.WRERR;    //NOS SERVIRA PARA REVISAR QUE EL DATO SE ENVIO DE MANERA CORRECTA
    
}
unsigned int EEPROM_R(unsigned int add){
    EEADR = add;
    EECON1bits.EEPGD = 0;       //ENTRAMOS A LA PROGRAM MEMORY (EEPROM)
    EECON1bits.RD = 1;          //HABILITAMOS PARA LEER
    unsigned int dato = EEDATA; //CARGAMOS EL VALOR PARA EXTRAERLO
    return dato;
}
unsigned char MANDAR (void){
    
    switch (POS_TX){
        case 0:
            POT0A = ((0.8181*POT0)-4.09)+48;
            POS_TX = 1;
            return POT0A;
            break;
        case 1:
            POS_TX = 2;
            return 0x2C;
            break;
        case 2:
            POT1A =((0.1385*POT1)-10.4)+49;
            POS_TX = 3;
            return POT1A;
            break;
        case 3:
            POS_TX = 4;
            return 0x2C;
            break;
        case 4:
            POT2A = ((0.1551*POT2)-5.4)+48;
            POS_TX = 5;
            return POT2A;
            break;
        case 5:
            POS_TX = 0;
            return 0x0A;
            break;    
    }
}
