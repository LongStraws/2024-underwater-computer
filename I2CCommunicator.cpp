/**
 * @file I2CCommunicator.cpp
 * @brief Implementation of custom I2C communicator. 
 * This implementation uses direct system calls (open, read, write, ioctl, and close) for I2C communication. 
 * These calls are standard in Linux and are provided by the Linux kernel.
 *
 * @author 
 * Alae B.
 * [ADD NAME HERE - FOLLOW ALPHABETICAL ORDER]
 *
 * @copyright 
 * Copyright (c) 2024 Kelpie Robotics. All rights reserved.
 */

#include "I2CCommunicator.hpp"
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdexcept>

/**
 * Initializes and opens the I2C bus for communication.
 * @param bus_path The file path of the I2C bus (e.g., "/dev/i2c-1").
 * @param device_address The 7-bit I2C address of the target device.
 * @throws std::runtime_error If the bus cannot be opened or the device cannot be accessed.
 */
I2CCommunicator::I2CCommunicator(const std::string& bus_path, int device_address)
    : bus_path_(bus_path), device_address_(device_address), i2c_file_descriptor_(-1) {
    openBus();
}

I2CCommunicator::~I2CCommunicator() {
    closeBus();
}

// Called above
void I2CCommunicator::openBus() {
    i2c_file_descriptor_ = open(bus_path_.c_str(), O_RDWR);
    if (i2c_file_descriptor_ < 0) {
        throw std::runtime_error("Failed to open the I2C bus");
    }

    if (ioctl(i2c_file_descriptor_, I2C_SLAVE, device_address_) < 0) {
        close(i2c_file_descriptor_);
        throw std::runtime_error("Failed to set I2C device address");
    }
}

// Called above
void I2CCommunicator::closeBus() {
    if (i2c_file_descriptor_ >= 0) {
        close(i2c_file_descriptor_);
    }
}

/**
 * Writes data to the I2C device.
 * @param data Pointer to the data buffer to be written.
 * @param length The number of bytes to write.
 * @throws std::runtime_error If the write operation fails.
 */
void I2CCommunicator::writeData(const uint8_t* data, size_t length) {
    // static_cast<ssize_t>(length): This casts length from size_t (unsigned) to ssize_t (signed) 
    // We have to do that because the return type of write is ssize_t
    if (write(i2c_file_descriptor_, data, length) != static_cast<ssize_t>(length)) {
        throw std::runtime_error("Failed to write to the I2C bus");
    }
}

/**
 * Reads data from the I2C device.
 * @param buffer Pointer to the buffer where the read data will be stored.
 * @param length The number of bytes to read.
 * @throws std::runtime_error If the read operation fails.
 */
void I2CCommunicator::readData(uint8_t* buffer, size_t length) {
    // static_cast<ssize_t>(length): This casts length from size_t (unsigned) to ssize_t (signed) 
    // We have to do that because the return type of write is ssize_t     
    if (read(i2c_file_descriptor_, buffer, length) != static_cast<ssize_t>(length)) {
        throw std::runtime_error("Failed to read from the I2C bus");
    }
}
