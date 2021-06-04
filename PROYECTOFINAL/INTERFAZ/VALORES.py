

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

    def escribir(self,servo1,servo2):
        if (servo1 >= 4):
            self.label.setText('Servo1 ')

        elif (servo2<= 3):
            self.label.setText('Servo2 ')
        else:
            self.label.setText('Servo1 3')

    def posicion_garra(self, angulo):
        #print(angulo)
        type(angulo)
    def actual(self):
        self.update()

def posiciones():
    global ventana, ser
    try:
        while (1):
            ser.flushInput()
            time.sleep(.3)
            angulo = ser.readline()
            ventana.posicion_garra(angulo)
            ser.readline()
            try:
                #valorservos = str(ser.readline()).split(',')
                print(ser.readline())
                #servo1 = int(valorservos[0][2])
                #servo2 = int(valorservos[1][0])
                #ventana.escribir(servo1,servo2)
                #print(servo1,'\t',servo2)
            except :
                pass
            ventana.actual()
    except:
        print("Error: No esta comunicando")


app = QtWidgets.QApplication([])
ventana = interfaz()
ventana.show()
app.exec_()
