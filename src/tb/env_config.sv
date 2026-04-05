class env_config extends uvm_object;

bit has_functional_coverage = 0;
bit has_wagent_functional_coverage = 0;
bit has_scoreboard = 1;
bit has_wagent = 1;

wr_agent_config m_wr_agent_cfg[];

int no_of_duts = 2;

`uvm_object_utils(env_config)

extern function new(string name = "env_config");

endclass

function env_config::new(string name = "env_config");
  super.new(name);
endfunction
