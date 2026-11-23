`timescale 1ns/10ps

`include "uvm_macros.svh"

// import knihovny UVM
// import UVM library
import uvm_pkg::*;

class my_sequence extends uvm_sequence #(my_pkg::my_item);
  // zakladni trida uvm_sequence je parametrizovatelna
  // parametr je trida definujici transakci
  // the base class uvm_sequence is parameterizable
  // parameter is the class defining the transaction

  // registrace do factory
  // registration to factory
  `uvm_object_utils(my_sequence)

  // deklarace transakce
  // transaction declaration
  my_pkg::my_item inst_item;

  // konstruktor
  // constructor
  function new(string name = "my_sequence");
    super.new(name);
  endfunction

  // telo sekvence
  // sequence body
  virtual task body();
    // pro jednoduchou sekvenci lze pouzit makro uvm_do
    // for a simple sequence you can use the uvm_do macro
    `uvm_do(inst_item)
  endtask

endclass
