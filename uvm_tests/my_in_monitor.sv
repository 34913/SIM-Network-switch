`timescale 1ns/10ps

`include "uvm_macros.svh"

// import knihovny UVM
// import UVM library
import uvm_pkg::*;

class my_in_monitor extends uvm_monitor;

  // registrace do factory
  // registration to factory
  `uvm_component_utils(my_in_monitor)
  
  // deklarace rozhrani DUT
  // DUT interface declaration
  virtual if_wan inst_if_wan;

  // deklarace objektu pro ukladani transakce
  // declaration of object for storing transaction
  my_pkg::my_item inst_collected_item;
  
  // port pro odesilani (nejen) do scoreboardu
  // port for sending (not only) to the scoreboard
  uvm_analysis_port #(my_pkg::my_item) inst_collected_item_port;
  
  // konstruktor
  // constructor
  function new (string name = "my_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // faze build
  // build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // vytvoreni portu pro odesilani (muze byt i v konstruktoru)
    // create a port for sending (can also be in the constructor)
    inst_collected_item_port = new("inst_collected_item_port", this);

    // vyzvednuti reference na rozhrani DUT z databaze
    // retrieve reference to DUT interface from database
    if(!uvm_config_db#(virtual if_wan)::get(this, "", "inst_if_wan", inst_if_wan))
      `uvm_fatal("NOVIF", {"Missing inst_if_wan: ", get_full_name(), ".inst_if_wan"})
  endfunction
  
  // faze run - vlakno, ktere zajisti odposlech vstupniho rozhrani, prevod na transakci a odeslani na kontrolu
  // run phase - thread that ensures listening to the input interface, converting it to a transaction and sending it for checking
  virtual task run_phase(uvm_phase phase);
    // nekonecna smycka
    // infinite loop
    forever begin
      // cekani na udalost, ktera znaci platnost dat na sbernici
      // waiting for an event that indicates valid data on the bus
      @(posedge inst_if_wan.packet_finished);
      // vytvoreni noveho objektu transakce
      // create a new transaction object
      inst_collected_item = my_pkg::my_item::type_id::create("inst_collected_item", this);
      // nastaveni polozek
      // set individual items
      inst_collected_item.addr = inst_if_wan.packet_addr;
      inst_collected_item.data = inst_if_wan.packet_data;
      // odeslani analytickym portem
      // send using analytical port
      inst_collected_item_port.write(inst_collected_item);
    end
  endtask

endclass
