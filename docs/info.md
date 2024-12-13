# How it works

The `tt_um_monobit` module is a top-level wrapper for a hardware implementation of the Monobit randomness test. This test evaluates whether a binary sequence is random by comparing the number of `1`s and `0`s. If the counts are sufficiently balanced, the sequence is considered random.

## Key Components

### Input/Output Ports

- **`ui_in`**: An 8-bit input bus used to configure the randomness test parameters.
  - `ui_in[0]`: Maps directly to `epsilon_rsc`, which specifies the threshold for randomness.
  
- **`uo_out`**: An 8-bit output bus for test results and status flags.
  - `uo_out[0]`: `is_random_rsc` (1 if the sequence is random, 0 otherwise).
  - `uo_out[1]`: `valid_rsc` (1 if the test result is valid, 0 otherwise).
  - `uo_out[5–7]`: Synchronization flags related to `is_random_rsc`, `valid_rsc`, and `epsilon_rsc`.

- **`uio_in` and `uio_out`**: General-purpose I/O buses, unused in this module (set to `0`).

- **`ena`, `clk`, and `rst_n`**: Enable, clock, and active-low reset signals control the module’s operation.

---

## Internal Signals and Registers

- **`epsilon_rsc`**: Threshold for deciding the randomness of a binary sequence. 
- **`is_random_rsc`**: Indicates whether the input sequence is random (1 for random, 0 for not random).
- **`valid_rsc`**: Indicates if the randomness result is valid (1 if valid, 0 otherwise).
- **`bit_count_sva`**: Tracks the number of bits processed.
- **`sum_sva`**: Stores the cumulative signed difference between the number of `1`s and `0`s.
- **Synchronization Signals**: `is_random_triosy`, `valid_triosy`, and `epsilon_triosy` provide control flow between modules.

---

## CCS Functions

The CCS (Component Communication Signals) functions ensure smooth data flow and synchronization across modules. Key CCS components include:

1. **CCS Synchronization (`triosy` Signals)**:
   - **Purpose**: Synchronize operations between input, processing, and output stages.
   - **Implementation**:
     - `is_random_triosy` ensures the `is_random_rsc` signal is updated at the correct time.
     - `valid_triosy` manages the update timing for `valid_rsc`.
     - `epsilon_triosy` ensures consistent configuration for `epsilon_rsc`.

2. **CCS Signal Read and Write Operations**:
   - The CCS interfaces handle input/output communication between submodules, ensuring that data is processed in a synchronized and predictable manner.
   - Example functions:
     - `readslicef`: Reads a slice of a vector signal, used for extracting specific bits of input.
     - `conv_s2u`: Converts signed data to unsigned format for arithmetic and comparison operations.

---

## Monobit Submodule

The `monobit` submodule is the core computational engine of the module. Its design includes:

1. **Finite State Machine (FSM)**:
   - A 5-state FSM manages the entire Monobit test operation:
     - **`main_C_0`**: Reset state. Initializes internal signals and prepares the module.
     - **`main_C_1`**: Begins bit processing.
     - **`main_C_2`**: Updates counters (`sum_sva` and `bit_count_sva`).
     - **`main_C_3`**: Prepares final results.
     - **`main_C_4`**: Writes results to output ports.

2. **Counter Logic**:
   - **`bit_count_sva`**: Increments on every clock cycle to track how many bits have been processed.
   - **`sum_sva`**: Tracks the cumulative signed difference between the number of `1`s and `0`s in the input sequence. 

3. **Randomness Decision**:
   - After all bits are processed, `sum_sva` is compared to `epsilon_rsc`:
     - If `|sum_sva| <= epsilon_rsc`, the sequence is random (`is_random_rsc = 1`).
     - Otherwise, the sequence is not random (`is_random_rsc = 0`).

4. **Output Signals**:
   - The submodule drives `is_random_rsc` and `valid_rsc`, which are routed to the top-level `uo_out` bus.

---

## Inner Modules and Functions

### Helper Functions

- **`readslicef`**:
  - Extracts a slice of a signal, commonly used for accessing specific bits of input or intermediate data.
  - Example: `readslicef(signal, start, end)` returns a subset of bits from the `signal`.

- **`conv_s2u`**:
  - Converts signed data to unsigned format for operations where unsigned arithmetic is required.
  - Example: Converts `sum_sva` for comparison with `epsilon_rsc`.

### Submodule Design

- **Monobit Logic Block**:
  - Implements the bit-counting and randomness decision logic.
  - Efficiently processes input bits in a pipeline, ensuring each bit contributes to the final `sum_sva`.

- **Result Logic**:
  - Maps `is_random_rsc` and `valid_rsc` to the appropriate `uo_out` signals.
  - Drives synchronization flags (`is_random_triosy` and `valid_triosy`) to signal the readiness of results.

---

# How to test

Testing was conducted using a Python script, `test.py`, with the following steps:

1. **Initialization**:
   - Configure the `ui_in` bus with the desired `epsilon_rsc` threshold.
   - Apply a clock (`clk`) and reset (`rst_n`) signals to initialize the module.

2. **Input Sequences**:
   - Feed binary sequences to the module, clocking each bit through.
   - Observe internal counters (`bit_count_sva` and `sum_sva`) via simulation.

3. **Output Validation**:
   - Read the `uo_out` bus to retrieve `is_random_rsc` and `valid_rsc`.
   - Compare the results against expected outcomes for known random and non-random sequences.

---

# External hardware

No external hardware is required. The module operates within an FPGA or a simulation environment, using built-in clocks and input/output signals.
