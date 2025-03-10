import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

CLK_PERIOD_NS = 1
@cocotb.test()
async def check_taps(dut):
    cocotb.start_soon(Clock(dut.clk_i, CLK_PERIOD_NS, "ns").start())
    dut.data_i.value = 0
    await RisingEdge(dut.clk_i)
    gDATA_W = dut.DATA_W.value
    dut.data_i.value = 2**(gDATA_W-2)
    await RisingEdge(dut.clk_i)
    dut.data_i.value = 0
    for _ in range(100):
        await RisingEdge(dut.clk_i)