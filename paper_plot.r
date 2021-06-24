# ==================================================
setwd("~/git/AC-CFM")
install.packages("R.matlab");library(R.matlab)
install.packages("R.oo");library(R.oo)
LINES <- 5
LOADLOST_ALL <- 20
LOADLOST_LINES <- 19
NETWORK <- 2
BUS <- 3
PD <- 3
BASEMVA <- 2
# ==================================================

casebase <- "118bus_lowdamp_pgliblimits"
methods <- c("acopf","scacopf","fpacopf_09","fpacopf_12","fpacopf_15")
protections <- c("allprotection","ol_vls_50")
limitscales <- c("1_05","1_10","1_15","1_20")
plottypes <- c("lines","loadserved_all","loadlost_all")
frac_or_pu <- "pu"
paper_plot <- function(plottype,casebase,methods,protections,limitscales,frac_or_pu){
  ## get data
  fnames <- c()
  fids <- c()
  for (protection in protections) {
    for (limitscale in limitscales) {
      cdf_df_combined <- NA
      for (method in methods) {
        fid <- paste("cascades_",casebase,"_",method,"_",protection,"_",limitscale,sep='')
        fids <- c(fids,fid)
        fname <- paste("output/",fid,".mat",sep='')
        fnames <- c(fnames,fname)
        df <- readMat(fname)[[1]]
        if (plottype=="lines") {
          ypre <- data.frame("rawcounts"=rowSums(df[[LINES]]))
          ymax <- max(ypre);
          xpre <- 1:(ymax+1);
          x = 1:ymax;
        } else if (plottype=="loadlost_all") {
          totalloadpu <- sum(df[[NETWORK]][[BUS]][,PD])/df[[NETWORK]][[BASEMVA]][1,1]
          frac <- df[[LOADLOST_ALL]]
          pu <- df[[LOADLOST_ALL]]*totalloadpu
          yprepre <- data.frame("loadlostpu"=pu,"loadlostfrac"=frac)
          if (frac_or_pu == "pu") {
            ypre <- yprepre$loadlostpu
          } else if (frac_or_pu == "frac") {
            ypre <- yprepre$loadlostfrac
          }
          ymax <- max(ypre);
          xpre <- seq(from=0,to=ymax,length.out=1001);
          x <- seq(from=0,to=ymax,length.out=1000);
        } else if (plottype=="loadserved_all") {
          ypre <- data.frame(df[[LOADLOST_LINES]])
        }
        
      }
    }
  }
  end
}


ggplot(data=cdf_df_combined, aes(x=alpha)) + 
  geom_line(aes(y=acopf, color = "N-0")) +
  geom_line(aes(y=scacopf, color = "N-1")) +
  geom_line(aes(y=exitrates_1e09, color = "lambda = 1e-09")) +
  geom_line(aes(y=exitrates_1e12, color = "lambda = 1e-12")) +
  geom_line(aes(y=exitrates_1e15, color = "lambda = 1e-15")) +
  scale_y_log10(n.breaks=5) +
  scale_x_log10(n.breaks=10) +
  xlab("L: Number of failed lines") +
  ylab("Pr(Number of failed lines >= L)") +
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
                     labels = c("N-0", "N-1",
                                expression("\U03BB"^"lim"~"="~10^"-9"), 
                                expression("\U03BB"^"lim"~"="~10^"-12"), 
                                expression("\U03BB"^"lim"~"="~10^"-15"))
  ) +
  labs(color = "")