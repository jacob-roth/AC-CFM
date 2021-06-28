# ==================================================
log10_minor_break = function (...){
  function(x) {
    minx         = floor(min(log10(x), na.rm=T))-1;
    maxx         = ceiling(max(log10(x), na.rm=T))+1;
    n_major      = maxx-minx+1;
    major_breaks = seq(minx, maxx, by=1)
    minor_breaks = 
      rep(log10(seq(1, 9, by=1)), times = n_major)+
      rep(major_breaks, each = 9)
    return(10^(minor_breaks))
  }
}
# ==================================================
# install.packages("R.matlab");
# install.packages("R.oo");
# install.packages("comprehenr");
# install.packages("ggplot2");
# install.packages("reshape2");
# install.packages("latex2exp");
# install.packages("scales");
# install.packages("patchwork");
setwd("~/git/AC-CFM")
library(R.matlab)
library(R.oo)
library(comprehenr)
library(ggplot2)
library(reshape2)
library(latex2exp)
library(scales)
library(patchwork)
LINES <- 5
LOADLOST_ALL <- 20
LOADLOST_LINES <- 19
NETWORK <- 2
BUS <- 3
PD <- 3
BASEMVA <- 2
RES <- 1e-4
# load shed <- load lost
# loglog for all
# ==================================================

casebase <- "118bus_lowdamp_pgliblimits"
methods <- c("acopf","scacopf","fpacopf_09","fpacopf_12","fpacopf_15")
methodlabs <- c("acopf","scacopf","exitrates_1e09","exitrates_1e12","exitrates_1e15")
protections <- c("allprotection","ol_vls_50")
limitscales <- c("1_05","1_10","1_15","1_20")
plottypes <- c("lines","loadlost_all")#,"loadserved_all")

