import socket
import threading
import time
import datetime
from datetime import timezone
#import RPi.GPIO as GPIO

class TCPClient:


    def __init__(self, host, port, uart, statusPin):
       self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
       self.connected = False
       self.receiveThread = threading.Thread(target=self.receive)
       self.host = host
       self.port = port
       self.disconnectFlag = False
       self.uart = uart
       #GPIO.setmode(GPIO.BOARD)
       self.statusPin = statusPin
       #GPIO.setup(self.statusPin, GPIO.OUT)
       #GPIO.output(self.statusPin, 0)
    
    def intializeSocket(self):
        self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    def connect(self):
        while True:
            try:
                print("Connecting...")
                self.intializeSocket()
                self.client.connect((self.host, self.port))
                self.connected = True
                print("Connected.")
                #GPIO.output(self.statusPin, 1)
                if self.receiveThread.is_alive():
                    return
                self.receiveThread.start()
                return
            except Exception as e:
                print(e)
                self.intializeSocket()
                self.connected = False
                #GPIO.output(self.statusPin, 0)
                #print("Connecting Failed. Trying again in 5 seconds...")
                time.sleep(0.5)

        
    def disconnect(self):
        if self.connected == False:
            print("Not connected.")
            return
        
        self.client.close()
        self.disconnectFlag = True
        #GPIO.output(self.statusPin, 0)
        print("Disconnected.")

    def send(self, data):
        if self.connected == False:
            print("Not connected.")
            return
        try:    
            self.client.sendall(data)
        except Exception:
            print("Error on send.")


    def receive(self):
        while(True):
            if self.disconnectFlag:
                break

            try:
                #self.client.settimeout()
                message = self.client.recv(1024)
                #message = message.decode().strip()
                #self.uart.write(message.encode())
                #print(message)
            except Exception as e:
                print(
                    f'''
                    ------------------------------
                    Error occurred, message below:
                    {e}
                    ------------------------------
                    '''
                    )
                print("Lost host. Trying to reconnect...")
                
                self.disconnect()
                self.connected = False
                self.connect()
                continue

            try:
		#msg_copy = ''.join(message)
                #decoded = msg_copy.decode().strip()
                #if (decoded.endswith('K.')): self.uart.write(message)
                #if (decoded == "RESET"): self.reset()
                self.uart.write(message)
		#print(f"Received msg from topside:\n{decoded}")
            except Exception as e:
                pass
                #print(f"Received PROTOBUF msg from topside")
                #self.uart.write(message)
            #except Exception as e:
            #    print("Error on receive.")
            #    print(e)
            #    break

    def reset(self):
        print("Received RESET message; starting RESET sequence.")
        self.disconnect()
        time.sleep(0.25)
        self.connect()
        print("Finished RESET sequence.")
