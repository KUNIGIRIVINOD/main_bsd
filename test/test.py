# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0


# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start traffic light controller test")

    # Set the clock period to 10 us (100 kHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    dut._log.info("Reset released")

    # Wait a few cycles and check outputs
    await ClockCycles(dut.clk, 1)
    val = int(dut.uo_out.value)
    main_street = val & 0b11
    side_street = (val >> 2) & 0b11
    pedestrian  = (val >> 4) & 0b1

    # Initially should be MAIN_GREEN (main=10, side=00, ped=0)
    assert main_street == 0b10, f"Expected main_street=10, got {main_street:02b}"
    assert side_street == 0b00, f"Expected side_street=00, got {side_street:02b}"
    assert pedestrian == 0, f"Expected pedestrian=0, got {pedestrian}"

    dut._log.info("State MAIN_GREEN OK")

    # Advance enough cycles to reach MAIN_YELLOW
    await ClockCycles(dut.clk, 3)
    val = int(dut.uo_out.value)
    main_street = val & 0b11
    side_street = (val >> 2) & 0b11
    pedestrian  = (val >> 4) & 0b1

    assert main_street == 0b01, f"Expected main_street=01 (YELLOW), got {main_street:02b}"
    dut._log.info("State MAIN_YELLOW OK")

    # Advance to SIDE_GREEN
    await ClockCycles(dut.clk, 3)
    val = int(dut.uo_out.value)
    main_street = val & 0b11
    side_street = (val >> 2) & 0b11
    pedestrian  = (val >> 4) & 0b1

    assert side_street == 0b10, f"Expected side_street=10 (GREEN), got {side_street:02b}"
    dut._log.info("State SIDE_GREEN OK")

    # Advance to PEDESTRIAN_CROSS
    await ClockCycles(dut.clk, 9)  # enough cycles to go through side yellow
    val = int(dut.uo_out.value)
    pedestrian = (val >> 4) & 0b1

    assert pedestrian == 1, "Expected pedestrian light ON"
    dut._log.info("State PEDESTRIAN_CROSS OK")

    dut._log.info("Traffic light FSM test completed successfully")


    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
