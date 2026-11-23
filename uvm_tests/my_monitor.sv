`timescale 1ns/10ps

`include "uvm_macros.svh"

// import knihovny UVM
// import UVM library
import uvm_pkg::*;

class my_monitor extends uvm_monitor;

  // registrace do factory
  // registration to factory
  `uvm_component_utils(my_monitor)
  
  // deklarace rozhrani DUT
  // DUT interface declaration
  virtual if_lan inst_if_lan;
  
  // deklarace objektu pro ukladani transakce
  // declaration of object for storing transaction
  my_pkg::my_item inst_collected_item;
  
  // port pro odesilani (nejen) do scoreboardu
  // port for sending (not only) to the scoreboard
  uvm_analysis_port #(my_pkg::my_item) inst_collected_item_port;

  // promenna, do ktere se ulozi poradove cislo portu, ke ktere je pripojen konkretni objekt teto tridy
  // variable that stores the serial number of the port to which a specific object of this class is connected
  int monitor_index;
  
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
    // nejprve index - poradove cislo portu
    // first is index - port serial number
    if(!uvm_config_db#(int)::get(this, "", "monitor_index", monitor_index))
      `uvm_fatal("NOPAR", {"Missing monitor_index: ", get_full_name(), ".monitor_index"})    
    // pote rozhrani dle poradoveho cisla portu
    // then interface by port serial number
    if(!uvm_config_db#(virtual if_lan)::get(this, "", $sformatf("inst_if_lan[%0d]", monitor_index), inst_if_lan))
      `uvm_fatal("NOVIF", {"Missing inst_if_lan: ", get_full_name(), ".inst_if_lan"})
  endfunction
  
  // faze run - vlakno, ktere zajisti prevod prijem paketu od prepinace, prevod na transakci a odeslani na kontrolu
  // run phase - thread that ensures listening to the input interface, converting it to a transaction and sending it for checking
  virtual task run_phase(uvm_phase phase);

    // inicializace
    // initialization
    inst_if_lan.port_received <= 1'b0;

    // nekonecna smycka
    // infinite loop
    forever begin
      // cekani na udalost, ktera znaci platnost dat na sbernici
      // waiting for an event that indicates valid data on the bus
      @(posedge inst_if_lan.port_req);
      // vytvoreni noveho objektu transakce
      // create a new transaction object
      inst_collected_item = my_pkg::my_item::type_id::create("inst_collected_item", this);
      // nastaveni polozek
      // set individual items
      inst_collected_item.data = inst_if_lan.port_data;

      // chvile cekani - pro DUT se tvari jako doba, po kterou prijemce paket zpracovava
      // delay - for the DUT it looks like the time the receiver processes the packet
      @(posedge inst_if_lan.clk);
      // potvrzeni pro DUT, ze paket byl prijat
      // acknowledge to DUT that packet was received
      inst_if_lan.port_received <= 1'b1;
      // cekani a ukonceni potvrzovacho signalu
      // waiting and terminating the confirmation signal
      @(posedge inst_if_lan.clk);
      inst_if_lan.port_received <= 1'b0;
      
      // odeslani analytickym portem
      // send using analytical port
      inst_collected_item_port.write(inst_collected_item);
    end
  endtask

endclass
