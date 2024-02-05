import socket
import threading
import time
# import datetime
# from datetime import timezone
import RPi.GPIO as GPIO

# TODO: Switch to logger
# TODO: Add timestamp and traceback to outputs
# TODO: Seperate TCPClient, Serial driver and relay into separate classes


class TCPClient:
    """ TCP-UART Relay """

    def __init__(self, host, port, uart, statusPin = None, debug : bool = False):
        self.host = host
        self.port = port
        self.uart = uart
        self.statusPin = statusPin
        self.debug = debug
        
        self.client = None
        self.connected = False
        self.receiveThread = threading.Thread(target=self.receive)
        self.disconnectFlag = False
        
        if self.statusPin is not None:
            GPIO.setmode(GPIO.BOARD)
            GPIO.setup(self.statusPin, GPIO.OUT)
            GPIO.output(self.statusPin, 0)

    def connect(self):
        while not self.connected:
            try:
                print("Connecting...")
                self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                #self.client.settimeout()
                self.client.connect((self.host, self.port))
                
                print("Connected.")
                self.connected = True
                if self.statusPin is not None: GPIO.output(self.statusPin, 1)
                if not self.receiveThread.is_alive(): self.receiveThread.start()
            
            except Exception as e:
                print(e)
                print("Connection failed.")
                self.connected = False
                 
                print("Retrying connection in 5s...")
                time.sleep(5)

    def disconnect(self):
        if not self.connected:
            print("Disconnect failed - not connected.")
            return

        self.client.close()
        self.connected = False
        print("Disconnected.")
        if self.statusPin is not None: GPIO.output(self.statusPin, 0)

    def reconnect(self):
        if self.connected:
            self.disconnect()
            time.sleep(0.25)
        
        self.connect()

    def send(self, data):
        if not self.connected:
            print("Send failed - not connected.")
            return
        try:    
            self.client.sendall(data)
            if(self.debug): print(data)
        except Exception as e:
            print(e)
            print("Send failed.")

    def receive(self):
        while True:
            if not self.connected: continue

            try:
                message = self.client.recv(1024)
            except Exception as e:
                print(e)
                print("Host disconnected. Trying to reconnect...")
                # print(
                #     f'''
                #     ------------------------------
                #     Error occurred, message below:
                #     {e}
                #     ------------------------------
                #     '''
                #     )
                
                self.reconnect()
                continue
            
            # Message Handeling
            #decoded = ''.join(message).decode().strip()
            decoded = message.decode().strip().lower()
            if self.debug: print(f"Received message from topside: \"{decoded}\"")
            match decoded:
                case "reset":
                    print("Received RESET command. Resetting connection...")
                    self.reconnect()
                case _:
                    try:
                        # TODO: Send message or decoded?
                        if self.debug: print(f"Relaying message \"{message}\"")
                        self.uart.write(message)
                    except Exception as e:
                        print(e)
                        print("Error relaying message. Skipping...")
                        
                        #print(f"Received PROTOBUF msg from topside")
                        
