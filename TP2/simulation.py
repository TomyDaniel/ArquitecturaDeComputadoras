import serial
import time

PUERTO = 'COM14'   # Windows: 'COM3', 'COM4', etc. Linux: '/dev/ttyUSB0'
BAUD   = 9600

# Opcodes de la consigna
OP_AND, OP_OR, OP_NOR, OP_XOR = 0b100100, 0b100101, 0b100111, 0b100110
OP_ADD, OP_SUB, OP_SRA, OP_SRL = 0b100000, 0b100010, 0b000011, 0b000010

# (A, B, opcode, nombre_op, y_esperado, carry_esperado, ovf_esperado)
CASOS = [
    (0b11001100, 0b10101010, OP_AND, "AND", 0b10001000, 0, 0),
    (0b11001100, 0b10101010, OP_OR,  "OR",  0b11101110, 0, 0),
    (0b11001100, 0b10101010, OP_NOR, "NOR", 0b00010001, 0, 0),
    (0b11001100, 0b10101010, OP_XOR, "XOR", 0b01100110, 0, 0),
    (0b00000101, 0b00000010, OP_ADD, "ADD", 0b00000111, 0, 0),
    (0b11111111, 0b00000001, OP_ADD, "ADD (carry)", 0b00000000, 1, 0),
    (0b01111111, 0b00000001, OP_ADD, "ADD (ovf)",   0b10000000, 0, 1),
    (0b00000101, 0b00000010, OP_SUB, "SUB", 0b00000011, 0, 0),
    (0b00000010, 0b00000101, OP_SUB, "SUB (carry)", 0b11111101, 1, 0),
    (0b10000000, 0b00000001, OP_SUB, "SUB (carry+ovf)", 0b01111111, 0, 1),
    (0b11010110, 0b00000010, OP_SRL, "SRL", 0b00110101, 0, 0),
    (0b11010110, 0b00000010, OP_SRA, "SRA", 0b11110101, 0, 0),
]


def probar_operacion(ser, A, B, opcode):
    ser.write(bytes([A]))
    time.sleep(0.05)
    ser.write(bytes([B]))
    time.sleep(0.05)
    ser.write(bytes([opcode]))

    respuesta = ser.read(2)
    if len(respuesta) < 2:
        return None, None, None  # timeout / sin respuesta

    y = respuesta[0]
    flags = respuesta[1]
    carry = flags & 0b01
    ovf = (flags >> 1) & 0b01
    return y, carry, ovf


def main():
    ser = serial.Serial(PUERTO, BAUD, timeout=2)
    time.sleep(2)  # margen para que se estabilice la conexión serie

    errores = 0
    print(f"Corriendo {len(CASOS)} casos de prueba...\n")

    for i, (A, B, opcode, nombre, y_esp, carry_esp, ovf_esp) in enumerate(CASOS):
        y, carry, ovf = probar_operacion(ser, A, B, opcode)

        if y is None:
            print(f"Test {i} ({nombre}): SIN RESPUESTA (timeout)")
            errores += 1
            continue

        ok = (y == y_esp) and (carry == carry_esp) and (ovf == ovf_esp)
        estado = "OK" if ok else "FALLO"

        print(f"Test {i} ({nombre}): A={A:08b} B={B:08b} op={opcode:06b} -> "
              f"y={y:08b} (esp {y_esp:08b}) carry={carry}(esp {carry_esp}) "
              f"ovf={ovf}(esp {ovf_esp})  {estado}")

        if not ok:
            errores += 1

        time.sleep(0.1)  # margen entre casos

    print(f"\n{'TODOS los casos pasaron OK' if errores == 0 else f'{errores} FALLOS de {len(CASOS)} casos'}")
    ser.close()


if __name__ == "__main__":
    main()