function plot_cascade_survival(fnames,dispatch_types,plot_title,survival_type,display_type,fileout)
  for i = 1:length(dispatch_types)
    %%% iter i
    dispatch_type = dispatch_types{i};
    fname = fnames{i};
    
    %%% process
    res = load(fname);
    if strcmp(survival_type, 'lines')
      ypre = sum(res.result.tripped_lines_in_scenario,2);
      ymax = max(ypre);
      xpre = 1:(ymax+1);
      x = 1:ymax;
    elseif strcmp(survival_type, 'load')
      ypre = res.result.lost_load_final;
      ymax = max(ypre);
      xpre = linspace(0,ymax,1001);
      x = linspace(0,ymax,1000);
    end
    y = histcounts(ypre,xpre);
    mask = find(y > 0);
    xx = x(mask);
    yy = y(mask);
    ncascs_with_failure = sum(yy);
    
    %%% number of cascades with <= L failures
    number = cumsum(yy);
    proportion = number/ncascs_with_failure;
      
    %%% plot
    if strcmp(display_type,'proportion')
      plot(xx,proportion,'DisplayName',dispatch_type)
    elseif strcmp(display_type,'number')
      plot(xx,number,'DisplayName',dispatch_type)
    end
    hold on
  end

  %%% formatting
  legend
  if strcmp(survival_type, 'lines')
    xlabel('L (number of line failures)')
    ylabel('Proportion of cascades with <= L failures')
  elseif strcmp(survival_type, 'load')
    xlabel('L (fraction of total load lost)')
    ylabel('Proportion of cascades with <= L load lost')
  end
  title(plot_title);
  grid on;
  saveas(gcf,strcat('figures/',fileout,'_',survival_type,'_',display_type,'.png'));
  clf
end