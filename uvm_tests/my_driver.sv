`timescale 1ns/10ps

`include "uvm_macros.svh"

// import knihovny UVM
// import UVM library
import uvm_pkg::*;

class my_driver extends uvm_driver #(my_pkg::my_item);
  // zakladni trida uvm_driver je parametrizovatelna
  // parametr je trida definujici transakci
  // the base class uvm_driver is parameterizable
  // parameter is the class defining the transaction
  
  // registrace do factory
  // registration to factory
  `uvm_component_utils(my_driver)
  
  // deklarace rozhrani DUT
  // DUT interface declaration
  virtual if_wan inst_if_wan;
  
  // konstruktor
  // constructor
  function new (string name = "my_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // faze build
  // build phase
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // vyzvednuti reference na rozhrani DUT z databaze
    // retrieve reference to DUT interface from database
    if (!uvm_config_db#(virtual if_wan)::get(this, "", "inst_if_wan", inst_if_wan))
      `uvm_fatal("NOVIF", {"Missing inst_if_wan: ", get_full_name(), ".inst_if_wan"})
  endfunction
  
  // faze run
  // run phase
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
  
    // inicializace
    // initialization
    inst_if_wan.packet_send_req <= 1'b0;
    inst_if_wan.packet_addr <= {my_pkg::PORT_ADDR_LENGTH{1'bz}};
    inst_if_wan.packet_data <= {my_pkg::DATA_WIDTH{1'bz}};

    // cekani na reset
    // waiting for reset
    @(posedge inst_if_wan.reset);

    // nekonecna smycka
    // infinite loop
    forever begin

      while(inst_if_wan.reset !== 1'b0) begin
        // pokud (dokud) je reset, tak podrzet vychozi hodnoty
        // if (until) reset is active, keep default values
        inst_if_wan.packet_send_req <= 1'b0;
        inst_if_wan.packet_addr <= {my_pkg::PORT_ADDR_LENGTH{1'bz}};
        inst_if_wan.packet_data <= {my_pkg::DATA_WIDTH{1'bz}};
        @(posedge inst_if_wan.clk);
      end

      // zadost o dalsi polozku ze sekvenceru
      // request the next item from the sequencer
      seq_item_port.get_next_item(req);
      // buzeni DUT - zpravidla v samostatnem tasku, ale neni nutne
      // DUT driving - usually in a separate task, but not necessarily
      drive_item(req);
      // ohlaseni dokonceni buzeni
      // report driving completion
      seq_item_port.item_done();

      // nechat viset hodnoty na sbernici az do dalsiho taktu hodin
      // leave values on the bus until the next clock cycle
      @(posedge inst_if_wan.clk);

    end
  endtask
  
  task drive_item (my_pkg::my_item req);
      // nastaveni polozek (jednotlivych signalu) rozhrani DUT
      // setting items (individual signals) of the DUT interface
      inst_if_wan.packet_send_req <= 1'b1;
      inst_if_wan.packet_addr <= req.addr;
      inst_if_wan.packet_data <= req.data;
      
      // pockat na reakci DUT
      // wait for DUT response
      @(posedge inst_if_wan.packet_finished);
      inst_if_wan.packet_send_req <= 1'b0;

      // vypis hlasky na konzoli
      // print the message to the console
      //`uvm_info(get_type_name(), $sformatf("Driver: item sent: \n%s", req.sprint()), UVM_LOW);
  endtask

endclass
