`timescale 1ns/10ps

`include "uvm_macros.svh"

// import knihovny UVM
// import UVM library
import uvm_pkg::*;

class my_test extends uvm_test;

  // registrace do factory
  // registration to factory
  `uvm_component_utils(my_test)
  
  // deklarace prostredi a sekvence
  // environment and sequence declaration
  my_pkg::my_env env;
  my_pkg::my_sequence seq;
  
  // konstruktor
  // constructor
  function new (string name = "my_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // faze build
  // build phase
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    // vytvoreni prostredi
    // create environment
    env = my_pkg::my_env::type_id::create("env", this); // konstruktory komponent potrebuji referenci nadrazene komponenty; component constructors need a reference to the parent component
  endfunction
  
  // faze run
  // run phase
  task run_phase (uvm_phase phase);
    uvm_objection objection;
    super.run_phase(phase);

    // moznost nastaveni casu, ktery dobehne jeste potom, co vsechny komponenty stahly sve namitky (tj. umoznily konec testu)
    // possibility to set the time that will run out after all components have withdrawn their objections (i.e. allowed the end of the test)
    //phase.phase_done.set_drain_time(this, 100ns);

    // nekonecna smycka, ktera spousti stale stejnou sekvenci bez namitek - rizeni ukonceni testu je ciste v rezii scoreboardu
    // infinite loop that will always run the same sequence without any objections - test termination control is purely under the control of the scoreboard
    forever begin
      //`uvm_info(get_type_name(), $sformatf("Test: Run: create sequence"), UVM_LOW)
      // vytvor objekt sequence
      // create a sequence object
      seq = my_pkg::my_sequence::type_id::create("seq", this);

      //`uvm_info(get_type_name(), $sformatf("Test: Run: start sequence"), UVM_LOW)
      // zahaj sekvenci - tj. vygeneruj nahodne hodnoty v polozkach objektu tridy my_item a posli objekt pres driver na DUT
      // start the sequence - i.e. randomly generate values ​​in the objects of the my_item class and send the object via the driver to the DUT
      seq.start(env.inst_sequencer);
    end

  endtask
  
  // volitelne - vypis topologie testu a konfiguracni databaze
  // optional - list of test topology and configuration database
  uvm_table_printer printer; // deklarace objektu pro formatovany vypis; declaration of object for formatted output
  
  // faze end of elaboration - debugovaci vypisy mezi sestavenim testovaciho prostredi a zahajenim testu - lze zakomentovat pro mene ukecany vypis
  // end of elaboration phase - debug output between build of the test environment and starting the test - can be commented for a less verbose output
  virtual function void end_of_elaboration_phase (uvm_phase phase);
    // vypis topologie testu
    // print test topology
    `uvm_info(get_type_name(), $sformatf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
    // vypis konfiguracni databaze
    // dump configuration database
    uvm_config_db #(int)::dump();
  endfunction 

endclass
