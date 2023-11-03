import serial
import clientClass
import threading

baudrate = 115200
statusPin = 16

def start_UART_relay(_serial, _client, _printable=False):
        while True:
            if _serial.in_waiting <= 0: continue
            message = _serial.readline()
            if _printable and (b'#AAM' in message): print(message)
            _client.send(message)

serial_mcu = serial.Serial('/dev/ttyACM0', baudrate, timeout=1)
#debug_mcu = serial.Serial('/dev/ttyAMA1', baudrate, timeout=1)

thread_alive = True

client = clientClass.TCPClient("192.168.0.21", 9000, serial_mcu, statusPin)

## Uncomment for third serial connection, used for debug
# debug = serial.Serial('/dev/serial0', 115200)
# debug_client = clientClass.UART_TCPClient("10.0.0.106", 9000, debug)

client.connect()

receiveThread_Serial = threading.Thread(target=start_UART_relay, args = (serial_mcu, client))
#receiveThread_Debug = threading.Thread(target=start_UART_relay, args = (debug_mcu, client, True))

receiveThread_Serial.start()
#receiveThread_Debug.start()
