

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
        threading.Thread(daemon=True, target=posiciones).start()

    def serial_garra(self):
        global ser
        #try:
        ser.write(bytes.fromhex('61'))
        ser.write(bytes.fromhex('0A'))
        ser.write(bytes.fromhex(hex(ord(str(self.Garra.value())))[2:]))

    def posicion_garra(self, angulo):
        print(angulo)
        type(angulo)


def posiciones():
    global ventana, ser
    try:
        while (1):
            ser.flushInput()
            time.sleep(.3)
            angulo = ser.readline()
            ventana.posicion_garra(angulo)
    except:
        print("Error: No esta comunicando")


app = QtWidgets.QApplication([])
ventana = interfaz()
ventana.show()
app.exec_()
