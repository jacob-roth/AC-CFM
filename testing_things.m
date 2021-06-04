clc;clear;

% load default settings
settings = get_default_settings();

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

% power flow modification settings
settings.lossless = 1;
settings.remove_bshunt = 1;
settings.remove_tap = 1;
settings.lineflows_current = 1;
settings.mpopt.opf.flow_lim = 'I';

% apply the model
% result = accfm(case9, struct('branches', initial_contingency), settings);
% result = accfm(case39, struct('branches', initial_contingency), settings);
% result = accfm(case118_n1_lowdamp, struct('branches', initial_contingency), settings);
result = accfm_comparison(case118_n1_lowdamp, struct('branches', initial_contingency), settings);
% result_modified = accfm_comparison(case118_n1_lowdamp_modified, struct('branches', initial_contingency), settings);

result = accfm_comparison(modifycase(case118_n1_lowdamp,'1_00__0__0__acopf__1_05',settings), struct('branches', initial_contingency), settings);
result = accfm_comparison(modifycase(case118_n1_lowdamp,'1_00__0__0__scacopf__1_05',settings), struct('branches', initial_contingency), settings);
result = accfm_comparison(modifycase(case118_n1_lowdamp,'1_00__0__0__exitrates__1e_15__1_05',settings), struct('branches', initial_contingency), settings);

% multiple scenarios
scenarios = []
for l = 1:186
  for ll = l:186
    scenarios = [scenarios, struct('branches', [l,ll])];
  end
end
result_scenarios = accfm_branch_scenarios(case118_n1_lowdamp, scenarios, settings)


% %%%%%%%%%
% % testing
% %%%%%%%%%
% clear;clc;
% % load default settings
% settings = get_default_settings();
% % enable verbose output – just for testing
% settings.verbose = 1;
% % model outage of line 9; this can also be an array of branch indices
% % initial_contingency = 9;%[29,177];
% initial_contingency = struct('branches', 9);

% network=case118_n1_lowdamp
% network=case39
% define_constants;

%%%
%%% accfcm_comparison
%%%
% load empty initial contingency if no other specified
if ~exist('initial_contingency', 'var') || ~isstruct(initial_contingency)
    initial_contingency = struct;
end

if ~isfield(initial_contingency, 'buses')
    initial_contingency.buses = [];
end

if ~isfield(initial_contingency, 'branches')
    initial_contingency.branches = [];
end

if ~isfield(initial_contingency, 'gens')
    initial_contingency.gens = [];
end

startTime = tic;

% ensure there are no components in the contingency that don't exist
initial_contingency.buses(initial_contingency.buses > size(network.bus, 1)) = [];
initial_contingency.branches(initial_contingency.branches < 1 | initial_contingency.branches > size(network.branch, 1)) = [];
initial_contingency.gens(initial_contingency.gens > size(network.gen, 1)) = [];

% load default settings if no other specified
if ~exist('settings', 'var') || ~isstruct(settings)
    settings = get_default_settings();
end

% add custom fields for identification of elements after extracting
% islands
network.bus_id = (1:size(network.bus, 1)).';
network.gen_id = (1:size(network.gen, 1)).';
network.branch_id = (1:size(network.branch, 1)).';

% add custom fields for result variables
network.branch_tripped = zeros(size(network.branch, 1), settings.max_recursion_depth);
network.bus_tripped = zeros(size(network.bus, 1), settings.max_recursion_depth);
network.bus_uvls = zeros(size(network.bus, 1), settings.max_recursion_depth);
network.bus_ufls = zeros(size(network.bus, 1), settings.max_recursion_depth);
network.gen_tripped = zeros(size(network.gen, 1), settings.max_recursion_depth);
network.load = zeros(settings.max_recursion_depth, 1);
network.generation_before = sum(network.gen(:, PG));
network.pf_count = 0;

% add custom fields to include in MATPOWER case structs
settings.custom.bus{1} = {'bus_id', 'bus_tripped', 'bus_uvls', 'bus_ufls'};
settings.custom.gen{1} = {'gen_id', 'gen_tripped'};
settings.custom.branch{1} = {'branch_id', 'branch_tripped'};

% get load before cascade
load_initial = sum(network.bus(:, PD));

% initialise cascade graph
network.G = digraph();
network.G = addnode(network.G, table({'root'}, size(network.bus, 1), {'root'}, load_initial, length(find(network.gen(:, GEN_STATUS) == 1)), length(find(network.branch(:, BR_STATUS) == 1)), 'VariableNames', {'Name', 'Buses', 'Type', 'Load', 'Generators', 'Lines'}));

