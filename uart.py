import argparse
import serial
import clients
import threading

parser = argparse.ArgumentParser()
parser.add_argument('-p', '--port',      type=str, default='/dev/ttyACM0')
parser.add_argument('-b', '--baud',      type=int, default=115200)
parser.add_argument('--host',           type=str, default="192.168.137.1:9000")
parser.add_argument('-s', '--statusPin', type=int, default=None) # Change default for prod
parser.add_argument('-d', '--debug', action='store_true')
args = parser.parse_args()

def start_UART_relay(_serial, _client, _printable=False):
    while True:
        if _serial.in_waiting <= 0: continue
        message = _serial.readline()
        if _printable and (b'#AAM' in message): print(message) # TODO: What's b'#AAM'?
        _client.send(message)

serial_mcu = serial.Serial(args.port, args.debug, timeout=1)
#debug_mcu = serial.Serial('/dev/ttyAMA1', args.debug, timeout=1)

address, port = args.host.split(":")
client = clients.TCPClient(address, int(port), serial_mcu, args.statusPin, args.debug)

## Uncomment for third serial connection, used for debug
# debug = serial.Serial('/dev/serial0', 115200)
# debug_client = clientClass.UART_TCPClient("10.0.0.106", 9000, debug)

client.connect()

receiveThread_Serial = threading.Thread(target=start_UART_relay, args = (serial_mcu, client))
#receiveThread_Debug = threading.Thread(target=start_UART_relay, args = (debug_mcu, client, True))

receiveThread_Serial.start()
#receiveThread_Debug.start()