paper_plot <- function(plottype,casebase,methods,methodlabs,protections,limitscales,frac_or_pu,number_or_proportion,alternate_formatting){
  fnames <- c()
  fids <- c()
  for (protection in protections) {
    for (limitscale in limitscales) {
      ##
      ## get data
      ##
      maxlength <- 0
      dataynumber <- vector("list", length(methodlabs))
      datayproportion <- vector("list", length(methodlabs))
      dataxnumber <- vector("list", length(methodlabs))
      dataxproportion <- vector("list", length(methodlabs))
      if (plottype == "lines"){
        plotname <- paste(limitscale,"/",plottype,"_",number_or_proportion,"_",protection,"_",sep='')
        if (alternate_formatting == TRUE){
          (fnameout <- paste("figures/",plotname,casebase,"_alt.pdf",sep=''))
        } else {
          (fnameout <- paste("figures/",plotname,casebase,".pdf",sep=''))
        }
        show(fnameout)
      }
      else {
        plotname <- paste(limitscale,"/",plottype,"_",frac_or_pu,"_",number_or_proportion,"_",protection,"_",sep='')
        if (alternate_formatting == TRUE) {
          (fnameout <- paste("figures/",plotname,casebase,"_alt.pdf",sep=''))
        } else {
          (fnameout <- paste("figures/",plotname,casebase,".pdf",sep=''))
        }
        show(fnameout)
      }
      for (k in 1:length(methods)) {
        method <- methods[k]
        show(c(protection,limitscale,method))
        fid <- paste("cascades_",casebase,"_",method,"_",protection,"_",limitscale,sep='')
        fids <- c(fids,fid)
        fname <- paste("output/",fid,".mat",sep='')
        fnames <- c(fnames,fname)
        df <- readMat(fname)[[1]]
        if (plottype=="lines") {
          yprepre <- data.frame("rawcounts"=rowSums(df[[LINES]]))
          ypre <- yprepre$rawcounts
          x <- 1:max(ypre)
          y <- to_vec(for (v in x) sum((ypre >= v)))
          mask <- (y > 0);
          xx <- x[mask];
          yy <- y[mask];
          if (number_or_proportion == "proportion"){
            xlabel <- "L: Number of failed lines"
            ylabel <- "Pr(Number of failed lines >= L)"
          }
          else {
            xlabel <- "L: Number of failed lines"
            ylabel <- "Number of cascades with failed lines >= L"
          }
        } else if (plottype=="loadlost_all") {
          totalloadpu <- sum(df[[NETWORK]][[BUS]][,PD])/df[[NETWORK]][[BASEMVA]][1,1]
          frac <- df[[LOADLOST_ALL]]
          pu <- frac*totalloadpu
          yprepre <- data.frame("loadlostpu"=pu,"loadlostfrac"=frac)
          if (frac_or_pu == "pu") {
            ypre <- yprepre$loadlostpu
            x <- seq(from=0,to=1,by=RES)*totalloadpu
            y <- to_vec(for (v in x) sum((ypre >= v)))
            mask <- (y > 0) & (x > 0)
            xx <- x[mask];
            yy <- y[mask];
            if (number_or_proportion == "proportion"){
              xlabel <- "x: Load shed (p.u.)"
              ylabel <- "Pr(Load shed >= x)"
            } else {
              xlabel <- "x: Load shed (p.u.)"
              ylabel <- "Number of cascades with load shed >= x"
            }
            
          } else if (frac_or_pu == "frac") {
            ypre <- yprepre$loadlostfrac
            x <- seq(from=0,to=1,by=RES)
            y <- to_vec(for (v in x) sum((ypre >= v)))
            mask <- (y > 0) & (x > 0)
            xx <- x[mask];
            yy <- y[mask];
            if (number_or_proportion == "proportion"){
              xlabel <- "x: Load shed (fraction)"
              ylabel <- "Pr(Load shed >= x)"
            } else {
              xlabel <- "x: Load lost (fraction)"
              ylabel <- "Number of cascades with load shed >= x"
            }
          }
        } else if (plottype=="loadserved_all") {
          totalloadpu <- sum(df[[NETWORK]][[BUS]][,PD])/df[[NETWORK]][[BASEMVA]][1,1]
          frac <- 1-df[[LOADLOST_ALL]]
          pu <- frac*totalloadpu
          yprepre <- data.frame("loadservedpu"=pu,"loadservedfrac"=frac)
          if (frac_or_pu == "pu") {
            ypre <- yprepre$loadservedpu
            ypre <- ypre[(ypre < totalloadpu)] # remove non-failure scenarios
            x <- seq(from=0,to=1,by=RES)*totalloadpu
            y <- to_vec(for (v in x) sum((ypre >= v)))
            mask <- (y > 0) & (x < totalloadpu)
            xx <- x[mask];
            yy <- y[mask];
            if (number_or_proportion == "proportion"){
              xlabel <- "x: Load served (p.u.)"
              ylabel <- "Pr(Load served >= x)"
            } else {
              xlabel <- "x: Load served (p.u.)"
              ylabel <- "Number of cascades with load served >= x"
            }
          } else if (frac_or_pu == "frac") {
            ypre <- yprepre$loadservedfrac
            ypre <- ypre[(ypre < 1)] # remove non-failure scenarios
            x <- seq(from=0,to=1,by=RES)
            y <- to_vec(for (v in x) sum((ypre >= v)))
            mask <- (y > 0) & (x < 1)
            xx <- x[mask];
            yy <- y[mask];
            if (number_or_proportion == "proportion"){
              xlabel <- "x: Load served (fraction)"
              ylabel <- "Pr(Load served >= x)"
            } else {
              xlabel <- "x: Load served (fraction)"
              ylabel <- "Number of cascades with load served >= x"
            }
          }
        }
        ncascs_with_failure <- max(yy);
        yyproportion <- yy/ncascs_with_failure
        dataynumber[[k]] <- yy
        datayproportion[[k]] <- yyproportion
        dataxnumber[[k]] <- xx
        dataxproportion[[k]] <- xx
        maxlength <- max(maxlength,max(length(yy)))
      }
    
      for (k in 1:length(methodlabs)) {
        dataynumber[[k]] <- c(dataynumber[[k]], rep(NA, maxlength-length(dataynumber[[k]])))
        datayproportion[[k]] <- c(datayproportion[[k]], rep(NA, maxlength-length(datayproportion[[k]])))
        dataxnumber[[k]] <- c(dataxnumber[[k]], rep(NA, maxlength-length(dataxnumber[[k]])))
        dataxproportion[[k]] <- c(dataxproportion[[k]], rep(NA, maxlength-length(dataxproportion[[k]])))
      }
      methodlabsy <- to_vec(for (m in methodlabs) paste(m,"_y",sep=''))
      methodlabsx <- to_vec(for (m in methodlabs) paste(m,"_x",sep=''))
      dataynumber <- as.data.frame(dataynumber); names(dataynumber) <- methodlabsy
      datayproportion <- as.data.frame(datayproportion); names(datayproportion) <- methodlabsy
      dataxnumber <- as.data.frame(dataxnumber); names(dataxnumber) <- methodlabsx
      dataxproportion <- as.data.frame(dataxproportion); names(dataxproportion) <- methodlabsx
      datanumber <- cbind(dataynumber,dataxnumber)
      dataproportion <- cbind(datayproportion,dataxproportion)
      ##
      ## make plot
      ##
      if (number_or_proportion == "number") {
        data <- datanumber
      } else if (number_or_proportion == "proportion") {
        data <- dataproportion
      }
      if (alternate_formatting == TRUE){
        pdf(fnameout)
      } else {
        pdf(fnameout)
      }
      sp <- ggplot(data=data) + 
            geom_line(aes(x=acopf_x, y=acopf_y, color = "N-0")) +
            geom_line(aes(x=scacopf_x, y=scacopf_y, color = "N-1")) +
            geom_line(aes(x=exitrates_1e09_x, y=exitrates_1e09_y, color = "lambda = 1e-09")) +
            geom_line(aes(x=exitrates_1e12_x, y=exitrates_1e12_y, color = "lambda = 1e-12")) +
            geom_line(aes(x=exitrates_1e15_x, y=exitrates_1e15_y, color = "lambda = 1e-15")) +
            xlab(xlabel) +
            ylab(ylabel) +
            theme(plot.title = element_text(size = 11, face = "bold")) +
            scale_color_manual(values = c("N-0" = "red",
                                          "N-1" = "brown4",
                                          "lambda = 1e-09" = "blue",
                                          "lambda = 1e-12" = "forestgreen",
                                          "lambda = 1e-15" = "magenta"),
                              limits = c("N-0", "N-1",
                                          "lambda = 1e-09", 
                                          "lambda = 1e-12", 
                                          "lambda = 1e-15"),
                              # labels = c("N-0", "N-1",              #labels = c("N-0", "N-1",
                              #   expression("λ"^"lim"~"="~10^"-9"),  #expression("\U03BB"^"lim"~"="~10^"-9"), 
                              #   expression("λ"^"lim"~"="~10^"-12"), #expression("\U03BB"^"lim"~"="~10^"-12"), 
                              #   expression("λ"^"lim"~"="~10^"-15")) #expression("\U03BB"^"lim"~"="~10^"-15"))
                              labels = c("N-0", "N-1",
                                          unname(TeX(c(
                                            "$\\lambda^{\\mathrm{lim}}\\,=\\,10^{-9}$",
                                            "$\\lambda^{\\mathrm{lim}}\\,=\\,10^{-12}$",
                                            "$\\lambda^{\\mathrm{lim}}\\,=\\,10^{-15}$"
                                          ))))
            ) + labs(color = "")
            if (TRUE) {
              # http://www.sthda.com/english/wiki/ggplot2-axis-scales-and-transformations
              ### albert
              sp <- sp + scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x, n=2),
                                      labels = trans_format("log10", math_format(10^.x)),
                                      minor_breaks=log10_minor_break())
              sp <- sp + scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x, n=2),
                                      labels = trans_format("log10", math_format(10^.x)),
                                      minor_breaks=log10_minor_break())
              if (alternate_formatting == TRUE) {
              #  sp <- sp + theme_bw()# + annotation_logticks()
               sp <- sp + theme_bw() + annotation_logticks(base = 10, sides = "lb")
              }
            } else {
              if (alternate_formatting == TRUE) {
               sp <- sp + theme_bw()
              }
            }
            print(sp)
            dev.off()
    }
  }
}

##
## proportion
##
frac_or_pu <- "pu"
number_or_proportion <- "proportion"
alternate_formatting <- TRUE
for (plottype in plottypes){
  paper_plot(plottype,casebase,methods,methodlabs,protections,limitscales,frac_or_pu,number_or_proportion, alternate_formatting)
}

##
## number
##
frac_or_pu <- "pu"
number_or_proportion <- "number"
alternate_formatting <- TRUE
for (plottype in plottypes){
  paper_plot(plottype,casebase,methods,methodlabs,protections,limitscales,frac_or_pu,number_or_proportion, alternate_formatting)
}