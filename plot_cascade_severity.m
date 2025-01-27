function plot_cascade_severity(fname,plot_title,severity_type,ol_scale)
  %%% process
  res = load(fname);
  if strcmp(severity_type, 'lines')
    if length(fieldnames(res)) == 1
      names = fieldnames(res);
      r = getfield(res,names{1});
      ypre = sum(r.tripped_lines_in_scenario,2);
    end
    ymax = max(ypre);
    xpre = 1:(ymax+1);
    x = 1:ymax;
    y = histcounts(ypre,xpre);
  elseif strcmp(severity_type, 'load')
    if length(fieldnames(res)) == 1
      names = fieldnames(res);
      r = getfield(res,names{1});
      ypre = r.lost_load_final;
    end
    ymax = max(ypre);
    xpre = linspace(0,ymax,1001);
    x = linspace(0,ymax,1000);
    y = histcounts(ypre,xpre);
  end
  mask = find(y > 0);
  xx = x(mask);
  yy = y(mask);
  
  %%% fit
  [slope, intercept] = logfit(xx,yy,'loglog');
  yhat = (10^intercept)*xx.^(slope);

  %%% plot
  scatter(xx,yy,'filled');
  hold on
  plot(xx,yhat,'DisplayName',strcat('slope=',num2str(round(slope,2))));
  set(gca,'XScale','log');
  set(gca,'YScale','log');
  if strcmp(severity_type, 'lines')
    xlim([0.9,max(x)+10]);
    ylim([0.9,max(y)+10]);
    xlabel('Number of line failures');
  elseif strcmp(severity_type, 'load')
    xlim([0.9*min(x),1.1*max(x)]);
    ylim([0.9*min(y),1.1*max(y)]);
    xlabel('Fraction of load lost');
  end
  legend
  ylabel('Number of cascades');
  title(plot_title);
  grid on;
  saveas(gcf,strcat('figures/',ol_scale,'/',severity_type,'_',erase(fname,[".mat","output/"]),'.png'));
  clf
end