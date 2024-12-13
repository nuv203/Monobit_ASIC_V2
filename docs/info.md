<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# How it works

The `tt_um_monobit` module serves as the top-level wrapper for a hardware implementation of the Monobit randomness test. This test evaluates whether a binary sequence is random by comparing the count of `1`s and `0`s. If the counts are sufficiently balanced, the sequence is deemed random. 

## Key components

### Input/Output Ports

- **`ui_in`**: An 8-bit input bus that provides configuration for the test. For instance:
  - Bit 0 (`epsilon_rsc`) configures the acceptable margin for determining randomness.
  - Other bits may be used for additional future configurations.
  
- **`uo_out`**: An 8-bit output bus that reports the results and status of the test:
  - Bit 0: `is_random_rsc`, indicates whether the sequence is random.
  - Bit 1: `valid_rsc`, indicates the validity of the test results.
  - Bits 5–7: Other flags including synchronization and configuration status (`triosy` signals).

- **`uio_in` and `uio_out`**: General-purpose I/O buses that are unused in this implementation. They are assigned `0`.

- **`ena`, `clk`, and `rst_n`**: Standard enable, clock, and active-low reset signals to control the operation of the module.

---

### Internal Signals and Registers

- **`epsilon_rsc`**: A direct connection to `ui_in[0]`. This value determines the threshold for the test’s tolerance when comparing the count of `1`s and `0`s.
- **`is_random_rsc` and `valid_rsc`**: Signals that hold the randomness determination and the validity of the results, respectively.
- **`bit_count_sva`**: A 7-bit register used to keep track of the total number of bits processed in the input sequence.
- **`sum_sva`**: An 8-bit register that accumulates the difference between the number of `1`s and `0`s during the test.

---

### Monobit Submodule

The `monobit` submodule is the core computational block, responsible for processing the binary sequence and determining randomness. Its design includes the following components:

1. **State Machine (FSM)**:
   - A **5-state FSM** (`main_C_0` to `main_C_4`) controls the sequence of operations:
     - **`main_C_0`**: Initialization state; resets counters and prepares the module for processing.
     - **`main_C_1` – `main_C_3`**: Intermediate processing states that update the counters based on the input bits.
     - **`main_C_4`**: Final state that computes results and prepares outputs.
   - The state transitions occur on each clock cycle, ensuring synchronous operation.

2. **Counting Logic**:
   - A counter (`bit_count_sva`) keeps track of how many bits have been processed.
   - Another register (`sum_sva`) accumulates a signed difference of `1`s and `0`s, adjusted by the `epsilon_rsc` threshold.

3. **Result Computation**:
   - After all bits are processed, the difference in counts (`sum_sva`) is evaluated:
     - If the difference is within the range defined by `epsilon_rsc`, the sequence is considered random.
     - Otherwise, it is deemed non-random.
   - Flags like `is_random_rsc` and `valid_rsc` are set accordingly.

4. **Synchronization Signals**:
   - Synchronization outputs (`triosy` signals) ensure proper interfacing with other modules or external systems.

---

### Output Logic

- The results are mapped to the `uo_out` bus as follows:
  - **`uo_out[0]`**: Randomness determination (`is_random_rsc`).
  - **`uo_out[1]`**: Test validity (`valid_rsc`).
  - **`uo_out[5–7]`**: Additional flags such as `is_random_triosy`, `valid_triosy`, and `epsilon_triosy`.

- Unused bits (`uo_out[2–4]`) are assigned `0`.

---

### Additional Details

- The `fsm_output` signal drives the state machine and ensures that all operations, including bit counting and result calculation, are synchronized with the clock.
- Helper functions (`readslicef` and `conv_s2u`) perform bit-slicing and sign-to-unsigned conversions as required for internal computations.

---

# How to test

Testing was conducted using a Python script, `test.py`, which:

1. Configures the `tt_um_monobit` module via the `ui_in` bus, setting the `epsilon_rsc` value and enabling the module.
2. Provides clock and reset signals to initialize the module and begin processing.
3. Feeds binary sequences to the module for evaluation.
4. Reads the results from the `uo_out` bus to validate the functionality.
   - Results such as `is_random_rsc` and `valid_rsc` are compared against expected outcomes for known input sequences.

---

# External hardware

No external hardware is required. The module is fully self-contained and designed for use within an FPGA or simulation environment.


