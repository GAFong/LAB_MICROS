

from PROYECTO_BRAZO import *
from PyQt5 import QtWidgets
import threading
import serial
import time
import sys

ser = serial.Serial(port='COM3',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)

class interfaz (QtWidgets.QMainWindow, Ui_MainWindow):
    def __init__ (self):
        super().__init__()
        self.setupUi(self)
        # FUNCIONES DE BOTONES, SLIDERS, ETC.
        self.Garra.valueChanged.connect(self.serial_garra)
        self.Brazo1.valueChanged.connect(self.serial_brazo1)
        self.Brazo2.valueChanged.connect(self.serial_brazo2)
        self.BASE.valueChanged.connect(self.serial_base)
        self.GUARDAR.pressed.connect(self.serial_guardar)
        self.VALOR1.pressed.connect(self.serial_valor1)
        self.VALOR2.pressed.connect(self.serial_valor2)
        self.VALOR3.pressed.connect(self.serial_valor3)
        threading.Thread(daemon=True, target=posiciones).start()

    def serial_garra(self):
        global ser
        #try:
        ser.write(bytes.fromhex('61')) #letra a
    #    ser.write(bytes.fromhex('0A')) #enter
        ser.write(bytes.fromhex(hex(ord(str(self.Garra.value())))[2:]))
    def serial_brazo1(self):
        global ser
        #try:
        ser.write(bytes.fromhex('62')) #letra b
        #ser.write(bytes.fromhex('0A')) #enter
        ser.write(bytes.fromhex(hex(ord(str(self.Brazo1.value())))[2:]))
    def serial_brazo2(self):
        global ser
        #try:
        ser.write(bytes.fromhex('63')) #letra c
        #ser.write(bytes.fromhex('0A')) #enter
        ser.write(bytes.fromhex(hex(ord(str(self.Brazo2.value())))[2:]))
    def serial_base(self):
        global ser
        #try:
        ser.write(bytes.fromhex('64')) #letra d
        ser.write(bytes.fromhex(hex(ord(str(self.BASE.value())))[2:]))

    def serial_guardar(self):
        global ser
        #try:
        ser.write(bytes.fromhex('65')) #letra e
    def serial_valor1(self):
        global ser
        #try:
        ser.write(bytes.fromhex('66')) #letra f
    def serial_valor2(self):
        global ser
        #try:
        ser.write(bytes.fromhex('67')) #letra g
    def serial_valor3(self):
        global ser
        #try:
        ser.write(bytes.fromhex('68')) #letra h

    def escribir(self,servo1,servo2,servo3):
        angulo1 = servo1*20
        angulo2 = (servo2*11.11) + 65
        angulo3 = servo3*10
        self.labelgarra.setText('Garra {}°'.format(angulo1))
        self.labelBrazo1.setText('Brazo 1  {}°'.format(angulo2))
        self.labelBrazo2.setText('Brazo 2  {}°'.format(angulo3))


    def actual(self):
        self.update()

def posiciones():
    global ventana, ser
    try:
        while (1):
            ser.flushInput()
            time.sleep(.3)
            #angulo = ser.readline()
            #ventana.posicion_garra(angulo)
            ser.readline()
            try:
                valorservos = str(ser.readline()).split(',')
                #print(valorservos)
                servo1 = int(valorservos[0][2])
                servo2 = int(valorservos[1][0])
                servo3 = int(valorservos[2][0])
                ventana.escribir(servo1,servo2,servo3)
                print(servo1,'\t',servo2)
            except :
                pass
            ventana.actual()
    except:
        print("Error: No esta comunicando")


app = QtWidgets.QApplication([])
ventana = interfaz()
ventana.show()
app.exec_()
