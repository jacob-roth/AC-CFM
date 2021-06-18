clc;clear;

%
%%
%%% cascade comparison script (only line overload protection mechanism)
%%
%

% default settings
settings = get_default_settings();
settings.seed = 12345;

% verbosity
settings.verbose = 0;
  
% protection mechanisms
settings.ol  = 1;
settings.vls = 1;
settings.gl  = 0;
settings.xl  = 0;
settings.fls = 0;
settings.intermediate_failures = 50;
settings.ol_scale = 1.0;

% power flow modification settings
settings.lossless = 1;
settings.remove_bshunt = 1;
settings.remove_tap = 1;
settings.lineflows_current = 1;
settings.mpopt.opf.flow_lim = 'I';
settings.mpopt.pf.flow_lim = 'I';
settings.mpopt.cpf.flow_lim = 'I';

% base mpc case
mpc_case = mpc_lowdamp_pgliblimits;
f_1 = '1_00__0__0__acopf__1_20';
f_2 = '1_00__0__0__scacopf__1_20';
f_3 = '1_00__0__0__exitrates__1e_09__1_20';
f_4 = '1_00__0__0__exitrates__1e_12__1_20';
f_5 = '1_00__0__0__exitrates__1e_15__1_20';

% result file name
co_1 = 'output/cascades_118bus_lowdamp_pgliblimits_acopf_ol_vls_50.mat';
co_2 = 'output/cascades_118bus_lowdamp_pgliblimits_scacopf_ol_vls_50.mat';
co_3 = 'output/cascades_118bus_lowdamp_pgliblimits_fpacopf_09_ol_vls_50.mat';
co_4 = 'output/cascades_118bus_lowdamp_pgliblimits_fpacopf_12_ol_vls_50.mat';
co_5 = 'output/cascades_118bus_lowdamp_pgliblimits_fpacopf_15_ol_vls_50.mat';

% contingencies
raw = table2array(readtable('data/ic_IDs.txt'));
contingencies = {};
for i = 1:size(raw,1)
  contingencies{i} = raw(i,:);
end

%
%%
%%% cascades
c_1 = modifycase(mpc_case,f_1,settings);
c_2 = modifycase(mpc_case,f_2,settings);
c_3 = modifycase(mpc_case,f_3,settings);
c_4 = modifycase(mpc_case,f_4,settings);
c_5 = modifycase(mpc_case,f_5,settings);
r_1 = accfm_branch_scenarios_comparison(c_1,contingencies,settings); save(co_1,'r_1');
r_2 = accfm_branch_scenarios_comparison(c_2,contingencies,settings); save(co_2,'r_2');
r_3 = accfm_branch_scenarios_comparison(c_3,contingencies,settings); save(co_3,'r_3');
r_4 = accfm_branch_scenarios_comparison(c_4,contingencies,settings); save(co_4,'r_4');
r_5 = accfm_branch_scenarios_comparison(c_5,contingencies,settings); save(co_5,'r_5');

%
%%
%%% plotting lines and loads
plot_cascade_severity(co_1,'118bus N-0 ACOPF','lines');
plot_cascade_severity(co_2,'118bus N-1 SC-ACOPF','lines');
plot_cascade_severity(co_3,'118bus N-k FP-ACOPF 1e-09','lines');
plot_cascade_severity(co_4,'118bus N-k FP-ACOPF 1e-12','lines');
plot_cascade_severity(co_5,'118bus N-k FP-ACOPF 1e-15','lines');
% plot_cascade_severity(co_1,'118bus N-0 ACOPF','load');
% plot_cascade_severity(co_2,'118bus N-1 SC-ACOPF','load');
% plot_cascade_severity(co_3,'118bus N-k FP-ACOPF 1e-09','load');
% plot_cascade_severity(co_4,'118bus N-k FP-ACOPF 1e-12','load');
% plot_cascade_severity(co_5,'118bus N-k FP-ACOPF 1e-15','load');

