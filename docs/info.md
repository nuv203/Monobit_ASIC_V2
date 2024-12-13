<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# How it works

The `tt_um_monobit` module serves as the top-level wrapper for a hardware implementation of the Monobit randomness test. This test determines whether a binary sequence is random by counting the number of ones and zeros and checking for balance.

## Key components

### Input/Output Ports

- `ui_in`: An 8-bit input bus used to configure the test parameters.
  - 
- `uo_out`: An 8-bit output bus to report results and status flags.
- `uio_in` and `uio_out`: Unused in this implementation, set to zero.
- `ena`, `clk`, and `rst_n`: Enable, clock, and active-low reset signals for the module.

### Internal Signals

- Signals such as `epsilon_rsc` and `is_random_rsc` handle the configuration and results of the randomness test.
- Synchronization signals (e.g., `triosy` signals) manage inter-module communication.

### Monobit Submodule

- The `monobit` submodule performs the core randomness test.
- It implements a state machine to iterate through the input sequence, count bits, and compute results.
- Outputs include `is_random_rsc` (indicating if the sequence is random) and `valid_rsc` (validity of the test result).

### FSM (Finite State Machine)

- A small FSM cycles through states to manage counting and result computation.
- The `fsm_output` drives the test logic and controls when results are updated.

### Output Logic

- Results such as the randomness determination and validity are mapped to specific bits of `uo_out` for easy observation.

# How to test

Testing was conducted using a Python script, `test.py`, which:

1. Configures the `tt_um_monobit` module via the `ui_in` bus.
2. Provides clock and reset signals to initialize and run the module.
3. Reads the results from the `uo_out` bus to validate the functionality.
4. Use test.py 

# External hardware

No external hardware is required for this module. The test is self-contained within the FPGA or simulation environment.

