function plot_cascade_survival(fnames,dispatch_types,plot_title,survival_type,display_type,cdf_type,fileout)
  linestyles = {'-','--',':',':',':'};
  for i = 1:length(dispatch_types)
    %%% iter i
    dispatch_type = dispatch_types{i};
    fname = fnames{i};
    
    %%% process
    res = load(fname);
    if strcmp(survival_type, 'lines')
      if length(fieldnames(res)) == 1
        names = fieldnames(res);
        r = getfield(res,names{1});
        ypre = sum(r.tripped_lines_in_scenario,2);
      end
      ymax = max(ypre);
      xpre = 1:(ymax+1);
      x = 1:ymax;
    elseif strcmp(survival_type, 'loadlost_all')
      if length(fieldnames(res)) == 1
        names = fieldnames(res);
        r = getfield(res,names{1});
        ypre = r.lost_load_final;
      end
      ymax = max(ypre);
      xpre = linspace(0,ymax,1001);
      x = linspace(0,ymax,1000);
    elseif strcmp(survival_type, 'loadlost_lines')
      if length(fieldnames(res)) == 1
        names = fieldnames(res);
        r = getfield(res,names{1});
        ypre = r.ls_tripped(:,end);
      end
      ymax = max(ypre);
      xpre = linspace(0,ymax,1001);
      x = linspace(0,ymax,1000);
    elseif strcmp(survival_type, 'loadserved_all')
      if length(fieldnames(res)) == 1
        names = fieldnames(res);
        r = getfield(res,names{1});
        ypre = 1.0 - r.lost_load_final;
      end
      ymax = max(ypre);
      xpre = linspace(0,ymax,1001);
      x = linspace(0,ymax,1000);
    elseif strcmp(survival_type, 'loadserved_lines')
      if length(fieldnames(res)) == 1
        names = fieldnames(res);
        r = getfield(res,names{1});
        ypre = 1.0 - r.ls_tripped(:,end);
      end
      ymax = max(ypre);
      xpre = linspace(0,ymax,1001);
      x = linspace(0,ymax,1000);
    end
    y = histcounts(ypre,xpre);
    mask = find(y > 0);
    xx = x(mask);
    yy = y(mask);
    ncascs_with_failure = sum(yy);
    
    %%% number of cascades with <= or >= L failures
    if strcmp(cdf_type,'cdf')
      number = cumsum(yy);
    elseif strcmp(cdf_type,'ccdf')
      number = cumsum(yy,'reverse');
    end
    proportion = number/ncascs_with_failure;
      
    %%% plot
    if strcmp(display_type,'proportion')
      plot(xx,proportion,'-o',...
                     'MarkerSize',2,...
                     'DisplayName',dispatch_type,...
                     'LineWidth',2,...
                     'LineStyle',linestyles{i})
    elseif strcmp(display_type,'number')
      plot(xx,number,'-o',...
                     'MarkerSize',2,...
                     'DisplayName',dispatch_type,...
                     'LineWidth',2,...
                     'LineStyle',linestyles{i})
    end
    hold on
  end

  %%% formatting
  legend('Location', 'southoutside')
  if strcmp(survival_type, 'lines')
    xlabel('L: number of line failures')
    if strcmp(display_type, 'proportion')
      if strcmp(cdf_type,'cdf')
        ylabel('Proportion of cascades with <= L line failures')
      elseif strcmp(cdf_type,'ccdf')
        ylabel('Proportion of cascades with >= L line failures')
      end
    elseif strcmp(display_type, 'number')
      if strcmp(cdf_type,'cdf')
        ylabel('Number of cascades with <= L line failures')
      elseif strcmp(cdf_type,'ccdf')
        ylabel('Number of cascades with >= L line failures')
      end
    end

  elseif strcmp(survival_type, 'loadlost_all') | strcmp(survival_type, 'loadlost_lines')
    xlabel('L: fraction of total load lost')
    if strcmp(display_type, 'proportion')
      if strcmp(cdf_type,'cdf')
        ylabel('Proportion of cascades with <= L load lost')
      elseif strcmp(cdf_type,'ccdf')
        ylabel('Proportion of cascades with >= L load lost')
      end
    elseif strcmp(display_type, 'number')
      if strcmp(cdf_type,'cdf')
        ylabel('Number of cascades with <= L load lost')
      elseif strcmp(cdf_type,'ccdf')
        ylabel('Number of cascades with >= L load lost')
      end
    end
  
  elseif strcmp(survival_type, 'loadserved_all') | strcmp(survival_type, 'loadserved_lines')
    xlabel('L: fraction of total load served')
    if strcmp(display_type, 'proportion')
      if strcmp(cdf_type,'cdf')
        ylabel('Proportion of cascades with <= L load served')
      elseif strcmp(cdf_type,'ccdf')
        ylabel('Proportion of cascades with >= L load served')
      end
    elseif strcmp(display_type, 'number')
      if strcmp(cdf_type,'cdf')
        ylabel('Number of cascades with <= L load served')
      elseif strcmp(cdf_type,'ccdf')
        ylabel('Number of cascades with >= L load served')
      end
    end
  end
  title(plot_title);
  grid on;
  saveas(gcf,strcat('figures/',survival_type,'_',display_type,'_survival_',cdf_type,'_',fileout,'.png'));
  clf
end