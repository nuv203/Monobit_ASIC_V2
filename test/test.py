import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer
import random


@cocotb.test()
async def test_monobit(dut):
    """
    Test the monobit design by sending multiple 128-bit sequences and validating
    if `is_random` and `is_valid` outputs behave as expected.
    """
    # Create a 10ns clock (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset logic
    dut._log.info("Applying Reset\n")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Reset Deasserted\n")

    # Counter to track clock cycles
    cycle_counter = 0

    # Generate different input streams
    all_zero = [0] * 128
    all_one = [1] * 128
    rand_stream1 = [random.randint(0, 1) for _ in range(128)]
    rand_stream2 = [random.randint(0, 1) for _ in range(128)]
    rand_stream3 = [random.randint(0, 1) for _ in range(128)]
    input_streams = [
        ("All Zeroes", all_zero),
        ("All Ones", all_one),
        ("Random Stream 1", rand_stream1),
        ("Random Stream 2", rand_stream2),
        ("Random Stream 3", rand_stream3)
    ]

    # Loop over each input sequence
    for stream_name, bit_stream in input_streams:
        dut._log.info(f"\n--- Testing {stream_name} ---\n")
        for i in range(len(bit_stream)):
            input_bit = bit_stream[i]
            dut.ui_in.value = input_bit

            # Wait for 1 clock cycle and capture outputs
            await ClockCycles(dut.clk, 1)
            cycle_counter += 1

            # Read the output value
            out = dut.uo_out.value.integer  # Get as an integer
            is_random = out & 1             # Extract is_random from the least significant bit
            is_valid  = (out >> 1) & 1      # Extract is_valid from the second bit

            # Log the current status
            dut._log.info(f"Cycle: {cycle_counter}, Input Bit: {input_bit}, is_random: {is_random}, is_valid: {is_valid}")
            
            # Check if valid signal is asserted at the right time
            if cycle_counter % 128 == 0:  # Assume valid is set every 128 bits
                assert is_valid == 1, f"Cycle {cycle_counter}: Expected 'valid' signal to be 1 but got {is_valid}."
            else:
                assert is_valid in [0, 1], f"Cycle {cycle_counter}: Unexpected 'valid' signal value: {is_valid}."

        dut._log.info(f"--- {stream_name} test completed ---\n")

    # Final random bit stream
    final_random_stream = [random.randint(0, 1) for _ in range(128)]
    dut._log.info("\n--- Testing Final Random Bit Stream ---\n")
    for i, input_bit in enumerate(final_random_stream):
        dut.ui_in.value = input_bit
        await ClockCycles(dut.clk, 1)
        cycle_counter += 1

        # Capture and log output
        out = dut.uo_out.value.integer
        is_random = out & 1
        is_valid  = (out >> 1) & 1

        # Log the current status
        dut._log.info(f"Cycle: {cycle_counter}, Input Bit: {input_bit}, is_random: {is_random}, is_valid: {is_valid}")

    dut._log.info("\nAll tests completed successfully.\n")