%
%%
%%% plotting survival
dispatch_types = {'N-0 ACOPF', 'N-1 SC-ACOPF', 'N-k FP-ACOPF (1e-09)', 'N-k FP-ACOPF (1e-12)', 'N-k FP-ACOPF (1e-15)'};
fnames = {co_1, co_2, co_3, co_4, co_5};
% %cdf
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','proportion','cdf',       'mpc_lowdamp_pgliblimits_ol_vls_50');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','number','cdf',           'mpc_lowdamp_pgliblimits_ol_vls_50');
% % plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadlost','proportion','cdf',    'mpc_lowdamp_pgliblimits_ol_vls_50');
% % plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadlost','number','cdf',        'mpc_lowdamp_pgliblimits_ol_vls_50');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_all','proportion','cdf',  'mpc_lowdamp_pgliblimits_ol_vls_50');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_all','number','cdf',      'mpc_lowdamp_pgliblimits_ol_vls_50');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_lines','proportion','cdf',  'mpc_lowdamp_pgliblimits_ol_vls_50');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_lines','number','cdf',      'mpc_lowdamp_pgliblimits_ol_vls_50');
%ccdf
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','proportion','ccdf',      'mpc_lowdamp_pgliblimits_ol_vls_50');
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','number','ccdf',          'mpc_lowdamp_pgliblimits_ol_vls_50');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadlost','proportion','ccdf',   'mpc_lowdamp_pgliblimits_ol_vls_50');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadlost','number','ccdf',       'mpc_lowdamp_pgliblimits_ol_vls_50');
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_all','proportion','ccdf', 'mpc_lowdamp_pgliblimits_ol_vls_50');
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_all','number','ccdf',     'mpc_lowdamp_pgliblimits_ol_vls_50');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_lines','proportion','ccdf', 'mpc_lowdamp_pgliblimits_ol_vls_50');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_lines','number','ccdf',     'mpc_lowdamp_pgliblimits_ol_vls_50');

%
%%
%%% cascade comparison script (all protection mechanisms)
%%
%

% default settings
settings = get_default_settings();
settings.seed = 12345

% verbosity
settings.verbose = 0;
  
% protection mechanisms
settings.ol  = 1;
settings.vls = 1;
settings.gl  = 1;
settings.xl  = 1;
settings.fls = 1;
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

% base mpc case
mpc_case = mpc_lowdamp_pgliblimits;
f_1 = '1_00__0__0__acopf__1_20';
f_2 = '1_00__0__0__scacopf__1_20';
f_3 = '1_00__0__0__exitrates__1e_09__1_20';
f_4 = '1_00__0__0__exitrates__1e_12__1_20';
f_5 = '1_00__0__0__exitrates__1e_15__1_20';

% result file name
co_1 = 'output/cascades_118bus_lowdamp_pgliblimits_acopf_allprotection.mat';
co_2 = 'output/cascades_118bus_lowdamp_pgliblimits_scacopf_allprotection.mat';
co_3 = 'output/cascades_118bus_lowdamp_pgliblimits_fpacopf_09_allprotection.mat';
co_4 = 'output/cascades_118bus_lowdamp_pgliblimits_fpacopf_12_allprotection.mat';
co_5 = 'output/cascades_118bus_lowdamp_pgliblimits_fpacopf_15_allprotection.mat';

% contingencies
raw = table2array(readtable('data/ic_IDs.txt'));
contingencies = {};
for i = 1:size(raw,1)
  contingencies{i} = raw(i,:);
end

