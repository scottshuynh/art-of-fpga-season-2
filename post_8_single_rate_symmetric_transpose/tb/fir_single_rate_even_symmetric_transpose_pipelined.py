import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb.types import LogicArray

import math

CLK_PERIOD_NS = 1


@cocotb.test()
async def test_coefficient_scoreboard(dut):
    cocotb.start_soon(Clock(dut.clk_i, CLK_PERIOD_NS, "ns").start())
    DATA_W = dut.DATA_W.value
    TAPS = dut.TAPS.value
    M_PIPE = dut.M_PIPE.value
    LATENCY = 4 + M_PIPE

    # Generate an impulse to test the output for its taps
    await RisingEdge(dut.clk_i)
    impulse = 1
    dut.data_i.value = impulse
    await RisingEdge(dut.clk_i)
    dut.data_i.value = 0

    for _ in range(LATENCY - 1):
        await RisingEdge(dut.clk_i)

    # Scoreboard test against the taps
    for idx in range(len(TAPS)):
        await FallingEdge(dut.clk_i)
        expected = impulse * TAPS[idx]
        got = LogicArray(dut.data_o.value).signed_integer
        assert expected == got, f"Expecting: {expected}, Got: {got}"
        await RisingEdge(dut.clk_i)

    await RisingEdge(dut.clk_i)
