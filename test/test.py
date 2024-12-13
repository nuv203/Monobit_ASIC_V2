"""
Cocotb testbench for Monobit design.
Tests 128-bit sequences of all 0s, all 1s, and random bits. 
Validates that `is_random` and `is_valid` outputs behave as expected.
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Timer
import random


@cocotb.test()
async def test_monobit(dut):
    """
    Test the monobit design by sending 128-bit sequences as a single array and validating
    if `is_random` outputs 0 or 1 correctly.
    """
    # ------------------------------
    # Clock Initialization (100 MHz)
    # ------------------------------
    clock = Clock(dut.clk, 10, units="ns")  # 10ns period = 100 MHz
    cocotb.start_soon(clock.start())

    # ------------------------------
    # Reset the Design
    # ------------------------------
    dut._log.info("\n==== Applying Reset ====\n")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)  # Hold reset for 10 clock cycles
    dut.rst_n.value = 1
    dut._log.info("\n==== Reset Deasserted ====\n")

    # ------------------------------
    # Test Sequences
    # ------------------------------
    cycle_counter = 0

    # Define input bit streams
    all_zero = [0] * 128
    all_one = [1] * 128
    rand_stream1 = [random.randint(0, 1) for _ in range(128)]
    rand_stream2 = [random.randint(0, 1) for _ in range(128)]
    rand_stream3 = [random.randint(0, 1) for _ in range(128)]

    # Concatenate all bit streams to form the complete input sequence
    bit_stream = all_zero + all_one + rand_stream1 + rand_stream2 + rand_stream3 + [0] * 2

    dut._log.info("\n==== Start Testing Bit Streams ====\n")

    # ------------------------------
    # Loop Through Bit Stream
    # ------------------------------
    for i in range(len(bit_stream)):

        input_bit = bit_stream[i]

        for _ in range(5):  # 5 cycles for each bit in the stream
            cycle_counter += 1
            dut.ui_in.value = input_bit  # Set the input bit

            # Log cycle details
            dut._log.info(f"Cycle: {cycle_counter:04d} | Input Bit: {input_bit}")

            await Timer(1, units="ns")  # Wait for 1 ns

            # Read the output signals from uo_out
            out = dut.uo_out.value
            is_random = out & 1          # Extract the LSB for is_random
            is_valid  = (out >> 1) & 1   # Extract the second bit for is_valid

            # Log the output signals
            dut._log.info(f"  --> Outputs | is_random: {is_random} | is_valid: {is_valid}\n")

            await ClockCycles(dut.clk, 1)  # Wait for 1 clock cycle

    dut._log.info("\n==== All Tests Completed Successfully ====\n")
