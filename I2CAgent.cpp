#include "I2CCommunicator.hpp"
#include <uxr/agent/transport/Server.hpp>
#include <uxr/agent/transport/custom/CustomAgent.hpp>
#include <cstring>
#include <iostream>

// Global instance of I2CCommunicator, adjust parameters as needed for your setup
I2CCommunicator* i2c_communicator = nullptr;

bool my_custom_transport_open(eprosima::uxr::CustomEndPoint* endpoint) {
    try {
        // Placeholder: Replace with actual bus path and device address
        std::string bus_path = "/dev/i2c-1";
        int device_address = 0x48; // Example device address
        i2c_communicator = new I2CCommunicator(bus_path, device_address);
        return true;
    } catch (const std::exception& e) {
        std::cerr << "Failed to open I2C BUS: " << e.what() << std::endl;
        return false;
    }
}

void my_custom_transport_close(eprosima::uxr::CustomEndPoint*) {
    if (i2c_communicator) {
        delete i2c_communicator;
        i2c_communicator = nullptr;
    }
}

bool my_custom_transport_write(eprosima::uxr::CustomEndPoint*, 
                               const uint8_t* buf, size_t len, 
                               eprosima::uxr::TransportRc& transport_rc) {
    try {
        i2c_communicator->writeData(buf, len);
        transport_rc = eprosima::uxr::TransportRc::ok;
        return true;
    } catch (const std::exception& e) {
        std::cerr << "Failed to write to I2C transport: " << e.what() << std::endl;
        transport_rc = eprosima::uxr::TransportRc::error;
        return false;
    }
}

bool my_custom_transport_read(eprosima::uxr::CustomEndPoint*, uint8_t* buf, size_t len, int timeout, eprosima::uxr::TransportRc& transport_rc) {
    try {
        i2c_communicator->readData(buf, len);
        transport_rc = eprosima::uxr::TransportRc::ok;
        return true;
    } catch (const std::exception& e) {
        std::cerr << "Failed to read from I2C transport: " << e.what() << std::endl;
        transport_rc = eprosima::uxr::TransportRc::error;
        return false;
    }
}

int main(int argc, char** argv) {
    eprosima::uxr::Middleware::Kind mw_kind = eprosima::uxr::Middleware::Kind::FASTDDS;
    eprosima::uxr::CustomEndPoint custom_endpoint;

    eprosima::uxr::CustomAgent custom_agent(
        "I2C_agent",
        &custom_endpoint,
        mw_kind,
        true, // Enable framing
        my_custom_transport_open,
        my_custom_transport_close,
        my_custom_transport_write,
        my_custom_transport_read);

    if (custom_agent.start()) {
        std::cout << "I2C Agent started successfully." << std::endl;
        // Keep the agent running
        while (true) {
            std::this_thread::sleep_for(std::chrono::hours(1));
        }
        custom_agent.stop();
    } else {
        std::cerr << "Failed to start I2C Agent." << std::endl;
    }

    return 0;
}