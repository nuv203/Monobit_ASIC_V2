# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    dut._log.info("Test project behavior")
    a_vals = [i for i in range(16)] #makes an array [0...15]
    b_vals = [i for i in range(16)] #makes an array [0...15]
    
    for i in range(len(a_vals)):
        for j in range(len(b_vals)):
            # Set the input values you want to test
            dut.a.value = a_vals[i]
            dut.b.value = b_vals[j]
            
            # Wait for one clock cycle to see the output values
            await ClockCycles(dut.clk, 10)
          
            # The following assersion is just an example of how to check the output values.
            # Change it to match the actual expected output of your module:
            dut._log.info(f"value of outputs are: {dut.sum.value} and {dut.carry_out.value}.")
            assert int(dut.sum.value) == ((a_vals[i] + b_vals[j])%16) and int(dut.carry_out.value) == ((a_vals[i] + b_vals[j]) >= 16)  
        
    
   

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
    
