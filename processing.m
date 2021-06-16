r_1=load('r_1.mat')
r_2=load('r_2.mat')
r_3=load('r_3.mat')

load_tripped_1 = r_1.r_1.ls_tripped
load_tripped_2 = r_2.r_2.ls_tripped
load_tripped_3 = r_3.r_3.ls_tripped


%
%%
%%% test 2: 2736 bus
%%
%
x1 = load('test2_2736sp.mat');
x2 = load('test2_2736sp_randomized.mat');
lines1 = sum(x1.result.tripped_lines_in_scenario,2);
lines2 = sum(x2.result.tripped_lines_in_scenario,2);
lines1x = 1:(max(lines1)+1);
lines2x = 1:(max(lines2)+1);
counts1 = histcounts(lines1,lines1x);
counts2 = histcounts(lines2,lines2x);
mask1 = find(counts1 > 0);
mask2 = find(counts2 > 0);
lines1x = 1:max(lines1);
lines2x = 1:max(lines2);

scatter(lines1x(mask1),counts1(mask1),'filled')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlim([0.9,max(lines1x)+10])
ylim([0.9,max(counts1)+10])
xlabel('number of line failures')
ylabel('number of cascades')
title('Base Case: 2736sp')
grid on
saveas(gcf,'test2_2736sp.png')

scatter(lines2x(mask2),counts2(mask2),'filled')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlim([0.9,max(lines2x)+10])
ylim([0.9,max(counts2)+10])
xlabel('number of line failures')
ylabel('number of cascades')
title('Base Case: 2736sp randomized')
grid on
saveas(gcf,'test2_2736sp_randomized.png')

%
%%
%%% test 3: 2736 bus (current + lossless)
%%
%
x1 = load('test3_2736sp.mat');
x2 = load('test3_2736sp_randomized.mat');
lines1 = sum(x1.result.tripped_lines_in_scenario,2);
lines2 = sum(x2.result.tripped_lines_in_scenario,2);
lines1x = 1:(max(lines1)+1);
lines2x = 1:(max(lines2)+1);
counts1 = histcounts(lines1,lines1x);
counts2 = histcounts(lines2,lines2x);
mask1 = find(counts1 > 0);
mask2 = find(counts2 > 0);
lines1x = 1:max(lines1);
lines2x = 1:max(lines2);

scatter(lines1x(mask1),counts1(mask1),'filled')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlim([0.9,max(lines1x)+10])
ylim([0.9,max(counts1)+10])
xlabel('number of line failures')
ylabel('number of cascades')
title('Base Case: 2736sp')
grid on
saveas(gcf,'test3_2736sp.png')

scatter(lines2x(mask2),counts2(mask2),'filled')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlim([0.9,max(lines2x)+10])
ylim([0.9,max(counts2)+10])
xlabel('number of line failures')
ylabel('number of cascades')
title('Base Case: 2736sp randomized')
grid on
saveas(gcf,'test3_2736sp_randomized.png')