%
%%
%%% cascades
c_1 = modifycase(mpc_case,f_1,settings);
c_2 = modifycase(mpc_case,f_2,settings);
c_3 = modifycase(mpc_case,f_3,settings);
c_4 = modifycase(mpc_case,f_4,settings);
c_5 = modifycase(mpc_case,f_5,settings);
r_1 = accfm_branch_scenarios_comparison(c_1,contingencies,settings); save(co_1,'r_1');
r_2 = accfm_branch_scenarios_comparison(c_2,contingencies,settings); save(co_2,'r_2');
r_3 = accfm_branch_scenarios_comparison(c_3,contingencies,settings); save(co_3,'r_3');
r_4 = accfm_branch_scenarios_comparison(c_4,contingencies,settings); save(co_4,'r_4');
r_5 = accfm_branch_scenarios_comparison(c_5,contingencies,settings); save(co_5,'r_5');

%
%%
%%% plotting lines
plot_cascade_severity(co_1,'118bus N-0 ACOPF','lines');
plot_cascade_severity(co_2,'118bus N-1 SC-ACOPF','lines');
plot_cascade_severity(co_3,'118bus N-k FP-ACOPF 1e-09','lines');
plot_cascade_severity(co_4,'118bus N-k FP-ACOPF 1e-12','lines');
plot_cascade_severity(co_5,'118bus N-k FP-ACOPF 1e-15','lines');
% plot_cascade_severity(co_1,'118bus N-0 ACOPF','load');
% plot_cascade_severity(co_2,'118bus N-1 SC-ACOPF','load');
% plot_cascade_severity(co_3,'118bus N-k FP-ACOPF 1e-09','load');
% plot_cascade_severity(co_4,'118bus N-k FP-ACOPF 1e-12','load');
% plot_cascade_severity(co_5,'118bus N-k FP-ACOPF 1e-15','load');

%
%%
%%% plotting survival
dispatch_types = {'N-0 ACOPF', 'N-1 SC-ACOPF', 'N-k FP-ACOPF (1e-09)', 'N-k FP-ACOPF (1e-12)', 'N-k FP-ACOPF (1e-15)'};
fnames = {co_1, co_2, co_3, co_4, co_5};
% %cdf
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','proportion','cdf',      'mpc_lowdamp_pgliblimits_allprotection');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','number','cdf',          'mpc_lowdamp_pgliblimits_allprotection');
% % plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadlost','proportion','cdf',   'mpc_lowdamp_pgliblimits_allprotection');
% % plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadlost','number','cdf',       'mpc_lowdamp_pgliblimits_allprotection');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_all','proportion','cdf', 'mpc_lowdamp_pgliblimits_allprotection');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_all','number','cdf',     'mpc_lowdamp_pgliblimits_allprotection');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_lines','proportion','cdf', 'mpc_lowdamp_pgliblimits_allprotection');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_lines','number','cdf',     'mpc_lowdamp_pgliblimits_allprotection');
%ccdf
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','proportion','ccdf',     'mpc_lowdamp_pgliblimits_allprotection');
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','number','ccdf',         'mpc_lowdamp_pgliblimits_allprotection');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadlost','proportion','ccdf',  'mpc_lowdamp_pgliblimits_allprotection');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadlost','number','ccdf',      'mpc_lowdamp_pgliblimits_allprotection');
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_all','proportion','ccdf','mpc_lowdamp_pgliblimits_allprotection');
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_all','number','ccdf',    'mpc_lowdamp_pgliblimits_allprotection');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_lines','proportion','ccdf','mpc_lowdamp_pgliblimits_allprotection');
% plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','loadserved_lines','number','ccdf',    'mpc_lowdamp_pgliblimits_allprotection');


% result1 = accfm_comparison(c_1,struct('branches',contingencies{6}),settings)
% result2 = accfm_branch_scenarios_comparison(c_1,{contingencies{6}},settings)
% result1 = accfm_comparison(c_1,struct('branches',contingencies{377}),settings)
% result2 = accfm_branch_scenarios_comparison(c_1,{contingencies{377}},settings)
% result1 = accfm_comparison(c_1,struct('branches',contingencies{688}),settings)
% result2 = accfm_branch_scenarios_comparison(c_1,{contingencies{688}},settings)