% apply initial contingency
network.bus(initial_contingency.buses, BUS_TYPE) = NONE;
network.branch(initial_contingency.branches, BR_STATUS) = 0;
network.gen(initial_contingency.gens, GEN_STATUS) = 0;

network.G = addnode(network.G, table({'event'}, size(network.bus, 1), {'event'}, load_initial, length(find(network.gen(:, GEN_STATUS) == 1)), length(find(network.branch(:, BR_STATUS) == 1)), 'VariableNames', {'Name', 'Buses', 'Type', 'Load', 'Generators', 'Lines'}));
network.G = addedge(network.G, table({'root' 'event'}, {'EV'}, 1, 1, NaN, 'VariableNames', {'EndNodes', 'Type', 'Weight', 'Base', 'LS'}));

% disable MATLAB warnings
warning('off', 'MATLAB:nearlySingularMatrix');
warning('off', 'MATLAB:singularMatrix');


%%%
%%% apply_recursion
%%%
% default values
if ~exist('i', 'var')
    i = 1;
end

if ~exist('k', 'var')
    k = 0;
end

if ~exist('Gnode_parent', 'var')
    Gnode_parent = 'event';
end

% error if iteration limit reached
if i + k > settings.max_recursion_depth
    error('Iteration limit reached');
end

% find all islands
[groups, isolated] = find_islands(network);
isolated = num2cell(isolated);

% combine islands and isolated buses
if size(groups) == 0
    %islands = {isolated{:}};
    islands = isolated(:);
else
    islands = [groups(:)', isolated(:)'];
    %islands = {groups{:}, isolated{:}};
end



% % start the recursion
% result_cascade = apply_recursion(network, settings);

% % enable MATLAB warnings
% warning('on', 'MATLAB:nearlySingularMatrix');
% warning('on', 'MATLAB:singularMatrix');

% % get load after cascade
% load_final = sum(result_cascade.bus(:, PD));

% % calculate ls
% result_cascade.ls_total =  (1 - load_final / load_initial);
% result_cascade.ls_ufls = sum(result_cascade.G.Edges.LS(strcmp(result_cascade.G.Edges.Type, 'UFLS'))) / load_initial;
% result_cascade.ls_uvls = sum(result_cascade.G.Edges.LS(strcmp(result_cascade.G.Edges.Type, 'UVLS'))) / load_initial;
% result_cascade.ls_vcls = sum(result_cascade.G.Edges.LS(strcmp(result_cascade.G.Edges.Type, 'VC'))) / load_initial;
% result_cascade.ls_opf = sum(result_cascade.G.Edges.LS(strcmp(result_cascade.G.Edges.Type, 'OPF'))) / load_initial;
% result_cascade.ls_tripped = result_cascade.ls_total - result_cascade.ls_ufls - result_cascade.ls_uvls - result_cascade.ls_vcls - result_cascade.ls_opf;

% result_cascade.elapsed = toc(startTime);

% % in verbose mode, display graph
% if settings.verbose
%     fprintf('Cascade halted. Elapsed time: %.2fs\n', result_cascade.elapsed);
%     fprintf('Total load shedding: %.2f%%\n', 100 * result_cascade.ls_total);
%     fprintf('Load shedding UFLS: %.2f%% \n', 100 * result_cascade.ls_ufls);
%     fprintf('Load shedding UVLS: %.2f%% \n', 100 * result_cascade.ls_uvls);
%     fprintf('Load shedding VCLS: %.2f%% \n', 100 * result_cascade.ls_vcls);
%     fprintf('Load shedding non-converging OPF: %.2f%% \n', 100 * result_cascade.ls_opf);
%     fprintf('Load shedding tripped: %.2f%% \n', 100 * result_cascade.ls_tripped);

%     plot_cascade_graph(result_cascade);
% end


% result = accfm_comparison(case118_n1_lowdamp, struct('branches', 9), settings);

%%%%%%%%%%
% opf line limits
%%%%%%%%%%
% mpc = loadcase('case118_n1_lowdamp')
% mpc = toggle_iflims(mpc, 'on');

% resI = runopf(case118_n1_lowdamp, mpoption(settings.mpopt, 'opf.flow_lim', 'I'))
% resP = runopf(case118_n1_lowdamp, mpoption(settings.mpopt, 'opf.flow_lim', 'P'))
% res0 = runopf(case118_n1_lowdamp)

% out.lim.line

r1 = runpf(modifycase(case118_n1_lowdamp,'1_00__0__0__acopf__1_05',settings))
r2 = runpf(modifycase(case118_n1_lowdamp,'1_00__0__0__scacopf__1_05',settings))
r3 = runpf(modifycase(case118_n1_lowdamp,'1_00__0__0__exitrates__1e_15__1_05',settings))