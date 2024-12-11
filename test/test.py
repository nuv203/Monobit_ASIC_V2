# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def tt_um_monobit (dut):

    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())

    encryption_key = 0xAB

    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())
    # Initialize Inputs
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    dut.rst_n.value = 0

    await Timer(50, units='ns')
    dut.rst_n.value = 1

    dut.rst_n.value = 0
    await Timer(50, units='ns')
    dut.rst_n.value = 1
    await Timer(50, units='ns')

    # Test each state transition and output logic
    FREQ = 256
    BOUNDRY = 29  # Boundary adjusted for integer sum
    TARGET_BITS = 128
        
    class Monobit:
        def __init__(self):
            self.sum = 0
            self.bit_count = 0
            self.is_random = 0
            self.valid = 0
    
        def process_bit(self, epsilon):
            # Update sum based on epsilon: +1 if true, -1 if false
            self.sum += 1 if epsilon else -1
    
            # Reset valid and is_random each cycle
            self.is_random = 0
            self.valid = 0
    
            # Check if the bit count has reached 127 (since counting starts from 0, 127 means 128 bits)
            if self.bit_count == 127:
                # Determine if the sum is within the boundary range
                if -BOUNDRY <= self.sum <= BOUNDRY:
                    self.is_random = 1
                else:
                    self.is_random = 0
                self.valid = 1
                self.sum = 0  # Reset sum after processing a batch of 128 bits
    
            # Increment the bit count, and wrap it around if it reaches 128
            self.bit_count = (self.bit_count + 1) % TARGET_BITS
    
        def get_status(self):
            return {
                "is_random": self.is_random,
                "valid": self.valid,
                "sum": self.sum,
                "bit_count": self.bit_count
            }

    monobit_processor = Monobit()

    # Loop similar to the N_TESTS loop in the C++ testbench
    N_TESTS = 65536  # Same as in the C++ code
    
    i = 85
    # Recreate the C++ logic for `rnd`
    rnd = 0 if i <= 3 else i % 2  # This follows the C++ logic for `ac_int<1,false> rnd = i>3 ? i%2 :0;`
    
    # Set the input value in the design
    dut.ui_in.value = rnd  # Set the value of epsilon in the testbench (as per the C++ equivalent)
    
    # Call the monobit process
    monobit_processor.process_bit(rnd)  # Process the rnd bit with Monobit logic
    
    # Wait for a clock cycle (replicates the clock edge-based system in the C++)
    await Timer(50, units='ns')
    
    # Retrieve and print the status after processing all bits
    status = monobit_processor.get_status()
    print(f"Is Random: {status['is_random']}, Valid: {status['valid']}, Sum: {status['sum']}, Bit Count: {status['bit_count']}")

    is_random_expected = status['is_random']  # Expected output, set as per your design needs
    valid_expected = status['valid']  # Expected output, set as per your design needs

    # Check if the values from the DUT match the expected values
    assert dut.uo_out.value[0] == is_random_expected, f"Mismatch: Expected is_random {is_random_expected}, Got {dut.uo_out.value[0]}"
    assert dut.uo_out.value[1] == valid_expected, f"Mismatch: Expected valid {valid_expected}, Got {dut.uo_out.value[1]}"

    # Print output state for debugging
    dut._log.info(f"Is_Random: {dut.uo_out.value[0]}, Valid: {dut.uo_out.value[1]}")
