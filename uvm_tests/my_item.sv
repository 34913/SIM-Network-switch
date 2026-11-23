`timescale 1ns/10ps

`include "uvm_macros.svh"

// import knihovny UVM
// import UVM library
import uvm_pkg::*;

class my_item extends uvm_sequence_item;

  // deklarace jednotlivych polozek
  // declaration of individual items
  rand bit [my_pkg::PORT_ADDR_LENGTH-1:0] addr;
  rand bit [my_pkg::DATA_WIDTH-1:0] data;
  
  // omezeni nahodnych hodnot
  // constraint random values
  constraint constraint_addr {
    addr inside {[0:my_pkg::NUM_OF_PORTS-1]};
  }
  
  // registrace tridy a vsech polozek do factory (dulezite! - musi byt pro kazdou polozku)
  // register the class and all items in the factory (important! - must be for each item)
  `uvm_object_utils_begin(my_item)
    `uvm_field_int(addr, UVM_DEFAULT)
    `uvm_field_int(data, UVM_DEFAULT)
//    `uvm_field_int(variable_bit, UVM_DEFAULT) // pro promennou typu bit se take pouziva uvm_field_int; for a bit type variable, uvm_field_int is also used
  `uvm_object_utils_end
  
  // konstruktor
  // constructor
  function new (string name = "my_item");
    super.new(name);
  endfunction

endclass
