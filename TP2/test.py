"""
Herramienta interactiva para probar la ALU vía UART (Basys3).
Permite ingresar A, B y la operación a mano, y muestra el resultado.

Requiere: pip install pyserial
Ajustar PUERTO según tu configuración.
"""

import serial
import time

PUERTO = 'COM14'   # Windows: 'COM3', 'COM4', etc. Linux: '/dev/ttyUSB0'
BAUD   = 9600

OPERACIONES = {
    "and": 0b100100,
    "or":  0b100101,
    "nor": 0b100111,
    "xor": 0b100110,
    "add": 0b100000,
    "sub": 0b100010,
    "sra": 0b000011,
    "srl": 0b000010,
}


def conectar():
    ser = serial.Serial(PUERTO, BAUD, timeout=2)
    time.sleep(2)  # margen para que se estabilice la conexión
    return ser


def pedir_byte(mensaje):
    while True:
        texto = input(mensaje).strip()
        try:
            # Acepta decimal (ej: 205), binario (ej: 0b11001101) o hex (ej: 0xCD)
            valor = int(texto, 0)
            if 0 <= valor <= 255:
                return valor
            print("El valor tiene que estar entre 0 y 255.")
        except ValueError:
            print("Valor inválido. Probá con un número decimal, 0bXXXXXXXX o 0xXX.")


def pedir_operacion():
    while True:
        nombre = input(f"Operación ({'/'.join(OPERACIONES.keys())}): ").strip().lower()
        if nombre in OPERACIONES:
            return nombre, OPERACIONES[nombre]
        print("Operación no reconocida, elegí una de la lista.")


def ejecutar(ser, A, B, opcode):
    ser.reset_input_buffer()  # limpia cualquier byte viejo que haya quedado

    ser.write(bytes([A]))
    time.sleep(0.05)
    ser.write(bytes([B]))
    time.sleep(0.05)
    ser.write(bytes([opcode]))

    respuesta = ser.read(2)
    if len(respuesta) < 2:
        print(">> Sin respuesta de la placa (timeout). Revisá conexión/reset.\n")
        return

    y = respuesta[0]
    flags = respuesta[1]
    carry = flags & 0b01
    ovf = (flags >> 1) & 0b01

    print()
    print(f"  A      = {A:3d}  (0b{A:08b})")
    print(f"  B      = {B:3d}  (0b{B:08b})")
    print(f"  y      = {y:3d}  (0b{y:08b})")
    print(f"  carry  = {carry}")
    print(f"  ovf    = {ovf}")
    print()


def main():
    print(f"Conectando a {PUERTO} @ {BAUD} baud...")
    ser = conectar()
    print("Conectado. Ctrl+C para salir.\n")

    try:
        while True:
            A = pedir_byte("A (0-255): ")
            B = pedir_byte("B (0-255): ")
            nombre, opcode = pedir_operacion()
            ejecutar(ser, A, B, opcode)
    except KeyboardInterrupt:
        print("\nSaliendo...")
    finally:
        ser.close()


if __name__ == "__main__":
    main()