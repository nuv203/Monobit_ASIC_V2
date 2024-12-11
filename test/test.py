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

    await Timer(50, units = 'ns')
    dut.rst_n.value = 1

    dut.rst_n.value = 0
    await Timer(50, units='ns')
    dut.rst_n.value = 1
    await Timer(50, units='ns')

    # Test each state transition and output logic
    epsilon_values = [i for i in range(255)]
    for epsilon_value in epsilon_values:  # Test for both epsilon values
        dut.ui_in.value = epsilon_value

        # Wait for a positive edge on the clock
        await Timer(50, units='ns')
        
        # Read outputs and validate expected behavior

        # Constants as defined in C++
        FREQ = 256
        BOUNDRY = 29  # Boundary adjusted for integer sum
        TARGET_BITS = 128
        
        class Monobit:
            def __init__(self):
                self.sum = 0
                self.bit_count = 0
                self.is_random = False
                self.valid = False
        
            def process_bit(self, epsilon):
                # Update sum based on epsilon: +1 if true, -1 if false
                self.sum += 1 if epsilon else -1
        
                # Reset valid and is_random each cycle
                self.is_random = False
                self.valid = False
        
                # Check if the bit count has reached 127 (since counting starts from 0, 127 means 128 bits)
                if self.bit_count == 127:
                    # Determine if the sum is within the boundary range
                    self.is_random = -BOUNDRY <= self.sum <= BOUNDRY
                    self.valid = True
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
        
        monobit_processor.process_bit(epsilon_value % 2)  # Alternating pattern of 1s and 0s
        
        # Retrieve and print the status after some processing
        status = monobit_processor.get_status()
        print(f"Is Random: {status['is_random']}, Valid: {status['valid']}, Sum: {status['sum']}, Bit Count: {status['bit_count']}")

        is_random_expected = status.is_random # Expected output, set as per your design needs
        valid_expected = status.valid      # Expected output, set as per your design needs
        assert dut.uo_out.value[0] == is_random_expected
        assert dut.uo_out.value[1] == valid_expected

        # Print output state for debugging
        dut._log.info(f"Epsilon: {epsilon_value}, Is_Random: {dut.uo_out.value[0]}, Valid: {dut.uo_out.value[1]}")

        # Add further checks as needed for complete coverage
