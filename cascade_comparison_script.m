clc;clear;

% load default settings
settings = get_default_settings();
settings.seed = 12345

% enable verbose output – just for testing
settings.verbose = 1;
 
% model outage of line 9; this can also be an array of branch indices
initial_contingency = 9; % [29,177];
 
% protection mechanisms
settings.ol  = 1;
settings.vls = 0;
settings.gl  = 0;
settings.xl  = 0;
settings.fls = 0;
settings.intermediate_failures = 0;
settings.ol_scale = 1.0;

% power flow modification settings
settings.lossless = 1;
settings.remove_bshunt = 1;
settings.remove_tap = 1;
settings.lineflows_current = 1;
settings.mpopt.opf.flow_lim = 'I';
settings.mpopt.pf.flow_lim = 'I';
settings.mpopt.cpf.flow_lim = 'I';

c_1 = modifycase(case118_n1_lowdamp,'1_00__0__0__acopf__1_05',settings);
c_2 = modifycase(case118_n1_lowdamp,'1_00__0__0__scacopf__1_05',settings);
c_3 = modifycase(case118_n1_lowdamp,'1_00__0__0__exitrates__1e_15__1_05',settings);

%
%%
%%% single contingency
r_1_single = accfm_comparison(c_1, struct('branches', initial_contingency), settings);
r_2_single = accfm_comparison(c_2, struct('branches', initial_contingency), settings);
r_3_single = accfm_comparison(c_3, struct('branches', initial_contingency), settings);

%
%%
%%% two contingencies
scenarios = {};
acceptable_lines = table2array(readtable('acceptable_lines.csv'));
al = datasample(acceptable_lines,10,'Replace',false)
nl = length(al);
for i = 1:nl
  for j = i+1:nl
    l1 = al(i);
    l2 = al(j);
    % scenarios{end+1} = struct('branches', [l1,l2]);
    scenarios{end+1} = [l1,l2];
  end
end

settings.verbose = 0;
r_1 = accfm_branch_scenarios_comparison(c_1, scenarios, settings);
r_2 = accfm_branch_scenarios_comparison(c_2, scenarios, settings);
r_3 = accfm_branch_scenarios_comparison(c_3, scenarios, settings);
settings.verbose = 1;

save('scens.mat', 'scenarios')
save('r_1.mat', 'r_1')
save('r_2.mat', 'r_2')
save('r_3.mat', 'r_3')

%
%%
%%% zipf contingencies
settings.seed = 12345
z_1 = accfm_pdf_batch_comparison(c_1, 'zipf', 3.0, 20, settings, 'z_1.mat');
z_2 = accfm_pdf_batch_comparison(c_2, 'zipf', 3.0, 20, settings, 'z_1.mat');
z_3 = accfm_pdf_batch_comparison(c_3, 'zipf', 3.0, 20, settings, 'z_1.mat');

settings.vls = 1;
settings.gl  = 1;
settings.xl  = 1;
settings.fls = 1;

z_1 = accfm_pdf_batch_comparison(case2736sp, 'zipf', 3.0, 20, settings, 'z_1.mat');