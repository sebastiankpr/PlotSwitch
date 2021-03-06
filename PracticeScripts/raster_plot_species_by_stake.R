# Script for producing "heatmap" of capture history of selected species (or individuals)
# EMC 1/2017
# Revised EMC 6/2019

#' @title raster of plot captures
#' @description makes a raster figure displaying locations within plot of rodent captures
#' @param path path to downloaded PortalData
#' @param group_or_individual string or vector of strings indicating which species (or group of multiple species) to focus on
#' @param min_period earliest time period to be included in selecting data
#' 
raster_of_plot_captures = function(path, group_or_individual, min_period){
  # load rodent data
  rdat <- read.csv(paste0(path,'Rodents/Portal_rodent.csv'), header = TRUE, na.strings = c(""), stringsAsFactors = FALSE)

  # table of adjustments to x and y coords to put plots in approximate locations
  plotcoords = data.frame(plot=seq(1,24),
                        x_adj = c(0,10,20,30,40,50, 0,10,20,30,40,50,
                                  0,10,20,30,40,50,60,30,40,50,60,60),
                        y_adj = c(0, 0, 0, 0, 0, 0,10,10,10,10,10,10,20,
                                  20,20,20,20,20,15,30,30,30,25,5))

  # select group (species) or individual to plot.  also time period
  group_or_individual = dplyr::filter(rdat,species==group_or_individual, period > min_period)

  df = capture_history_coordinates(group_or_individual,plotcoords)

  ggplot2::ggplot(df,ggplot2::aes(x_position,y_position,fill=z)) +
    ggplot2::scale_y_continuous(trans = "reverse") +
    ggplot2::geom_raster()
}

#' @title capture history coordinates
#' @description this function takes selected data and counts number of captures at each stake on each plot
#' @param group_or_individual
#' @param plotcoords
capture_history_coordinates = function(group_or_individual,plotcoords) {

  # count number of captures at each stake / plot
  counts = aggregate(group_or_individual$stake,
                     by=list(stake=group_or_individual$stake,plot=group_or_individual$plot),
                     FUN=length)
  names(counts) = c('stake','plot','z')
  counts$x = as.numeric(substr(counts$stake,2,2))
  counts$y = as.numeric(substr(counts$stake,1,1))

  # merge with full 7x7 grid
  g = expand.grid(x=1:7, y=1:7, plot=1:24)
  df = merge(g,counts,by=c('plot','x','y'),all=T)

  # merge with plot-location adjustments
  df = merge(df,plotcoords,all=T)
  df$x_position = df$x+df$x_adj
  df$y_position = df$y+df$y_adj

  # replace NAs with 0s
  df$z[is.na(df$z)]=0

  return(df)
}


