/**
 * @file I2CCommunicator.hpp
 * @brief Custom I2C communicator. 
 * Runs only on DietPi and other Debian-based operating systems.
 *
 * @author 
 * Alae B.
 * [ADD NAME HERE - FOLLOW ALPHABETICAL ORDER]
 *
 * @copyright 
 * Copyright (c) 2024 Kelpie Robotics. All rights reserved.
 */

#ifndef I2CCOMMUNICATOR_HPP
#define I2CCOMMUNICATOR_HPP

#include <string>
#include <cstdint>

class I2CCommunicator {
public:
    /**
     * @brief Constructor that initializes and opens the I2C bus for communication.
     * @param bus_path The file path of the I2C bus (e.g., "/dev/i2c-1").
     * @param device_address The 7-bit I2C address of the target device.
     * @throws std::runtime_error If the bus cannot be opened or the device cannot be accessed.
     */
    I2CCommunicator(const std::string& bus_path, int device_address);

    /**
     * @brief Destructor that closes the I2C bus.
     */
    ~I2CCommunicator();

    /**
     * @brief Writes data to the I2C device.
     * @param data Pointer to the data buffer to be written.
     * @param length The number of bytes to write.
     * @throws std::runtime_error If the write operation fails.
     */
    void writeData(const uint8_t* data, size_t length);

    /**
     * @brief Reads data from the I2C device.
     * @param buffer Pointer to the buffer where the read data will be stored.
     * @param length The number of bytes to read.
     * @throws std::runtime_error If the read operation fails.
     */
    void readData(uint8_t* buffer, size_t length);

private:
    std::string bus_path_;
    int device_address_;
    int i2c_file_descriptor_;

    /**
     * @brief Opens the I2C bus for communication.
     * @throws std::runtime_error If the bus cannot be opened.
     */
    void openBus();

    /**
     * @brief Closes the I2C bus.
     */
    void closeBus();
};

#endif // I2CCOMMUNICATOR_HPP