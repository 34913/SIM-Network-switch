`timescale 1ns/10ps

// import knihovny UVM
// import UVM library
import uvm_pkg::*;

`include "my_pkg.sv"
import my_pkg::*;

// lze presunout do konfiguracniho souboru
// can be moved to the configuration file
`include "if_lan.sv"
`include "if_wan.sv"
`include "top.sv"

module uvm_top;

  // Definice časových jednotek ve výpisech:
  //
  // Jako časová jednotka se použijí nanosekundy (ns).
  // Přesnost na dvě desetinná místa
  // Ke každému zobrazení časové hodnoty přidá "ns".
  // Minimální šířka výpisu je jeden symbol

  // Definition of time units in logs:
  //
  // Use nanoseconds (ns) as a time unit
  // Precision of two fractional digits
  // Append " ns" to every display of time value
  // Minimum field width of one symbol
  initial begin
    $timeformat(-9, 2, " ns", 1);
  end

  // deklarace clk a reset
  // declaration of clk and reset
  bit T_CLK, T_RST; // lze pouzit logic, ale zbytecne; logic can be used, but it's not neccessary

  // generovani hodin
  // generate clock
  always
    #5 T_CLK = ~T_CLK;

  // generovani resetu (muze byt soucasti sekvenci)
  // generate reset (can be part of a sequences)
  initial begin
    T_RST <= 1'b0;
    T_CLK <= 1'b1;
    #1 T_RST <= 1'b1;
    #21 T_RST <= 1'b0;
  end


  // instance vsech rozhrani DUT
  // instances of all DUT interfaces
  if_lan inst_if_lan[my_pkg::NUM_OF_PORTS-1:0] (
    .clk(T_CLK),
    .reset(T_RST)
  );

  if_wan inst_if_wan (
    .clk(T_CLK),
    .reset(T_RST)
    );

  // instance DUT
  // DUT instance
  top _dut (
    .clk(T_CLK),
    .reset(T_RST),
    .interface_input(inst_if_wan.dut),
    .interface_output(inst_if_lan.dut)
  );

  // preposlani referenci na rozhrani do testovaciho prostredi
  // HINT Pole nemůže být indexováno v modulu dynamickou proměnnou -> použít generate loop
  // forward the interface reference to the test environment
  // HINT Array cannot be indexed by dynamic variable in module -> use generate loop
  for(genvar i = 0; i < my_pkg::NUM_OF_PORTS; i++)
  initial begin
    uvm_config_db#(virtual if_lan)::set(uvm_root::get(), "*", $sformatf("inst_if_lan[%0d]",i), inst_if_lan[i]);
  end

  initial begin
    uvm_config_db#(virtual if_wan)::set(uvm_root::get(), "*", "inst_if_wan", inst_if_wan);

    // spusteni testu
    // run test
    run_test("my_test");
  end

  // nepovinne - ulozeni prubehu signalu do souboru typu .vcd
  // optional - save the signal waveform to a .vcd file
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end


endmodule
