# # SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# # SPDX-License-Identifier: Apache-2.0

# import cocotb
# from cocotb.triggers import RisingEdge, Timer
# from cocotb.clock import Clock

# @cocotb.test()
# async def tt_um_monobit (dut):

#     cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())

#     # Initialize Inputs
#     dut.ui_in.value = 0
#     dut.uio_in.value = 0
#     dut.ena.value = 1
#     dut.rst_n.value = 0

#     await Timer(50, units='ns')
#     dut.rst_n.value = 1

#     await Timer(50, units='ns')
#     dut.rst_n.value = 0
#     await Timer(50, units='ns')
#     dut.rst_n.value = 1
#     await Timer(50, units='ns')

#     # Constants
#     FREQ = 256
#     BOUNDRY = 29
#     TARGET_BITS = 128
        
#     class Monobit:
#         def __init__(self):
#             self.sum = 0
#             self.bit_count = 0
#             self.is_random = 0
#             self.valid = 0
    
#         def process_bit(self, epsilon):
#             self.sum += 1 if epsilon else -1
#             self.is_random = 0
#             self.valid = 0
    
#             if self.bit_count == 127:
#                 if -BOUNDRY <= self.sum <= BOUNDRY:
#                     self.is_random = 1
#                 else:
#                     self.is_random = 0
#                 self.valid = 1
#                 self.sum = 0
    
#             self.bit_count = (self.bit_count + 1) % TARGET_BITS
    
#         def get_status(self):
#             return {
#                 "is_random": self.is_random,
#                 "valid": self.valid,
#                 "sum": self.sum,
#                 "bit_count": self.bit_count
#             }

#     monobit_processor = Monobit()

#     # Process 128 bits using 170 (binary 10101010) repeated
#     bit_pattern = 170  # Binary 10101010
#     for i in range(128):
#         rnd = (bit_pattern >> (i % 8)) & 1  # Cycle through 10101010 repeatedly
#         dut.ui_in.value = rnd  # Send input bit
#         monobit_processor.process_bit(rnd)  # Process input bit
#         await Timer(50, units='ns')  # Wait for clock
    
#     # Retrieve and print status
#     status = monobit_processor.get_status()
#     print(f"Is Random: {status['is_random']}, Valid: {status['valid']}, Sum: {status['sum']}, Bit Count: {status['bit_count']}")

#     is_random_expected = status['is_random']
#     valid_expected = status['valid']

#     # Check the values
#     await Timer(50, units='ns')
#     assert dut.uo_out.value[0] == is_random_expected, f"Expected is_random={is_random_expected}, Got {dut.uo_out.value[0]}"
#     assert dut.uo_out.value[1] == valid_expected, f"Expected valid={valid_expected}, Got {dut.uo_out.value[1]}"

#     # Print the output for debugging
#     dut._log.info(f"Is_Random: {dut.uo_out.value[0]}, Valid: {dut.uo_out.value[1]}")

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

@cocotb.test()
async def test_monobit(dut):
    """
    Test the monobit design by sending 128-bit sequences as a single array and validating
    if `is_random` outputs 0 or 1 correctly.
    """
    # Create a 10ns clock (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset the design
    dut.rst_n <= 0
    await ClockCycles(dut.clk, 5)  # Hold reset for 5 clock cycles
    dut.rst_n <= 1

    # Configuration for the test
    SEQUENCE_LENGTH = 128  # Each sequence contains 128 bits
    corner_cases = [
        [1] * SEQUENCE_LENGTH,  # All 1s
        [0] * SEQUENCE_LENGTH   # All 0s
    ]
    random_sequences = [[random.randint(0, 1) for _ in range(SEQUENCE_LENGTH)] for _ in range(10)]

    # Combine corner cases and random sequences
    test_sequences = corner_cases + random_sequences

    # Run tests for all sequences
    for idx, sequence in enumerate(test_sequences):
        dut._log.info(f"Testing sequence {idx + 1}/{len(test_sequences)}")

        # Apply the sequence as an array
        for bit in sequence:
            dut.ui_in.value <= bit
            await RisingEdge(dut.clk)

        # Wait for the result to be valid
        await ClockCycles(dut.clk, 1)

        # Capture outputs
        is_random = int(dut.uo_out.value[0])
        valid = int(dut.uo_out.value[1])

        # Validate outputs
        assert valid == 1, f"Sequence {idx + 1}: Valid signal was not asserted."

        if idx == 0:  # All 1s
            assert is_random == 0, f"Failed for all 1s. Expected 0, got {is_random}."
        elif idx == 1:  # All 0s
            assert is_random == 0, f"Failed for all 0s. Expected 0, got {is_random}."
        else:
            dut._log.info(f"Random sequence result: {is_random}")

        dut._log.info(f"Sequence {idx + 1} passed with is_random={is_random}")

    dut._log.info("All tests completed successfully.")

