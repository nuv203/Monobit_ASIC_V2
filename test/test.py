# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def tt_um_monobit (dut):

    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())

    # Initialize Inputs
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    dut.rst_n.value = 0

    await Timer(50, units='ns')
    dut.rst_n.value = 1

    await Timer(50, units='ns')
    dut.rst_n.value = 0
    await Timer(50, units='ns')
    dut.rst_n.value = 1
    await Timer(50, units='ns')

    # Constants
    FREQ = 256
    BOUNDRY = 29
    TARGET_BITS = 128
        
    class Monobit:
        def __init__(self):
            self.sum = 0
            self.bit_count = 0
            self.is_random = 0
            self.valid = 0
    
        def process_bit(self, epsilon):
            self.sum += 1 if epsilon else -1
            self.is_random = 0
            self.valid = 0
    
            if self.bit_count == 127:
                if -BOUNDRY <= self.sum <= BOUNDRY:
                    self.is_random = 1
                else:
                    self.is_random = 0
                self.valid = 1
                self.sum = 0
    
            self.bit_count = (self.bit_count + 1) % TARGET_BITS
    
        def get_status(self):
            return {
                "is_random": self.is_random,
                "valid": self.valid,
                "sum": self.sum,
                "bit_count": self.bit_count
            }

    monobit_processor = Monobit()

    # Process 128 bits using 170 (binary 10101010) repeated
    bit_pattern = 170  # Binary 10101010
    for i in range(128):
        rnd = (bit_pattern >> (i % 8)) & 1  # Cycle through 10101010 repeatedly
        dut.ui_in.value = rnd  # Send input bit
        monobit_processor.process_bit(rnd)  # Process input bit
        await Timer(50, units='ns')  # Wait for clock
    
    # Retrieve and print status
    status = monobit_processor.get_status()
    print(f"Is Random: {status['is_random']}, Valid: {status['valid']}, Sum: {status['sum']}, Bit Count: {status['bit_count']}")

    is_random_expected = status['is_random']
    valid_expected = status['valid']

    # Check the values
    assert dut.uo_out.value[0] == is_random_expected, f"Expected is_random={is_random_expected}, Got {dut.uo_out.value[0]}"
    assert dut.uo_out.value[1] == valid_expected, f"Expected valid={valid_expected}, Got {dut.uo_out.value[1]}"

    # Print the output for debugging
    dut._log.info(f"Is_Random: {dut.uo_out.value[0]}, Valid: {dut.uo_out.value[1]}")
