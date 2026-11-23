`timescale 1ns/10ps

`include "uvm_macros.svh"

// import knihovny UVM
// import UVM library
import uvm_pkg::*;

class my_env extends uvm_env;

  // registrace do factory
  // registration to factory
  `uvm_component_utils(my_env)
  
  // deklarace vsech komponent
  // declaration of all components
  my_pkg::my_driver inst_driver;
  my_pkg::my_in_monitor inst_in_monitor;
  my_pkg::my_monitor inst_monitor[my_pkg::NUM_OF_PORTS-1:0];
  my_pkg::my_scoreboard inst_scoreboard;
  my_pkg::my_sequencer inst_sequencer;
  
  // konstruktor
  // constructor
  function new (string name = "my_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // faze build
  // build phase
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
  
    // vytvoreni vsech komponent
    // konfigurace komponent - ulozeni do databaze
    // construction of all components
    // component configuration - saving to database
    inst_driver = my_pkg::my_driver::type_id::create("inst_driver", this);
    for (int i = 0; i < my_pkg::NUM_OF_PORTS; i++) begin
      inst_monitor[i] = my_pkg::my_monitor::type_id::create($sformatf("inst_monitor[%0d]", i), this);
      uvm_config_db#(int)::set(this, $sformatf("inst_monitor[%0d]", i), "monitor_index", i);
    end

    inst_in_monitor = my_pkg::my_in_monitor::type_id::create("inst_in_monitor", this);
    inst_scoreboard = my_pkg::my_scoreboard::type_id::create("inst_scoreboard", this);
    inst_sequencer = my_pkg::my_sequencer::type_id::create("inst_sequencer", this);
  endfunction
  
  // faze connect - propojeni portu komponent
  // connect phase - component ports connection
  virtual function void connect_phase (uvm_phase phase);
    // propojeni monitor -> scoreboard
    foreach(inst_monitor[i]) inst_monitor[i].inst_collected_item_port.connect(inst_scoreboard.inst_out_fifo[i].analysis_export);

    // propojeni monitor vstupu -> scoreboard
    // connect input monitor -> scoreboard
    inst_in_monitor.inst_collected_item_port.connect(inst_scoreboard.inst_in_fifo.analysis_export);

    // propojeni driver <- sequencer
    // driver <- sequencer connection
    inst_driver.seq_item_port.connect(inst_sequencer.seq_item_export);
  endfunction

endclass
