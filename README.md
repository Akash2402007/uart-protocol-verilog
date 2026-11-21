# UART Protocol Implementation Using Verilog HDL

## Overview

This project implements a UART (Universal Asynchronous Receiver-Transmitter) communication system using Verilog HDL. It contains a UART transmitter, UART receiver, baud-rate generator, and a top-level module that connects the transmitter output to the receiver input for loopback verification.

The design is simulated using Xilinx Vivado 2018.2.

## Features

- Separate UART transmitter and receiver modules.
- 8-bit data transmission, least-significant bit (LSB) first.
- Start-bit and stop-bit handling.
- Baud-rate enable generation for the transmitter and receiver.
- FSM-based transmitter and receiver control.
- Transmitter status output (`busy`).
- Receiver data-valid output (`rdy`) and ready-clear control (`rdy_clr`).
- Synchronous reset handling in the transmitter and receiver.
- Basic stop-bit validation in the receiver.
- Loopback connection from the transmitter's serial output to the receiver's serial input.

## Project Structure

```text
uart-protocol-verilog/
├── baud_rate_generator.v
├── uart_tx.v
├── uart_rx.v
├── uart_top.v
├── uart_top_test.v
└── README.md
```

> The testbench filename and module name should match the files in your Vivado project. In this project, the simulation top is `uart_top_test` if that is the module declared in `uart_top_test.v`.

## Module Description

| Module | Description |
|---|---|
| `baud_rate_generator` | Generates enable pulses for the UART transmitter and receiver. |
| `uart_tx` | Converts parallel 8-bit input data into a serial UART frame. |
| `uart_rx` | Detects and receives the serial frame, reconstructs the 8-bit data, and asserts the ready signal. |
| `uart_top` | Connects the baud-rate generator, transmitter, and receiver. The transmitter output is looped back to the receiver input. |
| `uart_top_test` | Provides clock/reset stimulus, sends test data, and checks the received byte. |

## UART Frame Format

The transmitter sends one frame containing:

```text
Start bit | 8 data bits (LSB first) | Stop bit
    0     |       D0 ... D7          |    1
```

The design uses 8 data bits, no parity bit, and one stop bit (8-N-1 framing).

## Baud-Rate Configuration

The baud-rate generator uses counters with these terminal counts:

- TX counter: `5207` (counter period: 5208 system-clock cycles)
- RX counter: `324` (counter period: 325 system-clock cycles)

For a 50 MHz system clock, these values give approximately:

- TX bit rate: `50,000,000 / 5208` ≈ **9600.6 baud**
- RX enable rate: `50,000,000 / 325` ≈ **153.85 kHz**, approximately 16 times the TX bit rate

These counter values are intended for a 50 MHz system clock. Recalculate them if the clock frequency is changed.

## Top-Level Connections

The top-level module accepts:

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | System clock |
| `rst` | Input | Reset signal |
| `data_in[7:0]` | Input | Parallel byte to transmit |
| `wr_en` | Input | Starts a transmission when the transmitter is idle |
| `rdy_clr` | Input | Clears the receiver's data-ready indication |
| `busy` | Output | Indicates that the transmitter is transmitting |
| `rdy` | Output | Indicates that a received byte is ready |
| `data_out[7:0]` | Output | Received parallel byte |

Internally, the transmitter's `tx` output is connected to the receiver's `rx` input for loopback testing.

## Simulation

1. Add `baud_rate_generator.v`, `uart_tx.v`, `uart_rx.v`, and `uart_top.v` to **Design Sources** in Vivado.
2. Add `uart_top_test.v` to **Simulation Sources**.
3. Set `uart_top_test` as the simulation top (use the actual testbench module name declared in the file).
4. Run **Run Behavioral Simulation**.
5. Allow the simulation to run until the testbench completes.

The testbench used for loopback verification applies a system clock and reset, transmits `8'hA5`, waits for the receiver's ready indication, and compares the received byte with the transmitted byte.

Expected successful check:

```text
PASS: UART transmission and reception successful
```

This output is the expected testbench message when the received byte matches the transmitted byte; it is not a claim of hardware testing.

## Tools

- Verilog HDL
- Xilinx Vivado 2018.2

## Current Scope and Limitations

- The supplied testbench verifies a local transmitter-to-receiver loopback path.
- The baud-rate counter values are configured for a 50 MHz system clock.
- The receiver performs basic stop-bit validation; a separate framing-error status output is not included.
- The project has been simulated in Vivado. No physical UART hardware testing is claimed here.

## Author

**Akash Singh Anand**

Electronics and Communication Engineering
