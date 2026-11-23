
// UVM macros
`include "uvm_macros.svh"
// UVM class library compiled in a package
import uvm_pkg::*;

`include "uvm_top.sv"

config cfg1;
  design work.uvm_top; // top module name
endconfig
